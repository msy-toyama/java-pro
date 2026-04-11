//
//  ProgressService.swift
//  Java Pro
//
//  SwiftData を介してユーザーの学習進捗を管理するサービス。
//  View 層から直接 ModelContext を操作させず、本サービスを経由させることで
//  責務分離と将来のAPI化への移行を容易にする。
//

import Foundation
import SwiftData
import os

/// ユーザーの学習進捗を一元管理するサービス。
@MainActor
@Observable
final class ProgressService {
    private let modelContext: ModelContext

    // #Predicate に渡すためのステータス文字列定数（マジックストリング排除）
    private let completedRaw = LessonStatus.completed.rawValue
    private let inProgressRaw = LessonStatus.inProgress.rawValue

    /// ストリークキャッシュ（同一日内の重複計算を排除）
    private var cachedStreak: Int?
    private var streakCacheDate: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - AppSettings

    /// アプリ設定を取得（なければ作成）。
    func getSettings() -> AppSettings {
        let descriptor = FetchDescriptor<AppSettings>()
        if let existing = modelContext.fetchFirstLogged(descriptor) {
            return existing
        }
        let settings = AppSettings()
        modelContext.insert(settings)
        saveContext()
        return settings
    }

    /// オンボーディング完了を記録する。
    func completeOnboarding() {
        let settings = getSettings()
        settings.hasCompletedOnboarding = true
        saveContext()
    }

    // MARK: - レッスン進捗

