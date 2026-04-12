//
//  GamificationService.swift
//  Java Pro
//
//  XP・レベル・バッジの管理を担当するサービス。
//  学習アクションに対してXPを付与し、レベルアップとバッジ獲得を判定する。
//

import Foundation
import SwiftData
import os

/// ゲーミフィケーション（XP・レベル・バッジ）を一元管理するサービス。
@MainActor
@Observable
final class GamificationService {
    private let modelContext: ModelContext

    // #Predicate に渡すためのステータス文字列定数（マジックストリング排除）
    private let completedRaw = LessonStatus.completed.rawValue

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - XP 定数

    enum XPAmount {
        static let lessonComplete    = 20
        static let quizCorrect       = 10
        static let quizPerfect       = 20  // ボーナス（全問正解時に加算）
        static let reviewCorrect     = 15
        static let streakBonusPerDay = 5   // streak日数 × 5
        static let firstTryCorrect   = 5   // 初見正解ボーナス
    }

    // MARK: - レベルテーブル（Lv1〜50）

    /// 各レベルに必要な累計XP。
    static let levelThresholds: [Int] = {
        var thresholds: [Int] = [0] // Lv1 = 0
        for lv in 2...50 {
            // 緩やかな二次曲線: Lv50 = 30,000 XP
            // 全コンテンツ初回完了(~9,660 XP) → Lv22
            // +全模試合格(+4,000 XP) → Lv26
            // +ストリーク/復習 → Lv30+
            let xp = Int(Double(lv * lv) * 12.24)
            thresholds.append(xp)
        }
        return thresholds
    }()

    /// レベルごとの称号キー（ローカライズキーを格納し、表示時に解決する）。
    static let levelTitles: [Int: String] = [
        1: "level.title.1",
        3: "level.title.3",
        5: "level.title.5",
        8: "level.title.8",
        10: "level.title.10",
        13: "level.title.13",
        15: "level.title.15",
        18: "level.title.18",
        20: "level.title.20",
        23: "level.title.23",
        25: "level.title.25",
        28: "level.title.28",
        30: "level.title.30",
        33: "level.title.33",
        35: "level.title.35",
        38: "level.title.38",
        40: "level.title.40",
        43: "level.title.43",
        45: "level.title.45",
        48: "level.title.48",
        50: "level.title.50",
    ]

    // MARK: - XP 付与

    /// XPを付与し、レベルアップを判定する。レベルアップした場合は新レベルを返す。
    @discardableResult
    func awardXP(amount: Int, reason: String, relatedId: String? = nil) -> Int? {
        // XP レコード保存
        let record = UserXPRecord(amount: amount, reason: reason, relatedId: relatedId)
        modelContext.insert(record)

        // 日次記録にも加算
        addToDailyXP(amount: amount)

        // レベル更新
        let userLevel = getOrCreateUserLevel()
        let oldLevel = userLevel.level
        userLevel.totalXP += amount

        // レベルアップ判定
        let newLevel = Self.calculateLevel(totalXP: userLevel.totalXP)
        if newLevel > oldLevel {
            userLevel.level = newLevel
            userLevel.lastLevelUpAt = Date()
            saveContext()
            return newLevel
        }

        saveContext()
        return nil
    }

    /// レッスン完了時のXP付与。
    @discardableResult
    func awardLessonCompleteXP(lessonId: String) -> Int? {
        awardXP(amount: XPAmount.lessonComplete, reason: "lesson_complete", relatedId: lessonId)
    }

    /// クイズ正解時のXP付与。
    @discardableResult
    func awardQuizCorrectXP(quizId: String) -> Int? {
        awardXP(amount: XPAmount.quizCorrect, reason: "quiz_correct", relatedId: quizId)
    }

    /// 全問正解ボーナスXP付与。
    @discardableResult
    func awardPerfectBonusXP(lessonId: String) -> Int? {
        awardXP(amount: XPAmount.quizPerfect, reason: "quiz_perfect", relatedId: lessonId)
    }

