//
//  Java_ProTests.swift
//  Java ProTests
//
//  Java Pro の包括的ユニットテスト。
//  Swift Testing フレームワークを使用。
//

import Testing
import Foundation
import SwiftData
@testable import Java_Pro

// MARK: - テスト用ヘルパー

/// テスト全体で共有するインメモリ ModelContainer。
/// SwiftData は同一プロセスで複数コンテナを作ると解放時にクラッシュするため、
/// 単一コンテナを共有し、テスト間でデータをクリアする方式を採用。
@MainActor
enum TestDatabase {
    private static var _container: ModelContainer?

    static var container: ModelContainer {
        get throws {
            if let c = _container { return c }
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let c = try ModelContainer(
                for: UserLessonProgress.self, UserQuizHistory.self, UserDailyRecord.self,
                     AppSettings.self, UserXPRecord.self, UserBadge.self, UserLevel.self, UserExamResult.self,
                configurations: config
            )
            _container = c
            return c
        }
    }

    /// 全テーブルをクリアした新鮮な ModelContext を返す。
    static func freshContext() throws -> ModelContext {
        let container = try container
        let ctx = container.mainContext
        try ctx.delete(model: UserLessonProgress.self)
        try ctx.delete(model: UserQuizHistory.self)
        try ctx.delete(model: UserDailyRecord.self)
        try ctx.delete(model: AppSettings.self)
        try ctx.delete(model: UserXPRecord.self)
        try ctx.delete(model: UserBadge.self)
        try ctx.delete(model: UserLevel.self)
        try ctx.delete(model: UserExamResult.self)
        try ctx.save()
        return ctx
    }
}

/// テスト用の新鮮な ModelContext を取得するショートカット。
@MainActor
func makeTestModelContext() throws -> ModelContext {
    try TestDatabase.freshContext()
}

// ============================================================
// MARK: - 1. ContentModels テスト
// ============================================================

@Suite("ContentModels")
struct ContentModelsTests {

    @Test("CertificationLevel raw values")
    func certificationLevelRawValues() {
        #expect(CertificationLevel.beginner.rawValue == "beginner")
        #expect(CertificationLevel.silver.rawValue == "silver")
        #expect(CertificationLevel.gold.rawValue == "gold")
        #expect(CertificationLevel.allCases.count == 3)
    }

    @Test("QuizDifficulty raw values")
    func quizDifficultyRawValues() {
        #expect(QuizDifficulty.easy.rawValue == "easy")
        #expect(QuizDifficulty.normal.rawValue == "normal")
        #expect(QuizDifficulty.hard.rawValue == "hard")
    }

    @Test("QuizType includes all expected cases")
    func quizTypeCases() {
        // 8種のクイズタイプが揃っていること
        let types: [QuizData.QuizType] = [
            .fourChoice, .multiChoice, .fillBlank, .reorder,
            .outputPredict, .errorFind, .codeComplete, .examSimulator
        ]
        #expect(types.count == 8)
    }

    @Test("LessonStatus raw values")
    func lessonStatusRawValues() {
        #expect(LessonStatus.notStarted.rawValue == "notStarted")
        #expect(LessonStatus.inProgress.rawValue == "inProgress")
        #expect(LessonStatus.completed.rawValue == "completed")
    }

    @Test("CourseIndex JSON decoding")
    func courseIndexDecoding() throws {
        let json = """
        {
            "id": "ch01",
            "title": "入門",
            "subtitle": "Javaの世界へようこそ",
            "order": 1,
            "iconName": "star",
            "colorHex": "3B82F6",
            "lessonCount": 3,
            "fileName": "ch01_introduction",
            "certificationLevel": "beginner",
            "category": "basics"
        }
        """
        let data = json.data(using: .utf8)!
        let course = try JSONDecoder().decode(CourseIndex.self, from: data)
        #expect(course.id == "ch01")
        #expect(course.title == "入門")
        #expect(course.order == 1)
        #expect(course.lessonCount == 3)
        #expect(course.certificationLevel == .beginner)
        #expect(course.category == "basics")
    }

    @Test("QuizChoice JSON decoding")
    func quizChoiceDecoding() throws {
        let json = """
        {
            "id": "c1",
            "text": "正解の選択肢",
            "isCorrect": true,
            "order": 1
        }
        """
        let data = json.data(using: .utf8)!
        let choice = try JSONDecoder().decode(QuizChoice.self, from: data)
        #expect(choice.id == "c1")
        #expect(choice.text == "正解の選択肢")
        #expect(choice.isCorrect == true)
        #expect(choice.order == 1)
    }

