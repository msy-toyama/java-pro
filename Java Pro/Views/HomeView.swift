//
//  HomeView.swift
//  Java Pro
//
//  ホーム画面。今日の学習状況、XP・レベル進捗、連続日数、
//  おすすめレッスン、バッジ、復習カウントをダッシュボード表示する。
//  データ取得・状態管理はHomeViewModelに委譲し、View層を薄く保つ。
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var switchToTab: ((MainTabView.Tab) -> Void)?
    @State private var vm = HomeViewModel()
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            if vm.isLoading {
                ScrollView {
                    VStack(spacing: AppLayout.paddingLG) {
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .fill(AppColor.cardBackground)
                            .frame(height: 100)
                            .shimmer(duration: 1.5)
                        HStack(spacing: AppLayout.paddingMD) {
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColor.cardBackground)
                                .frame(height: 80)
                                .shimmer(duration: 1.5)
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .fill(AppColor.cardBackground)
                                .frame(height: 80)
                                .shimmer(duration: 1.5)
                        }
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .fill(AppColor.cardBackground)
                            .frame(height: 70)
                            .shimmer(duration: 1.5)
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .fill(AppColor.cardBackground)
                            .frame(height: 70)
                            .shimmer(duration: 1.5)
                    }
                    .padding(AppLayout.paddingMD)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 780 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .background(AppColor.background)
                .navigationTitle(lang.l("home.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .principal) { BrandedTitleView(title: lang.l("home.title"), icon: "house.fill", subtitle: lang.l("home.subtitle")) } }
                .onAppear { vm.loadData(modelContext: modelContext) }
            } else {
            ScrollView {
                VStack(spacing: AppLayout.paddingLG) {
                    levelCard
                        .staggeredAppear(index: 0)

                    streakCard
                        .staggeredAppear(index: 1)

                    dailyGoalCard
                        .staggeredAppear(index: 2)

                    todayStatsCard
                        .staggeredAppear(index: 3)

                    if let lesson = vm.recommendedLesson {
                        recommendedCard(lesson: lesson)
                            .staggeredAppear(index: 4)
                    }

                    if !vm.recentBadges.isEmpty {
                        recentBadgesCard
                            .staggeredAppear(index: 5)
                    }

                    if vm.reviewCount > 0 {
                        reviewReminderCard
                            .staggeredAppear(index: 6)
                    }

                    progressSummaryCard
                        .staggeredAppear(index: 7)
                }
                .padding(AppLayout.paddingMD)
                .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(AppColor.background)
            .refreshable { vm.loadData(modelContext: modelContext) }
            .navigationTitle(lang.l("home.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { BrandedTitleView(title: lang.l("home.title"), icon: "house.fill", subtitle: lang.l("home.subtitle")) } }
            .navigationDestination(for: LessonData.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .navigationDestination(for: PracticeChapter.self) { chapter in
                PracticeDetailView(chapter: chapter)
            }
            .onAppear {
                vm.checkGuideTour()
                if !vm.isLoading {
                    vm.refreshIfNeeded(modelContext: modelContext)
                }
            }
            .task {
                // 60秒周期で学習時間表示を更新。View 消失時に自動キャンセルされる。
                let service = ProgressService(modelContext: modelContext)
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(60))
                    guard !Task.isCancelled else { break }
                    vm.todayStats = service.todayStats()
                }
            }
            .overlay {
                if vm.showGuideTour {
                    GuideTourOverlay(steps: GuideTourSteps.home) {
                        vm.dismissGuideTour()
                    }
                }
            }
            } // end if/else isLoading
        }
    }

    // MARK: - レベルカード

    private var levelCard: some View {
        VStack(spacing: AppLayout.paddingSM) {
            HStack(alignment: .center, spacing: AppLayout.paddingMD) {
                // レベルバッジ
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.levelPurple, AppColor.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Text("\(vm.userLevel)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.levelTitle)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColor.xpGold)
                            .accessibilityHidden(true)
                        Text("\(vm.totalXP) XP")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                Spacer()

                // 今日のXP（シマー効果）
                VStack(spacing: 2) {
                    Text("+\(vm.todayStats.earnedXP)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.xpGold)
                        .shimmer(duration: 3.0, isActive: vm.todayStats.earnedXP > 0)
                    Text(lang.l("home.today_xp"))
                        .font(AppFont.codeSmall)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }

            // レベル進捗バー（アニメーション付き）
            AnimatedProgressBar(
                progress: vm.levelProgress,
                height: 6,
                backgroundColor: AppColor.levelPurple.opacity(0.15),
                gradient: LinearGradient(
                    colors: [AppColor.levelPurple, AppColor.primary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            HStack {
                Text("Lv.\(vm.userLevel)")
                    .font(AppFont.codeSmall)
                    .foregroundStyle(AppColor.textTertiary)
                Spacer()
                Text("Lv.\(min(vm.userLevel + 1, 50))")
                    .font(AppFont.codeSmall)
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .glowCard(color: AppColor.levelPurple)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("home.accessibility.level_card", vm.userLevel, vm.levelTitle, vm.totalXP, vm.todayStats.earnedXP))
    }

    // MARK: - ストリーク

    private var streakCard: some View {
        HStack(spacing: AppLayout.paddingMD) {
            VStack(spacing: 4) {
                Text("\(vm.todayStats.streak)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(vm.todayStats.streak > 0 ? AppColor.accent : AppColor.textTertiary)
                Text(lang.l("home.streak_days"))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(width: 100)

            VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
                Text(vm.streakMessage)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("home.daily_encouragement"))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()

            Image(systemName: vm.todayStats.streak > 0 ? "flame.fill" : "flame")
                .font(.title)
                .foregroundStyle(vm.todayStats.streak > 0 ? AppColor.accent : AppColor.textTertiary)
                .pulse(min: 0.9, max: 1.1, duration: 0.8)
                .opacity(vm.todayStats.streak > 0 ? 1 : 0.5)
                .accessibilityHidden(true)
        }
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("home.accessibility.streak_card", vm.todayStats.streak, vm.streakMessage))
    }

    // MARK: - 今日の目標

    private var dailyGoalCard: some View {
        let progress = vm.dailyGoalProgress

        return VStack(spacing: AppLayout.paddingSM) {
            HStack {
                Image(systemName: progress >= 1.0 ? "target" : "scope")
                    .foregroundStyle(progress >= 1.0 ? AppColor.success : AppColor.primary)
                    .accessibilityHidden(true)
                Text(lang.l("home.today_goal"))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(lang.l("home.daily_goal_minutes", vm.todayStats.studyMinutes, vm.dailyGoalMinutes))
                    .font(AppFont.caption)
                    .foregroundStyle(progress >= 1.0 ? AppColor.success : AppColor.textSecondary)
            }

            AnimatedProgressBar(
                progress: progress,
                height: 8,
                backgroundColor: AppColor.success.opacity(0.12),
                foregroundColor: AppColor.success
            )

            if progress >= 1.0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.success)
                        .accessibilityHidden(true)
                    Text(lang.l("home.goal_achieved"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.success)
                }
            }
        }
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("home.accessibility.daily_goal_card", vm.todayStats.studyMinutes, vm.dailyGoalMinutes) + (progress >= 1.0 ? lang.l("home.accessibility.daily_goal_achieved_suffix") : ""))
    }

    // MARK: - おすすめレッスン

    private func recommendedCard(lesson: LessonData) -> some View {
        NavigationLink(value: lesson) {
            HStack(spacing: AppLayout.paddingMD) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.l("home.next_lesson"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(lesson.title)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(lang.l("common.about_minutes", lesson.estimatedMinutes))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColor.primary)
                    .accessibilityHidden(true)
            }
            .modifier(CardStyle())
        }
        .accessibilityLabel(lang.l("home.accessibility.next_lesson_label", lesson.title, lesson.estimatedMinutes))
        .accessibilityHint(lang.l("home.accessibility.next_lesson_hint"))
    }

    // MARK: - 今日の統計

    private var todayStatsCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("home.today_study"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            HStack(spacing: AppLayout.paddingLG) {
                StatItem(icon: "book.fill", value: "\(vm.todayStats.completedLessons)", label: lang.l("home.lessons"), color: AppColor.primary)
                StatItem(icon: "checkmark.circle.fill", value: "\(vm.todayStats.completedQuizzes)", label: lang.l("home.quizzes"), color: AppColor.success)
                StatItem(icon: "star.fill", value: "\(vm.todayStats.earnedXP)", label: "XP", color: AppColor.xpGold)
            }
        }
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("home.accessibility.today_study_card", vm.todayStats.completedLessons, vm.todayStats.completedQuizzes, vm.todayStats.earnedXP))
    }

    // MARK: - 最近のバッジ

    private var recentBadgesCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack {
                Text(lang.l("home.recent_badges"))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Button {
                    switchToTab?(.mypage)
                } label: {
                    Text(lang.l("home.see_all"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.primary)
                }
            }
            HStack(spacing: AppLayout.paddingMD) {
                ForEach(vm.recentBadges.prefix(4), id: \.badgeId) { badge in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: badge.colorHex).opacity(0.15))
                                .frame(width: 48, height: 48)
                            Image(systemName: badge.iconName)
                                .font(.title3)
                                .foregroundStyle(Color(hex: badge.colorHex))
                        }
                        Text(lang.l(badge.name))
                            .font(AppFont.codeSmall)
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .modifier(CardStyle())
    }

    // MARK: - 復習

    private var reviewReminderCard: some View {
        Button {
            switchToTab?(.exam)
        } label: {
            HStack(spacing: AppLayout.paddingMD) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.warning)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(lang.l("home.review_pending", vm.reviewCount))
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(lang.l("home.review_reminder"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColor.textTertiary)
                    .accessibilityHidden(true)
            }
            .modifier(CardStyle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(lang.l("home.review_pending", vm.reviewCount))
        .accessibilityHint(lang.l("home.accessibility.review_hint"))
    }

    // MARK: - 進捗

    private var progressSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("home.overall_progress"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            AnimatedProgressBar(
                progress: vm.overallProgress,
                height: 8,
                backgroundColor: AppColor.primary.opacity(0.12),
                foregroundColor: AppColor.primary
            )

            Text(lang.l("home.lessons_completed_progress", vm.totalCompleted, vm.totalLessons, Int(vm.overallProgress * 100)))
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .modifier(CardStyle())
    }

}

// MARK: - 統計アイテム

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(value)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                Text(label)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(PreviewContainer.shared)
}