    /// ストリークボーナスXP付与。
    @discardableResult
    func awardStreakBonusXP(streakDays: Int) -> Int? {
        let amount = XPAmount.streakBonusPerDay * streakDays
        return awardXP(amount: amount, reason: "streak_bonus")
    }

    /// 今日まだストリークボーナスが未付与なら付与する。
    /// クイズセッション完了時に1回だけ呼ばれる。
    /// - Returns: 付与したXP量。既に付与済みまたはストリーク0の場合はnil。
    @discardableResult
    func awardStreakBonusIfNeeded(streakDays: Int) -> Int? {
        guard streakDays > 0 else { return nil }

        // 今日既に streak_bonus が付与されているか確認
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<UserXPRecord>(
            predicate: #Predicate { record in
                record.reason == "streak_bonus" && record.earnedAt >= startOfDay
            }
        )
        let alreadyAwarded = modelContext.fetchCountLogged(descriptor) > 0
        guard !alreadyAwarded else { return nil }

        return awardStreakBonusXP(streakDays: streakDays)
    }

    // MARK: - レベル参照

    /// 現在のユーザーレベル情報を取得する。
    func getUserLevel() -> UserLevel {
        getOrCreateUserLevel()
    }

    /// 累計XPからレベルを算出する。
    static func calculateLevel(totalXP: Int) -> Int {
        var level = 1
        for (lv, threshold) in levelThresholds.enumerated() {
            if totalXP >= threshold {
                level = lv + 1
            } else {
                break
            }
        }
        return min(level, 50)
    }

    /// 次のレベルまでの進捗率（0.0〜1.0）。
    func progressToNextLevel() -> Double {
        let userLevel = getOrCreateUserLevel()
        guard userLevel.level < 50 else { return 1.0 }  // 最大レベルは満タン表示
        let currentThreshold = Self.levelThresholds[safe: userLevel.level - 1] ?? 0
        let nextThreshold = Self.levelThresholds[safe: userLevel.level] ?? (currentThreshold + 1000)
        let range = nextThreshold - currentThreshold
        guard range > 0 else { return 1.0 }
        let progress = Double(userLevel.totalXP - currentThreshold) / Double(range)
        return min(max(progress, 0), 1.0)
    }

    /// 現在のレベル称号を取得する（ローカライズ済み文字列を返す）。
    func currentTitle() -> String {
        let level = getOrCreateUserLevel().level
        // 最も近い称号キーを取得し、ローカライズして返す
        var titleKey = "level.title.1"
        for (lv, key) in Self.levelTitles.sorted(by: { $0.key < $1.key }) {
            if level >= lv { titleKey = key }
        }
        return LanguageManager.shared.l(titleKey)
    }

    // MARK: - バッジ

    /// バッジ定義（32種）。nameKey/descriptionKey にローカライズキーを格納し、表示時に解決する。
    static let badgeDefinitions: [(id: String, nameKey: String, descriptionKey: String, icon: String, color: String, condition: String)] = [
        // 学習系
        ("first_lesson", "badge.first_lesson.name", "badge.first_lesson.desc", "figure.walk", "3B82F6", "lesson_1"),
        ("lesson_10", "badge.lesson_10.name", "badge.lesson_10.desc", "book.fill", "8B5CF6", "lesson_10"),
        ("lesson_25", "badge.lesson_25.name", "badge.lesson_25.desc", "book.closed.fill", "EC4899", "lesson_25"),
        ("lesson_50", "badge.lesson_50.name", "badge.lesson_50.desc", "books.vertical.fill", "F59E0B", "lesson_50"),
        ("lesson_100", "badge.lesson_100.name", "badge.lesson_100.desc", "graduationcap.fill", "10B981", "lesson_100"),
        ("all_ch01", "badge.all_ch01.name", "badge.all_ch01.desc", "star.fill", "06B6D4", "chapter_ch01"),
        ("oop_master", "badge.oop_master.name", "badge.oop_master.desc", "cube.fill", "6366F1", "oop_complete"),
        ("all_lessons", "badge.all_lessons.name", "badge.all_lessons.desc", "crown.fill", "FFD700", "all_lessons"),

        // クイズ系
        ("quiz_10", "badge.quiz_10.name", "badge.quiz_10.desc", "questionmark.circle.fill", "3B82F6", "quiz_10"),
        ("quiz_50", "badge.quiz_50.name", "badge.quiz_50.desc", "checkmark.circle.fill", "8B5CF6", "quiz_50"),
        ("quiz_100", "badge.quiz_100.name", "badge.quiz_100.desc", "checkmark.seal.fill", "10B981", "quiz_100"),
        ("quiz_200", "badge.quiz_200.name", "badge.quiz_200.desc", "checkmark.diamond.fill", "EC4899", "quiz_200"),
        ("quiz_500", "badge.quiz_500.name", "badge.quiz_500.desc", "bolt.circle.fill", "F59E0B", "quiz_500"),
        ("perfect_3", "badge.perfect_3.name", "badge.perfect_3.desc", "sparkles", "EC4899", "perfect_3"),
        ("perfect_10", "badge.perfect_10.name", "badge.perfect_10.desc", "star.circle.fill", "FFD700", "perfect_10"),
        ("speed_demon", "badge.speed_demon.name", "badge.speed_demon.desc", "hare.fill", "EF4444", "speed_quiz"),
        ("error_finder", "badge.error_finder.name", "badge.error_finder.desc", "ladybug.fill", "DC2626", "error_10"),

        // ストリーク系
        ("streak_3", "badge.streak_3.name", "badge.streak_3.desc", "flame.fill", "F59E0B", "streak_3"),
        ("streak_7", "badge.streak_7.name", "badge.streak_7.desc", "flame.fill", "EF4444", "streak_7"),
        ("streak_14", "badge.streak_14.name", "badge.streak_14.desc", "flame.circle.fill", "EC4899", "streak_14"),
        ("streak_30", "badge.streak_30.name", "badge.streak_30.desc", "flame.circle.fill", "FFD700", "streak_30"),
        ("streak_50", "badge.streak_50.name", "badge.streak_50.desc", "flame.circle.fill", "FF6B35", "streak_50"),
        ("streak_100", "badge.streak_100.name", "badge.streak_100.desc", "trophy.fill", "FFD700", "streak_100"),
        ("streak_365", "badge.streak_365.name", "badge.streak_365.desc", "medal.fill", "FFD700", "streak_365"),

        // 資格系
        ("silver_ready", "badge.silver_ready.name", "badge.silver_ready.desc", "shield.fill", "C0C0C0", "silver_lessons"),
        ("silver_pass", "badge.silver_pass.name", "badge.silver_pass.desc", "shield.checkered", "C0C0C0", "silver_pass"),
        ("gold_ready", "badge.gold_ready.name", "badge.gold_ready.desc", "shield.fill", "FFD700", "gold_lessons"),
        ("gold_pass", "badge.gold_pass.name", "badge.gold_pass.desc", "shield.checkered", "FFD700", "gold_pass"),
        ("xp_1000", "badge.xp_1000.name", "badge.xp_1000.desc", "bolt.fill", "8B5CF6", "xp_1000"),
        ("xp_5000", "badge.xp_5000.name", "badge.xp_5000.desc", "bolt.circle.fill", "10B981", "xp_5000"),
        ("xp_10000", "badge.xp_10000.name", "badge.xp_10000.desc", "bolt.shield.fill", "EF4444", "xp_10000"),
        ("xp_30000", "badge.xp_30000.name", "badge.xp_30000.desc", "bolt.ring.closed", "FFD700", "xp_30000"),
    ]

    /// 獲得済みバッジ一覧を取得する。
    func getEarnedBadges() -> [UserBadge] {
        let descriptor = FetchDescriptor<UserBadge>(
            sortBy: [SortDescriptor(\.earnedAt, order: .reverse)]
        )
        return modelContext.fetchLogged(descriptor)
    }

    /// バッジ獲得済みか判定する。
    func hasBadge(_ badgeId: String) -> Bool {
        let descriptor = FetchDescriptor<UserBadge>(
            predicate: #Predicate { $0.badgeId == badgeId }
        )
        return modelContext.fetchCountLogged(descriptor) > 0
    }

    /// バッジを授与する（重複防止付き）。
    @discardableResult
    func awardBadge(badgeId: String) -> UserBadge? {
        guard !hasBadge(badgeId) else { return nil }
        guard let def = Self.badgeDefinitions.first(where: { $0.id == badgeId }) else { return nil }

        let badge = UserBadge(
            badgeId: def.id,
            name: def.nameKey,
            description: def.descriptionKey,
            iconName: def.icon,
            colorHex: def.color
        )
        modelContext.insert(badge)
        saveContext()
        return badge
    }

    /// 復習クイズ正解時のXP付与。
    @discardableResult
    func awardReviewCorrectXP(quizId: String) -> Int? {
        awardXP(amount: XPAmount.reviewCorrect, reason: "review_correct", relatedId: quizId)
    }

    /// 初回正解ボーナスXP付与。
    @discardableResult
    func awardFirstTryCorrectXP(quizId: String) -> Int? {
        awardXP(amount: XPAmount.firstTryCorrect, reason: "first_try_correct", relatedId: quizId)
    }

    /// 条件を自動チェックしてバッジを付与する。付与されたバッジIDを返す。
    func checkAndAwardBadges(
        completedLessons: Int,
        correctQuizzes: Int,
        streak: Int,
        perfectCount: Int,
        totalXP: Int
    ) -> [String] {
        var awarded: [String] = []

        // 全獲得済みバッジIDを1回のクエリでバッチ取得（N+1防止）
        let earnedBadgeIds = allEarnedBadgeIds()

        // レッスン系 — 完了数ベース
        let lessonBadges: [(String, Int)] = [
            ("first_lesson", 1), ("lesson_10", 10), ("lesson_25", 25),
            ("lesson_50", 50), ("lesson_100", 100)
        ]
        for (id, threshold) in lessonBadges {
            if completedLessons >= threshold, !earnedBadgeIds.contains(id) {
                if awardBadge(badgeId: id) != nil { awarded.append(id) }
            }
        }

        // チャプター完了バッジ — ch01 全レッスン完了
        // completedLessonIds を1回だけ取得して使い回す（N+1防止）
        let allCompletedIds = completedLessonIds()

        if !earnedBadgeIds.contains("all_ch01") {
            let ch01Lessons = ContentService.shared.getLessons(courseId: "ch01")
            if !ch01Lessons.isEmpty {
                if ch01Lessons.allSatisfy({ allCompletedIds.contains($0.id) }) {
                    if awardBadge(badgeId: "all_ch01") != nil { awarded.append("all_ch01") }
                }
            }
        }

        // OOPマスター — ch07(クラス入門), ch08(継承・interface) 全完了
        if !earnedBadgeIds.contains("oop_master") {
            let oopCourseIds = ["ch07", "ch08"]
            let allOopDone = oopCourseIds.allSatisfy { courseId in
                let lessons = ContentService.shared.getLessons(courseId: courseId)
                return !lessons.isEmpty && lessons.allSatisfy { allCompletedIds.contains($0.id) }
            }
            if allOopDone {
                if awardBadge(badgeId: "oop_master") != nil { awarded.append("oop_master") }
            }
        }

        // 全レッスン制覇
        if !earnedBadgeIds.contains("all_lessons") {
            let totalLessons = ContentService.shared.totalLessonCount
            if completedLessons >= totalLessons, totalLessons > 0 {
                if awardBadge(badgeId: "all_lessons") != nil { awarded.append("all_lessons") }
            }
        }

        // クイズ系
        let quizBadges: [(String, Int)] = [
            ("quiz_10", 10), ("quiz_50", 50), ("quiz_100", 100), ("quiz_200", 200), ("quiz_500", 500)
        ]
        for (id, threshold) in quizBadges {
            if correctQuizzes >= threshold, !earnedBadgeIds.contains(id) {
                if awardBadge(badgeId: id) != nil { awarded.append(id) }
            }
        }

        // パーフェクト系
        if perfectCount >= 3, !earnedBadgeIds.contains("perfect_3") {
            if awardBadge(badgeId: "perfect_3") != nil { awarded.append("perfect_3") }
        }
        if perfectCount >= 10, !earnedBadgeIds.contains("perfect_10") {
            if awardBadge(badgeId: "perfect_10") != nil { awarded.append("perfect_10") }
        }

        // エラー発見バッジ — errorFind クイズ正解10問
        if !earnedBadgeIds.contains("error_finder") {
            let errorFindCorrectCount = countCorrectByQuizType("errorFind")
            if errorFindCorrectCount >= 10 {
                if awardBadge(badgeId: "error_finder") != nil { awarded.append("error_finder") }
            }
        }

        // スピードデーモンバッジ — checkAndAwardSpeedDemon で別途判定するためここではスキップ

        // ストリーク系
        let streakBadges: [(String, Int)] = [
            ("streak_3", 3), ("streak_7", 7), ("streak_14", 14),
            ("streak_30", 30), ("streak_50", 50), ("streak_100", 100), ("streak_365", 365)
        ]
        for (id, threshold) in streakBadges {
            if streak >= threshold, !earnedBadgeIds.contains(id) {
                if awardBadge(badgeId: id) != nil { awarded.append(id) }
            }
        }

        // 資格系 — Silver/Gold 範囲全レッスン完了
        if !earnedBadgeIds.contains("silver_ready") {
            let silverCourses = ContentService.shared.getAllCourses().filter { $0.certificationLevel == .silver }
            let allDone = silverCourses.allSatisfy { course in
                let lessons = ContentService.shared.getLessons(courseId: course.id)
                return !lessons.isEmpty && lessons.allSatisfy { allCompletedIds.contains($0.id) }
            }
            if allDone, !silverCourses.isEmpty {
                if awardBadge(badgeId: "silver_ready") != nil { awarded.append("silver_ready") }
            }
        }
        if !earnedBadgeIds.contains("gold_ready") {
            let goldCourses = ContentService.shared.getAllCourses().filter { $0.certificationLevel == .gold }
            let allDone = goldCourses.allSatisfy { course in
                let lessons = ContentService.shared.getLessons(courseId: course.id)
                return !lessons.isEmpty && lessons.allSatisfy { allCompletedIds.contains($0.id) }
            }
            if allDone, !goldCourses.isEmpty {
                if awardBadge(badgeId: "gold_ready") != nil { awarded.append("gold_ready") }
            }
        }

        // 資格系 — 模擬試験合格
        checkExamBadges(awarded: &awarded, prefix: "silver", badgeId: "silver_pass", earnedBadgeIds: earnedBadgeIds)
        checkExamBadges(awarded: &awarded, prefix: "gold", badgeId: "gold_pass", earnedBadgeIds: earnedBadgeIds)

        // XP系
        if totalXP >= 1000, !earnedBadgeIds.contains("xp_1000") {
            if awardBadge(badgeId: "xp_1000") != nil { awarded.append("xp_1000") }
        }
        if totalXP >= 5000, !earnedBadgeIds.contains("xp_5000") {
            if awardBadge(badgeId: "xp_5000") != nil { awarded.append("xp_5000") }
        }
        if totalXP >= 10000, !earnedBadgeIds.contains("xp_10000") {
            if awardBadge(badgeId: "xp_10000") != nil { awarded.append("xp_10000") }
        }
        if totalXP >= 30000, !earnedBadgeIds.contains("xp_30000") {
            if awardBadge(badgeId: "xp_30000") != nil { awarded.append("xp_30000") }
        }

        return awarded
    }

    // MARK: - Badge Helper

    /// 全獲得済みバッジIDをバッチ取得する（N+1クエリ防止）。
    private func allEarnedBadgeIds() -> Set<String> {
        let descriptor = FetchDescriptor<UserBadge>()
        return Set(modelContext.fetchLogged(descriptor).map(\.badgeId))
    }

    /// 完了済みのレッスンID一覧をバッチ取得する。
    private func completedLessonIds() -> Set<String> {
        let status = completedRaw
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.statusRaw == status }
        )
        return Set(modelContext.fetchLogged(descriptor).map(\.lessonId))
    }

    /// 指定クイズタイプの正解数を返す。
    /// 指定タイプのクイズで正解した**ユニークなクイズ数**を返す。
    /// 同じクイズを複数回正解しても1問としてカウントする。
    /// バッチクエリで正解した全quizIdを取得し、対象セットとの交差で判定（N+1 排除）。
    private func countCorrectByQuizType(_ typeRaw: String) -> Int {
        let targetQuizIds = ContentService.shared.getQuizIds(byType: typeRaw)
        guard !targetQuizIds.isEmpty else { return 0 }

        // 正解済みの全クイズIDを1回のクエリで取得
        let descriptor = FetchDescriptor<UserQuizHistory>(
            predicate: #Predicate { $0.isCorrect == true }
        )
        let correctIds = Set(modelContext.fetchLogged(descriptor).map(\.quizId))
        return targetQuizIds.intersection(correctIds).count
    }

    /// 模擬試験合格バッジを判定する。
    private func checkExamBadges(awarded: inout [String], prefix: String, badgeId: String, earnedBadgeIds: Set<String>) {
        guard !earnedBadgeIds.contains(badgeId) else { return }
        // exam ID は "se11_silver_1" のような形式のため contains でマッチ
        let descriptor = FetchDescriptor<UserExamResult>(
            predicate: #Predicate { result in
                result.passed && result.examChapterId.contains(prefix)
            }
        )
        if modelContext.fetchCountLogged(descriptor) > 0 {
            if awardBadge(badgeId: badgeId) != nil { awarded.append(badgeId) }
        }
    }

    /// スピードデーモンバッジを判定する。30秒以内に全問正解した場合に付与。
    /// - Parameters:
    ///   - elapsedSeconds: クイズセッションの経過秒数
    ///   - isPerfect: 全問正解したか
    /// - Returns: バッジが付与された場合は "speed_demon" を返す。
    func checkAndAwardSpeedDemon(elapsedSeconds: TimeInterval, isPerfect: Bool) -> String? {
        guard isPerfect, elapsedSeconds <= 30, !hasBadge("speed_demon") else { return nil }
        if awardBadge(badgeId: "speed_demon") != nil {
            return "speed_demon"
        }
        return nil
    }

    /// 今日獲得したXPの合計。
    func todayXP() -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<UserXPRecord>(
            predicate: #Predicate { record in
                record.earnedAt >= startOfDay
            }
        )
        let records = modelContext.fetchLogged(descriptor)
        return records.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Private

    private func getOrCreateUserLevel() -> UserLevel {
        let descriptor = FetchDescriptor<UserLevel>()
        if let existing = modelContext.fetchFirstLogged(descriptor) {
            return existing
        }
        let level = UserLevel()
        modelContext.insert(level)
        saveContext()
        return level
    }

    private func addToDailyXP(amount: Int) {
        let today = Date().dateString
        let descriptor = FetchDescriptor<UserDailyRecord>(
            predicate: #Predicate { $0.dateString == today }
        )
        if let record = modelContext.fetchFirstLogged(descriptor) {
            record.earnedXP += amount
        } else {
            // 新規レコードの場合、ProgressService 経由で取得し、既存レコードが確実に作成されるようにする
            // （unique制約による上書きで既存データが消失するリスクを回避）
            let record = UserDailyRecord(dateString: today)
            record.earnedXP = amount
            // 注: insert 前に再度フェッチして確認（ProgressService 側で直前に作成された可能性）
            let recheck = FetchDescriptor<UserDailyRecord>(
                predicate: #Predicate { $0.dateString == today }
            )
            if let existing = modelContext.fetchFirstLogged(recheck) {
                existing.earnedXP += amount
            } else {
                modelContext.insert(record)
            }
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            AppLogger.swiftData.error("GamificationService 保存エラー: \(error.localizedDescription)")
            SaveErrorNotifier.shared.report(error)
        }
    }
}

// MARK: - Array safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