    /// レッスンの進捗を取得する。未着手ならnil。
    func getLessonProgress(lessonId: String) -> UserLessonProgress? {
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.lessonId == lessonId }
        )
        return modelContext.fetchFirstLogged(descriptor)
    }

    /// レッスン学習を開始にする。完了済みレッスンのステータスは変更しない。
    func startLesson(lessonId: String) {
        if let existing = getLessonProgress(lessonId: lessonId) {
            if existing.status == .notStarted {
                existing.status = .inProgress
                existing.startedAt = Date()
            }
            // .completed や .inProgress の場合はステータスを変更しない
        } else {
            let progress = UserLessonProgress(lessonId: lessonId, status: .inProgress)
            progress.startedAt = Date()
            modelContext.insert(progress)
        }
        recordDailyActivity()
        saveContext()
    }

    /// レッスンを完了にする。
    func completeLesson(lessonId: String) {
        if let existing = getLessonProgress(lessonId: lessonId) {
            let wasAlreadyCompleted = existing.status == .completed
            existing.status = .completed
            existing.completedAt = Date()
            // 初回完了時のみ日次カウントをインクリメント（無限XP増殖防止）
            if !wasAlreadyCompleted {
                incrementDailyLessonCount()
            }
        } else {
            let progress = UserLessonProgress(lessonId: lessonId, status: .completed)
            progress.startedAt = Date()
            progress.completedAt = Date()
            modelContext.insert(progress)
            incrementDailyLessonCount()
        }
        saveContext()
    }

    /// コース内の完了レッスン数を返す。
    func completedLessonCount(courseId: String) -> Int {
        let lessons = ContentService.shared.getLessons(courseId: courseId)
        let lessonIds = Set(lessons.map(\.id))
        // バッチフェッチ: 完了済みの全レッスン進捗を1回のクエリで取得
        let status = completedRaw
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status }
        )
        let allCompleted = modelContext.fetchLogged(descriptor)
        return allCompleted.filter { lessonIds.contains($0.lessonId) }.count
    }

    /// 全レッスンの進捗ステータスマップを返す（バッチ取得用、N+1防止）。
    func allLessonProgressMap() -> [String: LessonStatus] {
        let descriptor = FetchDescriptor<UserLessonProgress>()
        let all = modelContext.fetchLogged(descriptor)
        var map: [String: LessonStatus] = [:]
        for progress in all {
            map[progress.lessonId] = progress.status
        }
        return map
    }

    /// 全完了レッスンIDのセットを返す（バッチ取得用）。
    func allCompletedLessonIds() -> Set<String> {
        let status = completedRaw
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status }
        )
        return Set(modelContext.fetchLogged(descriptor).map(\.lessonId))
    }

    /// 全体の完了レッスン数を返す。
    func totalCompletedLessonCount() -> Int {
        let status = completedRaw
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status }
        )
        return modelContext.fetchCountLogged(descriptor)
    }

    /// 累計の正解クイズ数を返す。
    func totalCorrectQuizCount() -> Int {
        let descriptor = FetchDescriptor<UserQuizHistory>(
            predicate: #Predicate { $0.isCorrect == true }
        )
        return modelContext.fetchCountLogged(descriptor)
    }

    /// 全問正解セッション（パーフェクト）の累計回数を返す。
    /// 「レッスン完了時に correctCount == quizzes.count」の回数を
    /// UserDailyRecord や XPRecord の "quiz_perfect" 理由から推定する。
    func totalPerfectCount() -> Int {
        let descriptor = FetchDescriptor<UserXPRecord>(
            predicate: #Predicate { $0.reason == "quiz_perfect" }
        )
        return modelContext.fetchCountLogged(descriptor)
    }

    /// ユーザーが最後に取り組んでいたレッスンIDを返す。
    func lastInProgressLessonId() -> String? {
        let status = inProgressRaw
        var descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return modelContext.fetchFirstLogged(descriptor)?.lessonId
    }

    /// 次に学習すべきレッスンIDを推薦する。
    func recommendedNextLessonId() -> String? {
        // 1. 進行中のレッスンがあればそれを返す
        if let inProgress = lastInProgressLessonId() {
            return inProgress
        }
        // 2. 完了済みレッスンIDをバッチ取得
        let status = completedRaw
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status }
        )
        let completedIds = Set(modelContext.fetchLogged(descriptor).map(\.lessonId))

        // 3. コースを順に見て、最初の未完了レッスンを返す
        let courses = ContentService.shared.getAllCourses()
        for course in courses {
            let lessons = ContentService.shared.getLessons(courseId: course.id)
            for lesson in lessons {
                if !completedIds.contains(lesson.id) {
                    return lesson.id
                }
            }
        }
        return nil
    }

    // MARK: - クイズ履歴

    /// クイズの回答を記録する。
    func recordQuizAnswer(quizId: String, isCorrect: Bool) {
        // 直近の履歴から streak と intervalStage を1回のクエリで取得（TOCTOU 防止）
        let previous = latestQuizHistory(quizId: quizId)
        let previousStreak = previous?.streakCount ?? 0
        let previousStage = previous?.intervalStage ?? 0
        let newStreak = isCorrect ? previousStreak + 1 : 0

        // intervalStage の更新
        let newStage: Int
        if isCorrect {
            newStage = min(previousStage + 1, 4) // max 4 (完了)
        } else {
            newStage = 0 // 誤答でリセット
        }

        let history = UserQuizHistory(
            quizId: quizId,
            isCorrect: isCorrect,
            streakCount: newStreak,
            intervalStage: newStage
        )
        modelContext.insert(history)
        incrementDailyQuizCount()
        saveContext()
    }

    /// クイズの最新回答を取得する。
    func latestQuizHistory(quizId: String) -> UserQuizHistory? {
        var descriptor = FetchDescriptor<UserQuizHistory>(
            predicate: #Predicate { $0.quizId == quizId },
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return modelContext.fetchFirstLogged(descriptor)
    }

    /// クイズの連続正解数を返す。
    private func latestStreakCount(quizId: String) -> Int {
        latestQuizHistory(quizId: quizId)?.streakCount ?? 0
    }

    /// クイズの最新 intervalStage を返す。
    private func latestIntervalStage(quizId: String) -> Int {
        latestQuizHistory(quizId: quizId)?.intervalStage ?? 0
    }

    // MARK: - 連続日数

    /// 今日の学習記録を取得（なければ作成）。
    /// 内部利用のため save は呼び出元に委譲する。
    private func getTodayRecord() -> UserDailyRecord {
        let today = Date().dateString
        let descriptor = FetchDescriptor<UserDailyRecord>(
            predicate: #Predicate { $0.dateString == today }
        )
        if let existing = modelContext.fetchFirstLogged(descriptor) {
            return existing
        }
        let record = UserDailyRecord(dateString: today)
        modelContext.insert(record)
        return record
    }

    /// 日次のアクティビティを記録する。
    private func recordDailyActivity() {
        _ = getTodayRecord()
        // 新しい日次レコードが作られるとストリークが変わる可能性がある
        invalidateStreakCache()
    }

    /// レッスン完了数をインクリメント。保存は呼び出し元に委譲。
    private func incrementDailyLessonCount() {
        let record = getTodayRecord()
        record.completedLessons += 1
    }

    /// クイズ回答数をインクリメント。保存は呼び出し元に委譲。
    private func incrementDailyQuizCount() {
        let record = getTodayRecord()
        record.completedQuizzes += 1
    }

    /// フォアグラウンド経過秒数を加算する。
    func addStudySeconds(_ seconds: Int) {
        let record = getTodayRecord()
        record.studySeconds += seconds
        invalidateStreakCache()
        saveContext()
    }

    /// 現在の連続学習日数を返す（日付ベースのキャッシュ付き）。
    func currentStreak() -> Int {
        let today = Date().dateString
        // 同一日内はキャッシュを返す（レッスン完了でストリークが変わる可能性を考慮し invalidate 口も用意）
        if let cached = cachedStreak, streakCacheDate == today {
            return cached
        }

        let result = computeStreak()
        cachedStreak = result
        streakCacheDate = today
        return result
    }

    /// ストリークキャッシュを無効化する（日次レコード生成後に呼ぶ）。
    func invalidateStreakCache() {
        cachedStreak = nil
        streakCacheDate = nil
    }

    /// 実際のストリーク計算（重い処理）。
    private func computeStreak() -> Int {
        // 最大365日分のストリークしかチェックしないので、400日前以降のレコードだけ取得
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -400, to: calendar.startOfDay(for: Date())) else { return 0 }
        let cutoffStr = cutoffDate.dateString
        let descriptor = FetchDescriptor<UserDailyRecord>(
            predicate: #Predicate { $0.dateString >= cutoffStr },
            sortBy: [SortDescriptor(\.dateString, order: .reverse)]
        )
        let records = modelContext.fetchLogged(descriptor)
        guard !records.isEmpty else {
            return 0
        }

        // Set に変換して O(1) ルックアップ（O(n*m) → O(n)）
        let dateSet = Set(records.map(\.dateString))

        var streak = 0
        // DST対策: startOfDay を基準にし、暦日のみで比較する
        var checkDate = Calendar.current.startOfDay(for: Date())

        // 今日のレコードがなければ昨日から逆算
        if !dateSet.contains(checkDate.dateString) {
            checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        for _ in 0..<365 {
            let dateStr = checkDate.dateString
            if dateSet.contains(dateStr) {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        return streak
    }

    /// 今日の学習統計を返す（読み取り専用 — レコードを生成しない）。
    func todayStats() -> TodayStats {
        let today = Date().dateString
        let descriptor = FetchDescriptor<UserDailyRecord>(
            predicate: #Predicate { $0.dateString == today }
        )
        let record = modelContext.fetchFirstLogged(descriptor)
        return TodayStats(
            completedLessons: record?.completedLessons ?? 0,
            completedQuizzes: record?.completedQuizzes ?? 0,
            streak: currentStreak(),
            earnedXP: record?.earnedXP ?? 0,
            studyMinutes: (record?.studySeconds ?? 0) / 60
        )
    }

    // MARK: - 保存

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            AppLogger.swiftData.error("ProgressService 保存エラー: \(error.localizedDescription)")
            SaveErrorNotifier.shared.report(error)
        }
    }
}
