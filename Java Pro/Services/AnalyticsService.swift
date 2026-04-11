//
//  AnalyticsService.swift
//  Java Pro
//
//  学習分析サービス。弱点分野分析・週間学習データ・資格進捗を提供する。
//  WeakPointView, CertificationView, ProfileView 等で利用される。
//

import Foundation
import SwiftData

/// 弱点トピック情報。
struct WeakTopic: Identifiable {
    let id: String      // courseId
    let title: String
    let correctRate: Double
    let totalAttempts: Int
    let incorrectCount: Int
}

/// 日別学習データ。
struct DayStudyData: Identifiable {
    let id: String      // dateString
    let date: Date
    let lessonsCompleted: Int
    let quizzesCompleted: Int
    let xpEarned: Int
    let minutesStudied: Int
}

/// 資格進捗情報。
struct CertProgress {
    let certLevel: CertificationLevel
    let totalLessons: Int
    let completedLessons: Int
    let totalQuizzes: Int
    let correctQuizzes: Int
    let topicProgress: [(topic: String, completed: Int, total: Int)]
    let examPassed: Bool
    let bestExamScore: Double?
}

/// 学習分析サービス。
@MainActor
@Observable
final class AnalyticsService {
    private let modelContext: ModelContext

    // #Predicate に渡すためのステータス文字列定数（マジックストリング排除）
    private let completedRaw = LessonStatus.completed.rawValue

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - 弱点分析

    /// 正答率が低いコースを弱点トピックとして返す。
    func weakTopics(certLevel: CertificationLevel? = nil, limit: Int = 5) -> [WeakTopic] {
        let courses = ContentService.shared.getAllCourses()
        let filteredCourses: [CourseIndex]
        if let certLevel {
            filteredCourses = courses.filter { $0.certificationLevel == certLevel }
        } else {
            filteredCourses = courses
        }

        // 全クイズ履歴を一括取得（直近90日分に制限し長期利用時のメモリ負荷を低減）
        let allHistories: [UserQuizHistory] = {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
            let descriptor = FetchDescriptor<UserQuizHistory>(
                predicate: #Predicate { $0.answeredAt >= cutoffDate },
                sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
            )
            return modelContext.fetchLogged(descriptor)
        }()

        // quizId -> 最新の履歴マップ
        var latestByQuiz: [String: UserQuizHistory] = [:]
        for h in allHistories {
            if let existing = latestByQuiz[h.quizId] {
                if h.answeredAt > existing.answeredAt {
                    latestByQuiz[h.quizId] = h
                }
            } else {
                latestByQuiz[h.quizId] = h
            }
        }

        var topics: [WeakTopic] = []

        for course in filteredCourses {
            let lessons = ContentService.shared.getLessons(courseId: course.id)
            var totalAttempts = 0
            var correctCount = 0

            for lesson in lessons {
                for quiz in lesson.quizzes {
                    if let h = latestByQuiz[quiz.id] {
                        totalAttempts += 1
                        if h.isCorrect { correctCount += 1 }
                    }
                }
            }

            guard totalAttempts > 0 else { continue }

            let rate = Double(correctCount) / Double(totalAttempts)
            topics.append(WeakTopic(
                id: course.id,
                title: course.title,
                correctRate: rate,
                totalAttempts: totalAttempts,
                incorrectCount: totalAttempts - correctCount
            ))
        }

        return topics
            .filter { $0.correctRate < 0.8 }  // 80%未満を弱点とする
            .sorted { $0.correctRate < $1.correctRate }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - 週間学習データ

    /// 直近7日間の学習データを返す。
    func weeklyStudyData() -> [DayStudyData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 7日前の日付文字列を算出
        guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) else { return [] }
        let weekAgoStr = weekAgo.dateString

        // 7日分のレコードを1回のクエリで取得（N+1解消）
        let descriptor = FetchDescriptor<UserDailyRecord>(
            predicate: #Predicate { $0.dateString >= weekAgoStr }
        )
        let records = modelContext.fetchLogged(descriptor)
        let recordMap = Dictionary(uniqueKeysWithValues: records.map { ($0.dateString, $0) })

        var data: [DayStudyData] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dateStr = date.dateString
            let record = recordMap[dateStr]

            let seconds = record?.studySeconds ?? 0
            let minutesFromSeconds = seconds / 60
            // studySeconds 未計測のレガシーレコード用フォールバック
            let estimatedMinutes = (record?.completedLessons ?? 0) * 5 + (record?.completedQuizzes ?? 0) * 2

            data.append(DayStudyData(
                id: dateStr,
                date: date,
                lessonsCompleted: record?.completedLessons ?? 0,
                quizzesCompleted: record?.completedQuizzes ?? 0,
                xpEarned: record?.earnedXP ?? 0,
                minutesStudied: seconds > 0 ? minutesFromSeconds : estimatedMinutes
            ))
        }

