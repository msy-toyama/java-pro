//
//  HomeViewModel.swift
//  Java Pro
//
//  ホーム画面のデータ取得・状態管理を担うViewModel。
//  14個の@Stateとデータ読み込みロジックを集約し、View層を薄く保つ。
//

import SwiftUI
import SwiftData

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - State

    var todayStats = TodayStats(completedLessons: 0, completedQuizzes: 0, streak: 0, earnedXP: 0, studyMinutes: 0)
    var reviewCount = 0
    var recommendedLesson: LessonData?
    var totalCompleted = 0
    var totalLessons = 0
    var userLevel = 1
    var levelTitle = "Java見習い"
    var levelProgress: Double = 0
    var totalXP = 0
    var recentBadges: [UserBadge] = []
    var isLoading = true
    var dailyGoalMinutes = 10
    var showGuideTour = false
    var lastLoadTime: Date?
    /// loadData の二重実行を防ぐフラグ
    private var isLoadingData = false

    // MARK: - Computed

    private var lang: LanguageManager { LanguageManager.shared }

    var streakMessage: String {
        switch todayStats.streak {
        case 0: return lang.l("home.streak.0")
        case 1: return lang.l("home.streak.1")
        case 2...6: return lang.l("home.streak.short")
        case 7...29: return lang.l("home.streak.medium")
        default: return lang.l("home.streak.long")
        }
    }

    var overallProgress: Double {
        totalLessons > 0 ? Double(totalCompleted) / Double(totalLessons) : 0
    }

    var dailyGoalProgress: Double {
        dailyGoalMinutes > 0 ? min(1.0, Double(todayStats.studyMinutes) / Double(dailyGoalMinutes)) : 0
    }

    // MARK: - Actions

    /// タブ復帰時に呼ぶ。最終読み込みから3秒以内ならスキップ。
    func refreshIfNeeded(modelContext: ModelContext) {
        let elapsed = lastLoadTime.map { Date().timeIntervalSince($0) } ?? .infinity
        if elapsed > 3 {
            loadData(modelContext: modelContext)
        }
    }

    /// ガイドツアーの表示判定
    func checkGuideTour() {
        if !showGuideTour && !UserDefaults.standard.hasSeenHomeTour {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                showGuideTour = true
            }
        }
    }

    /// ガイドツアー完了
    func dismissGuideTour() {
        showGuideTour = false
        UserDefaults.standard.hasSeenHomeTour = true
    }

    // MARK: - Data Loading

    func loadData(modelContext: ModelContext) {
        guard !isLoadingData else { return }
        isLoadingData = true
        lastLoadTime = Date()
        Task {
            defer {
                isLoadingData = false
                if isLoading {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isLoading = false
                    }
                }
            }
            let progressService = ProgressService(modelContext: modelContext)
            let reviewService = ReviewService(modelContext: modelContext)
            let gamificationService = GamificationService(modelContext: modelContext)

            // 軽量データを先に取得して即座にUIに反映
            todayStats = progressService.todayStats()
            totalLessons = ContentService.shared.totalLessonCount

            // 少し重い処理を続行
            reviewCount = reviewService.reviewCount()
            totalCompleted = progressService.totalCompletedLessonCount()

            // XP / レベル
            let level = gamificationService.getUserLevel()
            userLevel = level.level
            totalXP = level.totalXP
            levelProgress = gamificationService.progressToNextLevel()
            levelTitle = gamificationService.currentTitle()

            // バッジ
            recentBadges = gamificationService.getEarnedBadges()

            // おすすめレッスン
            if let lessonId = progressService.recommendedNextLessonId() {
                recommendedLesson = ContentService.shared.getLesson(id: lessonId)
            } else {
                recommendedLesson = nil
            }

            // 今日の目標
            dailyGoalMinutes = progressService.getSettings().dailyGoalMinutes
        }
    }
}