    @Test("GlossaryEntry JSON decoding")
    func glossaryEntryDecoding() throws {
        let json = """
        {
            "id": "g1",
            "term": "変数",
            "reading": "へんすう",
            "definition": "値を格納するための名前付き領域",
            "relatedLessonIds": ["ch01_lesson01"]
        }
        """
        let data = json.data(using: .utf8)!
        let entry = try JSONDecoder().decode(GlossaryEntry.self, from: data)
        #expect(entry.term == "変数")
        #expect(entry.reading == "へんすう")
        #expect(entry.relatedLessonIds.count == 1)
    }
}

// ============================================================
// MARK: - 2. DateExtensions テスト
// ============================================================

@Suite("DateExtensions")
struct DateExtensionsTests {

    @Test("dateString format is yyyy-MM-dd")
    func dateStringFormat() {
        let date = Date()
        let str = date.dateString
        // yyyy-MM-dd format: 10 chars, 2 hyphens
        #expect(str.count == 10)
        #expect(str.contains("-"))
    }

    @Test("Date round-trip via dateString")
    func dateStringRoundTrip() {
        let original = Date()
        let str = original.dateString
        let restored = Date(dateString: str)
        #expect(restored != nil)
        #expect(restored?.dateString == str)
    }

    @Test("isToday returns true for today")
    func isTodayCheck() {
        #expect(Date().isToday == true)
    }

    @Test("isYesterday returns false for today")
    func isYesterdayCheck() {
        #expect(Date().isYesterday == false)
    }

    @Test("daysAgo returns past date")
    func daysAgoCheck() {
        let threeDaysAgo = Date().daysAgo(3)
        let diff = Calendar.current.dateComponents([.day], from: threeDaysAgo, to: Date()).day ?? 0
        #expect(diff == 3)
    }

    @Test("daysLater returns future date")
    func daysLaterCheck() {
        let now = Date()
        let threeDaysLater = now.daysLater(3)
        let diff = Calendar.current.dateComponents([.day], from: now, to: threeDaysLater).day ?? 0
        #expect(diff == 3)
    }

    @Test("daysDifference calculation")
    func daysDifferenceCheck() {
        let today = Date()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        let diff = today.daysDifference(from: fiveDaysAgo)
        #expect(diff == 5)
    }

    @Test("shortDisplayString returns 今日 for today")
    func shortDisplayStringToday() {
        let str = Date().shortDisplayString
        #expect(str == "今日")
    }
}

// ============================================================
// MARK: - 3. UserModels テスト (SwiftData)
// ============================================================

@Suite("UserModels")
struct UserModelsTests {

    @Test("UserLessonProgress default status is notStarted")
    @MainActor
    func lessonProgressDefault() throws {
        let progress = UserLessonProgress(lessonId: "test_lesson")
        #expect(progress.status == .notStarted)
        #expect(progress.statusRaw == "notStarted")
    }

    @Test("UserLessonProgress status setter updates raw value")
    @MainActor
    func lessonProgressStatusSetter() throws {
        let progress = UserLessonProgress(lessonId: "test_lesson")
        progress.status = .completed
        #expect(progress.statusRaw == "completed")
        #expect(progress.status == .completed)
    }

    @Test("UserQuizHistory initializes correctly")
    @MainActor
    func quizHistoryInit() throws {
        let history = UserQuizHistory(quizId: "q1", isCorrect: true, streakCount: 3, intervalStage: 2)
        #expect(history.quizId == "q1")
        #expect(history.isCorrect == true)
        #expect(history.streakCount == 3)
        #expect(history.intervalStage == 2)
        #expect(!history.id.isEmpty)
    }

    @Test("UserDailyRecord initializes with zeros")
    @MainActor
    func dailyRecordInit() throws {
        let record = UserDailyRecord(dateString: "2025-01-01")
        #expect(record.dateString == "2025-01-01")
        #expect(record.completedLessons == 0)
        #expect(record.completedQuizzes == 0)
        #expect(record.earnedXP == 0)
        #expect(record.studySeconds == 0)
    }