        return data
    }

    // MARK: - 資格進捗

    /// 指定資格レベルの全体進捗を算出する。
    /// Silver: beginner + silver のコースを集計（Silver試験は入門範囲も出題対象）
    /// Gold: beginner + silver + gold のコースを集計（Gold試験は全範囲が出題対象）
    func certificationProgress(level: CertificationLevel) -> CertProgress {
        let allCourses = ContentService.shared.getAllCourses()
        let courses: [CourseIndex]
        switch level {
        case .silver:
            courses = allCourses.filter { $0.certificationLevel == .beginner || $0.certificationLevel == .silver }
        case .gold:
            courses = allCourses.filter { $0.certificationLevel == .beginner || $0.certificationLevel == .silver || $0.certificationLevel == .gold }
        case .beginner:
            courses = allCourses.filter { $0.certificationLevel == .beginner }
        }

        var totalLessons = 0
        var completedLessons = 0
        var totalQuizzes = 0
        var correctQuizzes = 0
        var topicProgress: [(topic: String, completed: Int, total: Int)] = []

        // 完了レッスンIDを一括取得
        let status = completedRaw
        let completedDescriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status }
        )
        let completedIds = Set(modelContext.fetchLogged(completedDescriptor).map(\.lessonId))

        // 正解クイズIDを一括取得（最新回答のみで判定 — 過去の正解が最新不正解を隠さないようにする）
        // 直近90日分に制限し長期利用時のメモリ負荷を低減（weakTopics と同様）
        let quizCutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let quizHistoryDescriptor = FetchDescriptor<UserQuizHistory>(
            predicate: #Predicate { $0.answeredAt >= quizCutoffDate },
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        )
        let allQuizHistories = modelContext.fetchLogged(quizHistoryDescriptor)
        var latestByQuiz: [String: UserQuizHistory] = [:]
        for history in allQuizHistories {
            if let existing = latestByQuiz[history.quizId] {
                if history.answeredAt > existing.answeredAt {
                    latestByQuiz[history.quizId] = history
                }
            } else {
                latestByQuiz[history.quizId] = history
            }
        }
        let correctQuizIds = Set(latestByQuiz.values.filter { $0.isCorrect }.map { $0.quizId })

        for course in courses {
            let lessons = ContentService.shared.getLessons(courseId: course.id)
            let courseLessonCount = lessons.count
            let courseCompletedCount = lessons.filter { completedIds.contains($0.id) }.count

            totalLessons += courseLessonCount
            completedLessons += courseCompletedCount

            for lesson in lessons {
                totalQuizzes += lesson.quizzes.count
                correctQuizzes += lesson.quizzes.filter { correctQuizIds.contains($0.id) }.count
            }

            topicProgress.append((
                topic: course.title,
                completed: courseCompletedCount,
                total: courseLessonCount
            ))
        }

        // 模擬試験合格チェック
        // exam ID は "se11_silver_1" のような形式のため contains でマッチ
        guard level == .silver || level == .gold else {
            return CertProgress(
                certLevel: level,
                totalLessons: totalLessons,
                completedLessons: completedLessons,
                totalQuizzes: totalQuizzes,
                correctQuizzes: correctQuizzes,
                topicProgress: topicProgress,
                examPassed: false,
                bestExamScore: nil
            )
        }
        let prefix = level == .silver ? "silver" : "gold"
        let examDescriptor = FetchDescriptor<UserExamResult>(
            predicate: #Predicate { result in
                result.passed && result.examChapterId.contains(prefix)
            }
        )
        let examPassed = modelContext.fetchCountLogged(examDescriptor) > 0

        // 最高スコア
        let bestDescriptor = FetchDescriptor<UserExamResult>(
            predicate: #Predicate { result in
                result.examChapterId.contains(prefix)
            },
            sortBy: [SortDescriptor(\.score, order: .reverse)]
        )
        let bestResult = modelContext.fetchFirstLogged(bestDescriptor)
        let bestScore = bestResult.map { Double($0.score) / Double(max($0.totalQuestions, 1)) }

        return CertProgress(
            certLevel: level,
            totalLessons: totalLessons,
            completedLessons: completedLessons,
            totalQuizzes: totalQuizzes,
            correctQuizzes: correctQuizzes,
            topicProgress: topicProgress,
            examPassed: examPassed,
            bestExamScore: bestScore
        )
    }

    // MARK: - 全体統計

    /// 総学習時間（実測秒数ベース、分単位）。
    func totalStudyMinutes() -> Int {
        let descriptor = FetchDescriptor<UserDailyRecord>()
        let records = modelContext.fetchLogged(descriptor)
        let totalSeconds = records.reduce(0) { $0 + $1.studySeconds }
        return totalSeconds / 60
    }
}
