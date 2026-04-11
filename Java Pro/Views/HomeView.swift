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
                }
                .background(AppColor.background)
                .navigationTitle("ホーム")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .principal) { BrandedTitleView(title: "ホーム", icon: "house.fill", subtitle: "プロプロ") } }
                .onAppear { vm.loadData(modelContext: modelContext) }
            } else {
            ScrollView {
                let isWide = horizontalSizeClass == .regular
                let columns = isWide
                    ? [GridItem(.flexible(), spacing: AppLayout.paddingMD),
                       GridItem(.flexible(), spacing: AppLayout.paddingMD)]
                    : [GridItem(.flexible())]

                LazyVGrid(columns: columns, spacing: AppLayout.paddingLG) {
                    levelCard
                        .gridCellColumns(isWide ? 2 : 1)
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
                        .gridCellColumns(isWide ? 2 : 1)
                        .staggeredAppear(index: 7)
                }
                .padding(AppLayout.paddingMD)
            }
            .background(AppColor.background)
            .refreshable { vm.loadData(modelContext: modelContext) }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { BrandedTitleView(title: "ホーム", icon: "house.fill", subtitle: "プロプロ") } }
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
                    Text("今日のXP")
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
        .accessibilityLabel("レベル\(vm.userLevel) \(vm.levelTitle)、合計\(vm.totalXP)XP、今日+\(vm.todayStats.earnedXP)XP")
    }

    // MARK: - ストリーク

    private var streakCard: some View {
        HStack(spacing: AppLayout.paddingMD) {
            VStack(spacing: 4) {
                Text("\(vm.todayStats.streak)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(vm.todayStats.streak > 0 ? AppColor.accent : AppColor.textTertiary)
                Text("日連続")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(width: 100)

            VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
                Text(vm.streakMessage)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text("毎日少しずつ学び続けましょう")
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
        .accessibilityLabel("\(vm.todayStats.streak)日連続学習、\(vm.streakMessage)")
    }

    // MARK: - 今日の目標

    private var dailyGoalCard: some View {
        let progress = vm.dailyGoalProgress

        return VStack(spacing: AppLayout.paddingSM) {
            HStack {
                Image(systemName: progress >= 1.0 ? "target" : "scope")
                    .foregroundStyle(progress >= 1.0 ? AppColor.success : AppColor.primary)
                    .accessibilityHidden(true)
                Text("今日の目標")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text("\(vm.todayStats.studyMinutes)/\(vm.dailyGoalMinutes)分")
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
                    Text("目標達成！お疲れさまです 🎉")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.success)
                }
            }
        }
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日の目標、\(vm.todayStats.studyMinutes)分の\(vm.dailyGoalMinutes)分達成\(progress >= 1.0 ? "、目標達成" : "")")
    }

    // MARK: - おすすめレッスン

    private func recommendedCard(lesson: LessonData) -> some View {
        NavigationLink(value: lesson) {
            HStack(spacing: AppLayout.paddingMD) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("次のレッスン")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(lesson.title)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("約\(lesson.estimatedMinutes)分")
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
        .accessibilityLabel("次のレッスン: \(lesson.title)、約\(lesson.estimatedMinutes)分")
        .accessibilityHint("レッスンを開始します")
    }

    // MARK: - 今日の統計

    private var todayStatsCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text("今日の学習")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            HStack(spacing: AppLayout.paddingLG) {
                StatItem(icon: "book.fill", value: "\(vm.todayStats.completedLessons)", label: "レッスン", color: AppColor.primary)
                StatItem(icon: "checkmark.circle.fill", value: "\(vm.todayStats.completedQuizzes)", label: "クイズ", color: AppColor.success)
                StatItem(icon: "star.fill", value: "\(vm.todayStats.earnedXP)", label: "XP", color: AppColor.xpGold)
            }
        }
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日の学習、レッスン\(vm.todayStats.completedLessons)、クイズ\(vm.todayStats.completedQuizzes)、XP\(vm.todayStats.earnedXP)")
    }

    // MARK: - 最近のバッジ

    private var recentBadgesCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack {
                Text("最近獲得したバッジ")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Button {
                    switchToTab?(.mypage)
                } label: {
                    Text("すべて見る")
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
                        Text(badge.name)
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
                    Text("復習が \(vm.reviewCount)件 あります")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("忘れる前に復習しましょう")
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
        .accessibilityLabel("復習が\(vm.reviewCount)件あります")
        .accessibilityHint("復習タブに移動します")
    }

    // MARK: - 進捗

    private var progressSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text("全体の進捗")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            AnimatedProgressBar(
                progress: vm.overallProgress,
                height: 8,
                backgroundColor: AppColor.primary.opacity(0.12),
                foregroundColor: AppColor.primary
            )

            Text("\(vm.totalCompleted) / \(vm.totalLessons) レッスン完了（\(Int(vm.overallProgress * 100))%）")
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