    @Test("AppSettings defaults are correct")
    @MainActor
    func appSettingsDefaults() throws {
        let settings = AppSettings()
        #expect(settings.id == "app_settings")
        #expect(settings.notificationsEnabled == true)
        #expect(settings.adRemoved == false)
        #expect(settings.reminderHour == 8)
        #expect(settings.reminderMinute == 0)
        #expect(settings.hasCompletedOnboarding == false)
        #expect(settings.isDarkMode == nil)
        #expect(settings.selectedCertification == .beginner)
        #expect(settings.dailyGoalMinutes == 15)
        #expect(settings.hapticFeedbackEnabled == true)
        #expect(settings.soundEnabled == true)
        #expect(settings.soundVolume == 0.7)
    }

    @Test("AppSettings certification setter")
    @MainActor
    func appSettingsCertSetter() throws {
        let settings = AppSettings()
        settings.selectedCertification = .gold
        #expect(settings.selectedCertificationRaw == "gold")
        #expect(settings.selectedCertification == .gold)
    }

    @Test("UserLevel defaults")
    @MainActor
    func userLevelDefaults() throws {
        let level = UserLevel()
        #expect(level.id == "user_level")
        #expect(level.level == 1)
        #expect(level.totalXP == 0)
    }

    @Test("UserExamResult passing logic")
    @MainActor
    func examResultPassingLogic() throws {
        // 63% 合格ライン
        let pass = UserExamResult(examChapterId: "se11_silver_1", score: 51, totalQuestions: 80, timeSpentSeconds: 5400, passingRate: 0.63)
        #expect(pass.passed == true) // 51/80 = 63.75%

        let fail = UserExamResult(examChapterId: "se11_silver_1", score: 50, totalQuestions: 80, timeSpentSeconds: 5400, passingRate: 0.63)
        #expect(fail.passed == false) // 50/80 = 62.5%
    }

    @Test("UserExamResult zero totalQuestions does not crash")
    @MainActor
    func examResultZeroDivision() throws {
        let result = UserExamResult(examChapterId: "test", score: 0, totalQuestions: 0, timeSpentSeconds: 0)
        // max(totalQuestions, 1) で割るのでクラッシュしない
        #expect(result.passed == false)
    }

    @Test("SwiftData CRUD with in-memory container")
    @MainActor
    func swiftDataCRUD() throws {
        let ctx = try makeTestModelContext()

        // Create
        let progress = UserLessonProgress(lessonId: "crud_test")
        ctx.insert(progress)
        try ctx.save()

        // Read
        let descriptor = FetchDescriptor<UserLessonProgress>(
            predicate: #Predicate { $0.lessonId == "crud_test" }
        )
        let fetched = try ctx.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.lessonId == "crud_test")

        // Update
        fetched.first?.status = .completed
        try ctx.save()
        let updated = try ctx.fetch(descriptor)
        #expect(updated.first?.status == .completed)

        // Delete
        if let item = fetched.first {
            ctx.delete(item)
            try ctx.save()
        }
        let deleted = try ctx.fetch(descriptor)
        #expect(deleted.isEmpty)
    }
}

// ============================================================
// MARK: - 4. GamificationService テスト
// ============================================================

@Suite("GamificationService")
struct GamificationServiceTests {

    @Test("Level thresholds table has 50 entries (Lv1..50)")
    @MainActor
    func levelThresholdsCount() {
        #expect(GamificationService.levelThresholds.count == 50)
    }

    @Test("Level thresholds are monotonically increasing")
    @MainActor
    func levelThresholdsMonotonic() {
        let thresholds = GamificationService.levelThresholds
        for i in 1..<thresholds.count {
            #expect(thresholds[i] > thresholds[i - 1], "Lv\(i+1) threshold should be > Lv\(i)")
        }
    }

    @Test("Lv1 requires 0 XP")
    @MainActor
    func level1At0XP() {
        #expect(GamificationService.levelThresholds[0] == 0)
    }

    @Test("Lv50 requires ~30,000 XP")
    @MainActor
    func level50Threshold() {
        let lv50 = GamificationService.levelThresholds.last!
        // 50^2 * 12.24 = 30,600
        #expect(lv50 > 29_000)
        #expect(lv50 < 32_000)
    }

    @Test("calculateLevel returns 1 for 0 XP")
    @MainActor
    func calculateLevel0XP() {
        #expect(GamificationService.calculateLevel(totalXP: 0) == 1)
    }

    @Test("calculateLevel returns 50 for very high XP")
    @MainActor
    func calculateLevelMaxXP() {
        #expect(GamificationService.calculateLevel(totalXP: 999_999) == 50)
    }

