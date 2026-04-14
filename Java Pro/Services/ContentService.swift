//
//  ContentService.swift
//  Java Pro
//
//  バンドル内のJSONファイルから教材データを読み込み、
//  インメモリにキャッシュして高速検索を提供するサービス。
//  アプリ起動時に1回だけロードし、以降は参照のみ。
//

import Foundation

/// 教材コンテンツの読み込み・検索を担当するシングルトンサービス。
@MainActor
@Observable
final class ContentService {
    static let shared = ContentService()

    // MARK: - キャッシュ

    private(set) var courseIndexes: [CourseIndex] = []
    private var chapters: [String: ChapterContent] = [:]        // courseId -> ChapterContent
    /// コースID → ソート済みレッスン配列（getLessons 呼び出しごとのソートを排除）
    private var sortedLessonsCache: [String: [LessonData]] = [:]
    private var lessonsIndex: [String: LessonData] = [:]         // lessonId -> LessonData
    private var quizzesIndex: [String: QuizData] = [:]           // quizId  -> QuizData
    /// クイズタイプ別IDキャッシュ（typeRawValue -> Set<quizId>）
    private var quizIdsByTypeCache: [String: Set<String>] = [:]
    /// クイズタイプ別キャッシュが無効化されたかどうかのフラグ
    private var isQuizTypeCacheDirty = true
    private(set) var glossary: [GlossaryEntry] = []

    private(set) var isLoaded = false

    /// コースインデックスのみが読み込み済みかどうか（チャプターは未ロードの可能性あり）
    private(set) var isCourseIndexLoaded = false

    /// コンテンツ読み込みで発生したエラーメッセージ（UI表示用）
    private(set) var loadError: String?

    /// チャプターロード中のcoruseId set（二重ロード防止）
    private var loadingChapterIds: Set<String> = []

    private init() {}

    // MARK: - ロード

    /// 言語切替時にキャッシュをクリアして再ロードする。
    func reloadForLanguageChange() async {
        // 全キャッシュクリア
        courseIndexes = []
        chapters = [:]
        sortedLessonsCache = [:]
        lessonsIndex = [:]
        quizzesIndex = [:]
        quizIdsByTypeCache = [:]
        isQuizTypeCacheDirty = true
        glossary = []
        isLoaded = false
        isCourseIndexLoaded = false
        loadError = nil
        loadingChapterIds = []

        // 再ロード
        await loadAllContentAsync()
    }

    /// バンドル内の全教材データを読み込む。起動時に1回だけ呼ぶ。
    /// - Note: 非同期版 `loadAllContentAsync()` を使用してください。
    @available(*, deprecated, message: "Use loadAllContentAsync() instead")
    func loadAllContent() {
        guard !isLoaded else { return }

        loadCourseIndex()
        for course in courseIndexes {
            loadChapter(course: course)
        }
        loadGlossary()
        isLoaded = true
    }

    private var isLoadingAsync = false

    /// バックグラウンドでJSONを読み込み、完了後にキャッシュに反映する。
    /// Phase 1: コースインデックスを先行ロード（高速）
    /// Phase 2: チャプター・用語集をバックグラウンドで一括ロード
    func loadAllContentAsync() async {
        guard !isLoaded, !isLoadingAsync else { return }
        isLoadingAsync = true
        defer { isLoadingAsync = false }

        // Phase 1: コースインデックスだけ先にロード（軽量・高速）
        let currentLanguage = LanguageManager.shared.currentLanguage
        let courseResult: ([CourseIndex], String?) = await Task.detached(priority: .userInitiated) {
            let fileName = Self.localizedFileName("courses_index", language: currentLanguage)
            if let data = Self.loadJSONDataFromBundle(fileName: fileName) {
                if let decoded = Self.decodeCourseIndexes(from: data) {
                    return (decoded.sorted { $0.order < $1.order }, nil)
                } else {
                    return ([], "courses_index.json のパースに失敗")
                }
            } else {
                return ([], "courses_index.json が見つかりません")
            }
        }.value

        courseIndexes = courseResult.0
        if let error = courseResult.1 {
            loadError = error
        }
        isCourseIndexLoaded = true

        // Phase 2: ファイルI/Oをバックグラウンドで実行し、デコードはメインスレッドで行う
        // （ChapterContent の Decodable 合成が MainActor 分離のため）
        let rawData: (chapterData: [(String, String, Data)], glossaryData: Data?, errors: [String]) = await Task.detached(priority: .userInitiated) {
            var chapterData: [(String, String, Data)] = []  // (courseId, fileName, data)
            var glossaryData: Data?
            var errors: [String] = []

            for course in courseResult.0 {
                let localizedName = Self.localizedFileName(course.fileName, language: currentLanguage)
                if let data = Self.loadJSONDataFromBundle(fileName: localizedName) {
                    chapterData.append((course.id, localizedName, data))
                } else {
                    errors.append("\(course.fileName).json が見つかりません")
                }
            }

            let glossaryFile = Self.localizedFileName("glossary", language: currentLanguage)
            if let data = Self.loadJSONDataFromBundle(fileName: glossaryFile) {
                glossaryData = data
            } else {
                errors.append("glossary.json が見つかりません")
            }

            return (chapterData, glossaryData, errors)
        }.value

        // メインスレッドでデコード＆キャッシュに格納
        var decodeErrors: [String] = []
        for (courseId, fileName, data) in rawData.chapterData {
            if let chapter = try? JSONDecoder().decode(ChapterContent.self, from: data) {
                registerChapter(courseId: courseId, chapter: chapter)
            } else {
                decodeErrors.append("\(fileName).json のパースに失敗")
            }
        }

        if let glossaryData = rawData.glossaryData {
            if let decoded = try? JSONDecoder().decode([GlossaryEntry].self, from: glossaryData) {
                glossary = decoded.sorted { $0.term < $1.term }
            } else {
                decodeErrors.append("glossary.json のパースに失敗")
            }
        }

        let allErrors = rawData.errors + decodeErrors
        if !allErrors.isEmpty {
            loadError = (loadError.map { $0 + "\n" } ?? "") + allErrors.joined(separator: "\n")
        }

        isLoaded = true
    }

