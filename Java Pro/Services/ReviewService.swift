//
//  ReviewService.swift
//  Java Pro
//
//  忘却曲線ベースの復習スケジュールを計算するサービス。
//  復習間隔: 誤答直後 → 24時間 → 3日 → 7日 の4段階。
//  正答で次段階に進み、誤答でリセットする。
//

import Foundation
import SwiftData

/// 復習対象クイズの判定と復習キューの提供を担当するサービス。
@MainActor
@Observable
final class ReviewService {
    private let modelContext: ModelContext
    private let contentService: ContentService

    init(modelContext: ModelContext, contentService: ContentService? = nil) {
        self.modelContext = modelContext
        self.contentService = contentService ?? ContentService.shared
    }

    // MARK: - 復習間隔定義

    /// 各ステージの復習間隔（秒）。
    private static let intervalSeconds: [TimeInterval] = [
        0,              // Stage 0: 即時（誤答直後）
        24 * 3600,      // Stage 1: 24時間後
        3 * 24 * 3600,  // Stage 2: 3日後
        7 * 24 * 3600,  // Stage 3: 7日後
    ]

    /// Stage 4 以上は復習完了とみなす。
    private static let completedStage = 4

    // MARK: - 復習キュー取得

    /// 今日復習すべきクイズの一覧を返す。
    func getReviewQueue(using cachedBatch: [String: UserQuizHistory]? = nil) -> [QuizData] {
        let now = Date()
        // 全クイズ履歴をバッチ取得し、quizId別に最新を抽出
        let latestByQuiz = cachedBatch ?? batchLatestHistories()

        var reviewQuizIds: Set<String> = []
        for (quizId, history) in latestByQuiz {
            if shouldReviewWithHistory(history, at: now) {
                reviewQuizIds.insert(quizId)
            }
        }

        // QuizData に変換して返す
        return reviewQuizIds.compactMap { contentService.getQuiz(id: $0) }
    }

    /// 今日の復習件数を返す（QuizData のマテリアライズを省略して高速化）。
    func reviewCount() -> Int {
        let now = Date()
        let latestByQuiz = batchLatestHistories()
        var count = 0
        for (_, history) in latestByQuiz {
            if shouldReviewWithHistory(history, at: now) {
                count += 1
            }
        }
        return count
    }

    /// 指定クイズが復習の対象かどうかを判定する。
    func shouldReview(quizId: String, at date: Date = Date()) -> Bool {
        guard let history = latestHistory(quizId: quizId) else {
            return false
        }
        return shouldReviewWithHistory(history, at: date)
    }

    /// 履歴レコードから復習対象かを判定する（内部共通ロジック）。
    private func shouldReviewWithHistory(_ history: UserQuizHistory, at date: Date) -> Bool {
        // 復習完了（Stage 4以上）なら対象外
        if history.intervalStage >= Self.completedStage {
            return false
        }
        // 誤答で Stage 0 にリセットされた場合は即時復習
        if !history.isCorrect {
            return true
        }
        // 正答の場合、次の復習時刻を過ぎているか確認
        let stage = history.intervalStage
        guard stage < Self.intervalSeconds.count else { return false }
        let interval = Self.intervalSeconds[stage]
        let nextReviewDate = history.answeredAt.addingTimeInterval(interval)
        return date >= nextReviewDate
    }

    // MARK: - 苦手テーマ分析

    /// 正答率が低いカテゴリ（コースID）を返す。
    func weakCourseIds(limit: Int = 3, using cachedBatch: [String: UserQuizHistory]? = nil) -> [String] {
        // 全クイズの最新履歴をバッチ取得
        let latestByQuiz = cachedBatch ?? batchLatestHistories()
        var courseCorrectRates: [(String, Double)] = []

        for course in contentService.getAllCourses() {
            let lessons = contentService.getLessons(courseId: course.id)
            var total = 0
            var correct = 0

            for lesson in lessons {
                for quiz in lesson.quizzes {
                    if let history = latestByQuiz[quiz.id] {
                        total += 1
                        if history.isCorrect { correct += 1 }
                    }
                }
            }

            if total > 0 {
                courseCorrectRates.append((course.id, Double(correct) / Double(total)))
            }
        }

        return courseCorrectRates
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map(\.0)
    }

    // MARK: - Private

    /// 全クイズ履歴を1回のクエリで取得し、quizId別に最新レコードを返す。
    /// パフォーマンス対策: 直近90日分の履歴のみ取得し、長期利用ユーザーでの大量データロードを防止。
    private func batchLatestHistories() -> [String: UserQuizHistory] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<UserQuizHistory>(
            predicate: #Predicate { $0.answeredAt >= cutoffDate },
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        )
        let allHistories = modelContext.fetchLogged(descriptor)
        var latest: [String: UserQuizHistory] = [:]
        for history in allHistories {
            if latest[history.quizId] == nil {
                latest[history.quizId] = history
            }
        }
        return latest
    }

    private func latestHistory(quizId: String) -> UserQuizHistory? {
        var descriptor = FetchDescriptor<UserQuizHistory>(
            predicate: #Predicate { $0.quizId == quizId },
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return modelContext.fetchFirstLogged(descriptor)
    }

    /// ReviewView など外部から最新回答を参照するための公開API。
    func latestHistoryPublic(quizId: String) -> UserQuizHistory? {
        latestHistory(quizId: quizId)
    }

    /// 全クイズの最新回答履歴を一括取得する（N+1 クエリ回避用）。
    /// - Returns: quizId → 最新の UserQuizHistory の辞書
    func allLatestHistories() -> [String: UserQuizHistory] {
        batchLatestHistories()
    }
}