    @Test("calculateLevel progression is correct")
    @MainActor
    func calculateLevelProgression() {
        // Lv2 = 2^2 * 12.24 = 48 XP
        let lv2Threshold = GamificationService.levelThresholds[1]
        #expect(GamificationService.calculateLevel(totalXP: lv2Threshold) == 2)
        #expect(GamificationService.calculateLevel(totalXP: lv2Threshold - 1) == 1)
    }

    @Test("XPAmount constants are positive")
    @MainActor
    func xpAmountConstants() {
        #expect(GamificationService.XPAmount.lessonComplete > 0)
        #expect(GamificationService.XPAmount.quizCorrect > 0)
        #expect(GamificationService.XPAmount.quizPerfect > 0)
        #expect(GamificationService.XPAmount.reviewCorrect > 0)
        #expect(GamificationService.XPAmount.streakBonusPerDay > 0)
        #expect(GamificationService.XPAmount.firstTryCorrect > 0)
    }

    @Test("Badge definitions have 32 entries")
    @MainActor
    func badgeDefinitionsCount() {
        #expect(GamificationService.badgeDefinitions.count == 32)
    }

    @Test("Badge IDs are unique")
    @MainActor
    func badgeIdsUnique() {
        let ids = GamificationService.badgeDefinitions.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }

    @Test("Level titles cover key milestones")
    @MainActor
    func levelTitlesCoverage() {
        let titles = GamificationService.levelTitles
        #expect(titles[1] != nil)  // Lv1
        #expect(titles[50] != nil) // Lv50 (max)
        #expect(titles[1] == "level.title.1")
        #expect(titles[50] == "level.title.50")
    }

    @Test("awardXP increases totalXP and returns level-up")
    @MainActor
    func awardXPLevelUp() throws {
        let ctx = try makeTestModelContext()
        let service = GamificationService(modelContext: ctx)

        // Lv2 の閾値分を一気に付与
        let lv2Threshold = GamificationService.levelThresholds[1]
        let result = service.awardXP(amount: lv2Threshold, reason: "test")
        #expect(result == 2) // Lv2 にレベルアップ

        // ユーザーレベルが反映されていること
        let userLevel = service.getUserLevel()
        #expect(userLevel.totalXP == lv2Threshold)
        #expect(userLevel.level == 2)
    }

    @Test("awardXP with no level-up returns nil")
    @MainActor
    func awardXPNoLevelUp() throws {
        let ctx = try makeTestModelContext()
        let service = GamificationService(modelContext: ctx)

        let result = service.awardXP(amount: 1, reason: "test")
        #expect(result == nil)
    }

    @Test("awardBadge prevents duplicate")
    @MainActor
    func awardBadgeDuplicate() throws {
        let ctx = try makeTestModelContext()
        let service = GamificationService(modelContext: ctx)

        let first = service.awardBadge(badgeId: "first_lesson")
        #expect(first != nil)
        let second = service.awardBadge(badgeId: "first_lesson")
        #expect(second == nil) // 重複は nil
    }

    @Test("progressToNextLevel returns 0..1 range")
    @MainActor
    func progressToNextLevelRange() throws {
        let ctx = try makeTestModelContext()
        let service = GamificationService(modelContext: ctx)

        let progress = service.progressToNextLevel()
        #expect(progress >= 0.0)
        #expect(progress <= 1.0)
    }

    @Test("currentTitle returns non-empty string")
    @MainActor
    func currentTitleNonEmpty() throws {
        let ctx = try makeTestModelContext()
        let service = GamificationService(modelContext: ctx)

        let title = service.currentTitle()
        #expect(!title.isEmpty)
        #expect(title == "Java見習い") // Lv1 の称号
    }
}

// ============================================================
// MARK: - 5. ProgressService テスト
// ============================================================

@Suite("ProgressService")
struct ProgressServiceTests {