    /// 個別チャプターをオンデマンドでロードする。
    /// 既にロード済みの場合は何もしない。
    /// - Note: 将来の遅延ロード対応用。現在は loadAllContentAsync() が全チャプターを一括ロードする。
    func ensureChapterLoaded(courseId: String) async {
        guard chapters[courseId] == nil,
              !loadingChapterIds.contains(courseId),
              let course = courseIndexes.first(where: { $0.id == courseId }) else {
            return
        }
        loadingChapterIds.insert(courseId)
        defer { loadingChapterIds.remove(courseId) }

        // ファイルI/Oのみバックグラウンドで実行
        let data: Data? = await Task.detached(priority: .userInitiated) {
            Self.loadJSONDataFromBundle(fileName: course.fileName)
        }.value

        // デコードはメインスレッドで実行（ChapterContent の Decodable がメインアクター分離のため）
        if let data,
           let chapter = try? JSONDecoder().decode(ChapterContent.self, from: data) {
            registerChapter(courseId: courseId, chapter: chapter)
        }
    }

    /// チャプターデータをキャッシュに登録する共通ヘルパー。
    private func registerChapter(courseId: String, chapter: ChapterContent) {
        chapters[courseId] = chapter
        sortedLessonsCache[courseId] = chapter.lessons.sorted { $0.order < $1.order }
        for lesson in chapter.lessons {
            lessonsIndex[lesson.id] = lesson
            for quiz in lesson.quizzes {
                quizzesIndex[quiz.id] = quiz
            }
        }
        // タイプ別キャッシュを無効化（再構築は次回アクセス時）
        isQuizTypeCacheDirty = true
    }

