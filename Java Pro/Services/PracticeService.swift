//
//  PracticeService.swift
//  Java Pro
//
//  実践演習データの読み込み・管理を担当するシングルトンサービス。
//  practice_exercises.json からデータを読み込み、キャッシュして提供する。
//

import Foundation

/// 実践演習コンテンツの読み込み・検索を担当するサービス。
@MainActor
@Observable
final class PracticeService {
    static let shared = PracticeService()

    // MARK: - キャッシュ

    private(set) var setupGuide: [SetupGuideSection] = []
    private(set) var practiceChapters: [PracticeChapter] = []
    private(set) var isLoaded = false
    private(set) var loadError: String?

    /// exerciseId → PracticeExercise の辞書キャッシュ
    private var exerciseIndex: [String: PracticeExercise] = [:]

    private init() {}

    // MARK: - ロード

    /// バンドル内の practice_exercises.json を読み込む。
    func loadPracticeData() {
        guard !isLoaded else { return }

        guard let url = Bundle.main.url(forResource: "practice_exercises", withExtension: "json") else {
            let msg = "practice_exercises.json が見つかりません"
            assertionFailure(msg)
            loadError = msg
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let practiceData = try JSONDecoder().decode(PracticeData.self, from: data)

            setupGuide = practiceData.setupGuide
            practiceChapters = practiceData.chapters

            // インデックス構築
            for chapter in practiceChapters {
                for exercise in chapter.exercises {
                    exerciseIndex[exercise.id] = exercise
                }
            }

            isLoaded = true
        } catch {
            let msg = "practice_exercises.json のパースに失敗: \(error)"
            assertionFailure(msg)
            loadError = msg
        }
    }

    // MARK: - 検索

    /// 全チャプターを返す。
    func getAllChapters() -> [PracticeChapter] {
        practiceChapters
    }

    /// レベルでフィルタリングしたチャプターを返す。
    func getChapters(for level: CertificationLevel) -> [PracticeChapter] {
        practiceChapters.filter { $0.certificationLevel == level }
    }

    /// IDで演習を取得する。
    func getExercise(id: String) -> PracticeExercise? {
        exerciseIndex[id]
    }

    /// チャプターIDで演習一覧を取得する。
    func getExercises(forChapter chapterId: String) -> [PracticeExercise] {
        practiceChapters.first { $0.id == chapterId }?.exercises ?? []
    }

    /// レッスンIDに関連する演習を返す。
    func getExercises(forRelatedLesson lessonId: String) -> [PracticeExercise] {
        practiceChapters
            .flatMap(\.exercises)
            .filter { $0.relatedLessonId == lessonId }
    }

    /// 演習IDを含むチャプターを返す。
    func getChapter(containingExercise exerciseId: String) -> PracticeChapter? {
        practiceChapters.first { chapter in
            chapter.exercises.contains { $0.id == exerciseId }
        }
    }

    /// コースIDに関連するチャプター（演習あり）を返す。
    func getChapters(forCourseId courseId: String) -> [PracticeChapter] {
        practiceChapters.filter { $0.id == courseId }
    }

    // MARK: - .java ファイル生成

    /// 演習のソリューションコードから一時 .java ファイルURLを生成する。
    func generateJavaFileURL(for exercise: PracticeExercise) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(exercise.solutionFileName)
        do {
            try exercise.solutionCode.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}