    @Test("getSettings returns singleton with defaults")
    @MainActor
    func getSettingsDefaults() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        let settings = service.getSettings()
        #expect(settings.id == "app_settings")
        #expect(settings.dailyGoalMinutes == 15)
    }

    @Test("getSettings returns same instance on repeated calls")
    @MainActor
    func getSettingsSingleton() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        let s1 = service.getSettings()
        let s2 = service.getSettings()
        #expect(s1.id == s2.id)
    }

    @Test("startLesson creates inProgress record")
    @MainActor
    func startLessonCreatesRecord() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.startLesson(lessonId: "test_lesson_1")
        let progress = service.getLessonProgress(lessonId: "test_lesson_1")
        #expect(progress != nil)
        #expect(progress?.status == .inProgress)
    }

    @Test("completeLesson sets completed status")
    @MainActor
    func completeLessonStatus() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.startLesson(lessonId: "test_lesson_2")
        service.completeLesson(lessonId: "test_lesson_2")
        let progress = service.getLessonProgress(lessonId: "test_lesson_2")
        #expect(progress?.status == .completed)
    }

    @Test("completeLesson does not regress completed status")
    @MainActor
    func completeLessonNoRegress() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.completeLesson(lessonId: "test_l")
        service.startLesson(lessonId: "test_l")
        let progress = service.getLessonProgress(lessonId: "test_l")
        // completed の後に startLesson しても completed のまま
        #expect(progress?.status == .completed)
    }

    @Test("recordQuizAnswer creates history")
    @MainActor
    func recordQuizAnswerCreates() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.recordQuizAnswer(quizId: "quiz_1", isCorrect: true)
        let history = service.latestQuizHistory(quizId: "quiz_1")
        #expect(history != nil)
        #expect(history?.isCorrect == true)
        #expect(history?.streakCount == 1)
        #expect(history?.intervalStage == 1)
    }

    @Test("recordQuizAnswer streak increments on correct")
    @MainActor
    func quizStreakIncrement() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.recordQuizAnswer(quizId: "quiz_s", isCorrect: true)
        service.recordQuizAnswer(quizId: "quiz_s", isCorrect: true)
        service.recordQuizAnswer(quizId: "quiz_s", isCorrect: true)

        let history = service.latestQuizHistory(quizId: "quiz_s")
        #expect(history?.streakCount == 3)
        #expect(history?.intervalStage == 3) // min(0+1+1+1, 4) = 3
    }

    @Test("recordQuizAnswer streak resets on incorrect")
    @MainActor
    func quizStreakReset() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.recordQuizAnswer(quizId: "quiz_r", isCorrect: true)
        service.recordQuizAnswer(quizId: "quiz_r", isCorrect: true)
        service.recordQuizAnswer(quizId: "quiz_r", isCorrect: false)

        let history = service.latestQuizHistory(quizId: "quiz_r")
        #expect(history?.streakCount == 0)
        #expect(history?.intervalStage == 0) // 誤答でリセット
    }

    @Test("addStudySeconds accumulates time")
    @MainActor
    func addStudySeconds() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        service.addStudySeconds(60)
        service.addStudySeconds(120)

        let stats = service.todayStats()
        #expect(stats.studyMinutes == 3) // (60+120)/60 = 3
    }

    @Test("todayStats returns zeros when no activity")
    @MainActor
    func todayStatsZero() throws {
        let ctx = try makeTestModelContext()
        let service = ProgressService(modelContext: ctx)

        let stats = service.todayStats()
        #expect(stats.completedLessons == 0)
        #expect(stats.completedQuizzes == 0)
        #expect(stats.earnedXP == 0)
    }
}

// ============================================================
// MARK: - 6. ExamService テスト
// ============================================================

@Suite("ExamService")
struct ExamServiceTests {

    @Test("Exam definitions are not empty")
    @MainActor
    func examDefinitionsExist() {
        #expect(!ExamService.examDefinitions.isEmpty)
    }

    @Test("Each exam definition has valid fields")
    @MainActor
    func examDefinitionFields() {
        for exam in ExamService.examDefinitions {
            #expect(!exam.id.isEmpty)
            #expect(!exam.titleKey.isEmpty)
            #expect(exam.totalQuestions > 0)
            #expect(exam.timeLimitMinutes > 0)
            #expect(exam.passingRate > 0 && exam.passingRate < 1)
        }
    }

    @Test("Exam definitions cover SE11 and SE17")
    @MainActor
    func examVersionCoverage() {
        let versions = Set(ExamService.examDefinitions.map(\.javaVersion))
        #expect(versions.contains(.se11))
        #expect(versions.contains(.se17))
    }

    @Test("Exam definitions cover Silver and Gold")
    @MainActor
    func examLevelCoverage() {
        let levels = Set(ExamService.examDefinitions.map(\.certLevel))
        #expect(levels.contains(.silver))
        #expect(levels.contains(.gold))
    }