    /// バンドルからJSONデータを読み込む（スレッドセーフ）。
    private nonisolated static func loadJSONDataFromBundle(fileName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    /// 言語対応のファイル名を解決する。
    /// 英語の場合: `fileName_en` を優先、見つからなければ日本語版にフォールバック。
    /// 日本語の場合: 元の `fileName` をそのまま使用。
    private nonisolated static func localizedFileName(_ baseName: String, language: AppLanguage) -> String {
        guard language == .english else { return baseName }
        let enName = "\(baseName)_en"
        // 英語版が存在すればそれを使用、なければ日本語版にフォールバック
        if Bundle.main.url(forResource: enName, withExtension: "json") != nil {
            return enName
        }
        return baseName
    }

    /// バンドルJSONをデコードする（nonisolated — Task.detached コンテキストで安全に使用可能）。
    private nonisolated static func decodeCourseIndexes(from data: Data) -> [CourseIndex]? {
        try? JSONDecoder().decode([CourseIndex].self, from: data)
    }

    private func loadCourseIndex() {
        guard let data = loadJSONData(fileName: "courses_index") else {
            let msg = "courses_index.json が見つかりません"
            assertionFailure(msg)
            loadError = msg
            return
        }
        do {
            courseIndexes = try JSONDecoder().decode([CourseIndex].self, from: data)
                .sorted { $0.order < $1.order }
        } catch {
            let msg = "courses_index.json のパースに失敗: \(error)"
            assertionFailure(msg)
            loadError = msg
        }
    }

    private func loadChapter(course: CourseIndex) {
        guard let data = loadJSONData(fileName: course.fileName) else {
            let msg = "\(course.fileName).json が見つかりません"
            assertionFailure(msg)
            loadError = loadError ?? msg
            return
        }
        do {
            let chapter = try JSONDecoder().decode(ChapterContent.self, from: data)
            chapters[course.id] = chapter
            sortedLessonsCache[course.id] = chapter.lessons.sorted { $0.order < $1.order }

            // インデックス構築
            for lesson in chapter.lessons {
                lessonsIndex[lesson.id] = lesson
                for quiz in lesson.quizzes {
                    quizzesIndex[quiz.id] = quiz
                }
            }
        } catch {
            let msg = "\(course.fileName).json のパースに失敗: \(error)"
            assertionFailure(msg)
            loadError = loadError ?? msg
        }
    }

    private func loadGlossary() {
        guard let data = loadJSONData(fileName: "glossary") else {
            let msg = "glossary.json が見つかりません"
            assertionFailure(msg)
            loadError = loadError ?? msg
            return
        }
        do {
            glossary = try JSONDecoder().decode([GlossaryEntry].self, from: data)
                .sorted { $0.term < $1.term }
        } catch {
            let msg = "glossary.json のパースに失敗: \(error)"
            assertionFailure(msg)
            loadError = loadError ?? msg
        }
    }

    private func loadJSONData(fileName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    // MARK: - コース参照

    /// 全コースを表示順で返す。
    func getAllCourses() -> [CourseIndex] {
        courseIndexes
    }

    /// IDでコースを取得する。
    func getCourse(id: String) -> CourseIndex? {
        courseIndexes.first { $0.id == id }
    }

    // MARK: - レッスン参照

    /// コースに含まれるレッスン一覧を表示順で返す（キャッシュ済み）。
    func getLessons(courseId: String) -> [LessonData] {
        sortedLessonsCache[courseId] ?? []
    }

    /// IDでレッスンを取得する。
    func getLesson(id: String) -> LessonData? {
        lessonsIndex[id]
    }

    /// レッスンの次のレッスンIDを返す。最終レッスンの場合は nil。
    func getNextLessonId(after lessonId: String) -> String? {
        guard let lesson = lessonsIndex[lessonId] else { return nil }
        let sorted = getLessons(courseId: lesson.courseId)
        guard let index = sorted.firstIndex(where: { $0.id == lessonId }),
              index + 1 < sorted.count else { return nil }
        return sorted[index + 1].id
    }

    /// 現在のレッスンが属するコースの最終レッスンだった場合、
    /// 次のコースの最初のレッスンIDを返す。それ以外は nil。
    func getNextCourseFirstLessonId(after lessonId: String) -> String? {
        guard let next = nextCourse(after: lessonId) else { return nil }
        return getLessons(courseId: next.id).first?.id
    }

    /// レッスンIDから、そのレッスンが属するコースの次のコースタイトルを返す。
    func getNextCourseTitle(after lessonId: String) -> String? {
        nextCourse(after: lessonId)?.title
    }

    /// 次のコースを取得する共通ヘルパー。
    /// 同一コース内に次レッスンがある場合は nil を返す。
    private func nextCourse(after lessonId: String) -> CourseIndex? {
        // 同一コース内に次レッスンがあれば nil（getNextLessonId 側で処理）
        guard getNextLessonId(after: lessonId) == nil else { return nil }
        guard let lesson = lessonsIndex[lessonId],
              let currentCourse = courseIndexes.first(where: { $0.id == lesson.courseId }) else { return nil }
        // order が次に大きいコースを探す
        return courseIndexes
            .filter { $0.order > currentCourse.order }
            .min { $0.order < $1.order }
    }

    // MARK: - クイズ参照

    /// レッスンに含まれるクイズ一覧を返す。
    func getQuizzes(lessonId: String) -> [QuizData] {
        lessonsIndex[lessonId]?.quizzes ?? []
    }

    /// IDでクイズを取得する。
    func getQuiz(id: String) -> QuizData? {
        quizzesIndex[id]
    }

    /// 全クイズIDの一覧を返す。
    func getAllQuizIds() -> [String] {
        Array(quizzesIndex.keys)
    }

    /// 指定クイズタイプに属するクイズIDのセットを返す（キャッシュ済み）。
    func getQuizIds(byType typeRaw: String) -> Set<String> {
        if isQuizTypeCacheDirty {
            // キャッシュが無効化されている場合に再構築
            quizIdsByTypeCache.removeAll()
            for (id, quiz) in quizzesIndex {
                quizIdsByTypeCache[quiz.type.rawValue, default: []].insert(id)
            }
            isQuizTypeCacheDirty = false
        }
        return quizIdsByTypeCache[typeRaw] ?? []
    }

    // MARK: - 辞典参照

    /// 辞典全件を返す。
    func getAllGlossary() -> [GlossaryEntry] {
        glossary
    }

    /// 用語名で辞典エントリを完全一致検索する（[[用語]] リンク解決用）。
    func getGlossaryEntry(term: String) -> GlossaryEntry? {
        glossary.first { $0.term == term }
    }

    /// キーワードで辞典を検索する（部分一致）。
    func searchGlossary(query: String) -> [GlossaryEntry] {
        guard !query.isEmpty else { return glossary }
        let q = query.lowercased()
        return glossary.filter {
            $0.term.lowercased().contains(q) ||
            $0.reading.lowercased().contains(q) ||
            $0.definition.lowercased().contains(q)
        }
    }

    // MARK: - 統計

    /// 全レッスン数を返す。
    /// チャプターが未ロードでもコースインデックスのメタデータから正確な値を返す。
    var totalLessonCount: Int {
        if isLoaded {
            return lessonsIndex.count
        }
        // チャプター未ロード時はコースインデックスの lessonCount 合計を使用
        return courseIndexes.reduce(0) { $0 + $1.lessonCount }
    }

    /// 全クイズ数を返す。
    var totalQuizCount: Int {
        quizzesIndex.count
    }
}