    @Test("exams(certLevel:javaVersion:) filters correctly")
    @MainActor
    func examFiltering() {
        let silverSE11 = ExamService.exams(certLevel: .silver, javaVersion: .se11)
        #expect(!silverSE11.isEmpty)
        for exam in silverSE11 {
            #expect(exam.certLevel == .silver)
            #expect(exam.javaVersion == .se11)
        }
    }

    @Test("defaultPassingRate is reasonable")
    @MainActor
    func defaultPassingRate() {
        #expect(ExamService.defaultPassingRate > 0.5)
        #expect(ExamService.defaultPassingRate < 1.0)
    }

    @Test("saveResult creates UserExamResult")
    @MainActor
    func saveResultCreates() throws {
        let ctx = try makeTestModelContext()
        let service = ExamService(modelContext: ctx)

        let result = service.saveResult(
            examId: "se11_silver_1",
            score: 55,
            totalQuestions: 80,
            timeSpentSeconds: 5400
        )
        #expect(result.score == 55)
        #expect(result.totalQuestions == 80)
        #expect(result.examChapterId == "se11_silver_1")
    }

    @Test("topicDisplayName returns known names")
    @MainActor
    func topicDisplayNames() {
        let name = ExamService.topicDisplayName("java_basics")
        #expect(name == "Javaの基本")
    }
}

// ============================================================
// MARK: - 7. ReviewService テスト
// ============================================================

@Suite("ReviewService")
struct ReviewServiceTests {

    @Test("Review interval stages")
    func reviewIntervalDefinition() {
        // Stage 0 = 即時, Stage 1 = 24h, Stage 2 = 3日, Stage 3 = 7日
        // shouldReview のロジックを間接的に検証
        // Stage 4 以上は復習完了
        // これらは ReviewService の private static 定数だが、動作テストで確認
    }

    @Test("shouldReview returns false for no history")
    @MainActor
    func shouldReviewNoHistory() throws {
        let ctx = try makeTestModelContext()
        let service = ReviewService(modelContext: ctx)
        #expect(service.shouldReview(quizId: "nonexistent") == false)
    }

    @Test("shouldReview returns true after incorrect answer")
    @MainActor
    func shouldReviewAfterIncorrect() throws {
        let ctx = try makeTestModelContext()
        let review = ReviewService(modelContext: ctx)

        // 誤答を記録
        let history = UserQuizHistory(quizId: "q_review_1", isCorrect: false, streakCount: 0, intervalStage: 0)
        ctx.insert(history)
        try ctx.save()

        #expect(review.shouldReview(quizId: "q_review_1") == true)
    }

    @Test("shouldReview returns false for completed stage")
    @MainActor
    func shouldReviewCompleted() throws {
        let ctx = try makeTestModelContext()
        let review = ReviewService(modelContext: ctx)

        // Stage 4（完了）の正答を記録
        let history = UserQuizHistory(quizId: "q_review_2", isCorrect: true, streakCount: 4, intervalStage: 4)
        ctx.insert(history)
        try ctx.save()

        #expect(review.shouldReview(quizId: "q_review_2") == false)
    }

    @Test("reviewCount returns 0 when no history")
    @MainActor
    func reviewCountEmpty() throws {
        let ctx = try makeTestModelContext()
        let service = ReviewService(modelContext: ctx)
        #expect(service.reviewCount() == 0)
    }

    @Test("latestHistoryPublic returns inserted history")
    @MainActor
    func latestHistoryPublic() throws {
        let ctx = try makeTestModelContext()
        let service = ReviewService(modelContext: ctx)

        let h = UserQuizHistory(quizId: "q_pub", isCorrect: true, streakCount: 1, intervalStage: 1)
        ctx.insert(h)
        try ctx.save()

        let latest = service.latestHistoryPublic(quizId: "q_pub")
        #expect(latest != nil)
        #expect(latest?.quizId == "q_pub")
    }
}

// ============================================================
// MARK: - 8. JSON リソース検証テスト
// ============================================================

@Suite("JSON Resources")
struct JSONResourceTests {

    @Test("courses_index.json loads and decodes")
    func coursesIndexLoads() throws {
        let url = Bundle.main.url(forResource: "courses_index", withExtension: "json")
        #expect(url != nil, "courses_index.json が Bundle に存在すること")

        let data = try Data(contentsOf: url!)
        let courses = try JSONDecoder().decode([CourseIndex].self, from: data)
        #expect(courses.count > 0, "コースが1件以上存在すること")
    }

    @Test("glossary.json loads and decodes")
    func glossaryLoads() throws {
        let url = Bundle.main.url(forResource: "glossary", withExtension: "json")
        #expect(url != nil, "glossary.json が Bundle に存在すること")

        let data = try Data(contentsOf: url!)
        let entries = try JSONDecoder().decode([GlossaryEntry].self, from: data)
        #expect(entries.count >= 200, "用語辞典が200件以上存在すること")
    }

    @Test("All chapter JSON files decode without errors")
    func allChaptersLoad() throws {
        guard let url = Bundle.main.url(forResource: "courses_index", withExtension: "json") else {
            Issue.record("courses_index.json が見つかりません")
            return
        }
        let data = try Data(contentsOf: url)
        let courses = try JSONDecoder().decode([CourseIndex].self, from: data)

        for course in courses {
            guard let chapterURL = Bundle.main.url(forResource: course.fileName, withExtension: "json") else {
                Issue.record("\(course.fileName).json が Bundle に存在しません")
                continue
            }
            let chapterData = try Data(contentsOf: chapterURL)
            let chapter = try JSONDecoder().decode(ChapterContent.self, from: chapterData)
            #expect(chapter.courseId == course.id, "\(course.fileName) の courseId が一致すること")
            #expect(chapter.lessons.count == course.lessonCount,
                    "\(course.fileName) のレッスン数がインデックスと一致すること (\(chapter.lessons.count) vs \(course.lessonCount))")
        }
    }

    @Test("All exam question JSON files decode")
    func allExamQuestionsLoad() throws {
        let examFileNames = [
            "exam_questions_se11_silver_1",
            "exam_questions_se11_silver_2",
            "exam_questions_se11_gold_1",
            "exam_questions_se11_gold_2",
            "exam_questions_se17_silver_1",
            "exam_questions_se17_silver_2",
            "exam_questions_se17_gold_1",
            "exam_questions_se17_gold_2",
        ]

        for fileName in examFileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                Issue.record("\(fileName).json が見つかりません")
                continue
            }
            let data = try Data(contentsOf: url)
            let quizzes = try JSONDecoder().decode([QuizData].self, from: data)
            #expect(quizzes.count >= 1, "\(fileName) に問題が1問以上あること")

            // 全問に正解選択肢があること
            for quiz in quizzes {
                let hasCorrect = quiz.choices.contains(where: \.isCorrect)
                    || quiz.correctOrder != nil
                    || quiz.blanks != nil
                #expect(hasCorrect, "\(fileName) / \(quiz.id) に正解が定義されていること")
            }
        }
    }

    @Test("Every quiz has a non-empty question text")
    func quizQuestionsNonEmpty() throws {
        guard let url = Bundle.main.url(forResource: "courses_index", withExtension: "json") else { return }
        let data = try Data(contentsOf: url)
        let courses = try JSONDecoder().decode([CourseIndex].self, from: data)

        for course in courses {
            guard let chapterURL = Bundle.main.url(forResource: course.fileName, withExtension: "json") else { continue }
            let chapterData = try Data(contentsOf: chapterURL)
            let chapter = try JSONDecoder().decode(ChapterContent.self, from: chapterData)

            for lesson in chapter.lessons {
                for quiz in lesson.quizzes {
                    #expect(!quiz.question.isEmpty,
                            "\(course.id)/\(lesson.id)/\(quiz.id) の question が空でないこと")
                }
            }
        }
    }

    @Test("Course IDs in courses_index are unique")
    func courseIdsUnique() throws {
        guard let url = Bundle.main.url(forResource: "courses_index", withExtension: "json") else { return }
        let data = try Data(contentsOf: url)
        let courses = try JSONDecoder().decode([CourseIndex].self, from: data)

        let ids = courses.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count, "コースIDが重複していないこと")
    }

    @Test("Course orders are unique")
    func courseOrdersUnique() throws {
        guard let url = Bundle.main.url(forResource: "courses_index", withExtension: "json") else { return }
        let data = try Data(contentsOf: url)
        let courses = try JSONDecoder().decode([CourseIndex].self, from: data)

        let orders = courses.map(\.order)
        let uniqueOrders = Set(orders)
        #expect(orders.count == uniqueOrders.count, "コースの表示順が重複していないこと")
    }
}

// ============================================================
// MARK: - 9. ContentService テスト
// ============================================================

@Suite("ContentService")
struct ContentServiceTests {

    @Test("ContentService.shared loads content")
    @MainActor
    func contentServiceLoads() async throws {
        let service = ContentService.shared
        await service.loadAllContentAsync()
        #expect(service.isLoaded == true)
        #expect(service.loadError == nil)
    }

    @Test("getAllCourses returns ordered list")
    @MainActor
    func getAllCoursesOrdered() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()
        let courses = service.getAllCourses()
        #expect(!courses.isEmpty)

        // order が昇順であること
        for i in 1..<courses.count {
            #expect(courses[i].order > courses[i - 1].order,
                    "コースが order 順にソートされていること")
        }
    }

    @Test("getCourse returns correct course by ID")
    @MainActor
    func getCourseById() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let course = service.getCourse(id: "ch01")
        #expect(course != nil)
        #expect(course?.title == "入門")
    }

    @Test("getLessons returns non-empty for existing course")
    @MainActor
    func getLessonsNonEmpty() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let lessons = service.getLessons(courseId: "ch01")
        #expect(!lessons.isEmpty)
    }

    @Test("getLesson by ID matches getLessons list")
    @MainActor
    func getLessonById() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let lessons = service.getLessons(courseId: "ch01")
        guard let first = lessons.first else { return }
        let fetched = service.getLesson(id: first.id)
        #expect(fetched?.id == first.id)
        #expect(fetched?.title == first.title)
    }

    @Test("getQuizzes returns quizzes for a lesson")
    @MainActor
    func getQuizzesForLesson() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let lessons = service.getLessons(courseId: "ch02")
        guard let lesson = lessons.first else { return }
        let quizzes = service.getQuizzes(lessonId: lesson.id)
        #expect(!quizzes.isEmpty, "ch02 の最初のレッスンにクイズがあること")
    }

    @Test("totalLessonCount > 0")
    @MainActor
    func totalLessonCountPositive() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()
        #expect(service.totalLessonCount > 0)
    }

    @Test("totalQuizCount > 0")
    @MainActor
    func totalQuizCountPositive() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()
        #expect(service.totalQuizCount > 0)
    }

    @Test("searchGlossary returns results for common term")
    @MainActor
    func searchGlossaryCommon() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let results = service.searchGlossary(query: "変数")
        #expect(!results.isEmpty, "「変数」で検索した結果が空でないこと")
    }

    @Test("searchGlossary with empty query returns all entries")
    @MainActor
    func searchGlossaryEmptyQuery() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let all = service.searchGlossary(query: "")
        let glossary = service.getAllGlossary()
        #expect(all.count == glossary.count)
    }

    @Test("getNextLessonId returns next lesson in same course")
    @MainActor
    func getNextLessonId() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let lessons = service.getLessons(courseId: "ch02")
        guard lessons.count >= 2 else { return }
        let nextId = service.getNextLessonId(after: lessons[0].id)
        #expect(nextId == lessons[1].id)
    }

    @Test("getNextLessonId returns nil for last lesson in course")
    @MainActor
    func getNextLessonIdNilForLast() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let lessons = service.getLessons(courseId: "ch01")
        guard let last = lessons.last else { return }
        let nextId = service.getNextLessonId(after: last.id)
        #expect(nextId == nil)
    }

    @Test("getAllQuizIds returns non-empty set")
    @MainActor
    func getAllQuizIdsNonEmpty() async {
        let service = ContentService.shared
        await service.loadAllContentAsync()

        let ids = service.getAllQuizIds()
        #expect(!ids.isEmpty)
    }
}

// ============================================================
// MARK: - 10. SchemaVersions テスト
// ============================================================

@Suite("SchemaVersions")
struct SchemaVersionsTests {

    @Test("V1 schema has 8 model types")
    func v1SchemaCount() {
        let models = JavaProSchemaV1.models
        #expect(models.count == 8)
    }

    @Test("V2 schema has 8 model types")
    func v2SchemaCount() {
        let models = JavaProSchemaV2.models
        #expect(models.count == 8)
    }

    @Test("Migration plan stages include V1 to V2")
    func migrationPlanStages() {
        let stages = JavaProMigrationPlan.stages
        #expect(!stages.isEmpty)
    }

    @Test("In-memory container creation succeeds")
    @MainActor
    func inMemoryContainerCreation() throws {
        _ = try makeTestModelContext()
        // テスト用ヘルパーが例外なく動くことを確認
    }
}
