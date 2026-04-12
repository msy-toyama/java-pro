//
//  ProfileView.swift
//  Java Pro
//
//  ユーザープロフィール画面。レベル・XP・バッジ・学習統計を表示する。
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var userLevel = 1
    @State private var totalXP = 0
    @State private var levelTitle = LanguageManager.shared.l("home.default_title")
    @State private var levelProgress: Double = 0
    @State private var totalLessonsCompleted = 0
    @State private var totalQuizzesCorrect = 0
    @State private var currentStreak = 0
    @State private var earnedBadges: [UserBadge] = []
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppLayout.paddingLG) {
                    // プロフィールヘッダー
                    profileHeader
                        .staggeredAppear(index: 0)

                    // XP 統計
                    xpStatsCard
                        .staggeredAppear(index: 1)

                    // 学習統計
                    learningStatsCard
                        .staggeredAppear(index: 2)

                    // 獲得バッジ
                    earnedBadgesSection
                        .staggeredAppear(index: 3)

                    // 未獲得バッジ
                    lockedBadgesSection
                        .staggeredAppear(index: 4)
                }
                .padding(AppLayout.paddingMD)
                .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(AppColor.background)
            .navigationTitle(lang.l("profile.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { BrandedTitleView(title: lang.l("profile.title"), icon: "person.fill") } }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .accessibilityLabel(lang.l("profile.settings"))
                }
            }
            .onAppear(perform: loadData)
        }
    }

    // MARK: - ヘッダー

    private var profileHeader: some View {
        VStack(spacing: AppLayout.paddingMD) {
            // レベルサークル
            ZStack {
                Circle()
                    .stroke(AppColor.levelPurple.opacity(0.2), lineWidth: 6)
                    .frame(width: 100, height: 100)
                Circle()
                    .trim(from: 0, to: levelProgress)
                    .stroke(
                        LinearGradient(
                            colors: [AppColor.levelPurple, AppColor.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(userLevel)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.levelPurple)
                    Text("Lv")
                        .font(AppFont.codeSmall)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }

            Text(levelTitle)
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(AppColor.xpGold)
                    .font(.caption)
                Text("\(totalXP) XP")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.xpGold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppLayout.paddingLG)
    }

    // MARK: - XP統計

    private var xpStatsCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("profile.xp_progress"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            AnimatedProgressBar(
                progress: levelProgress,
                height: 10,
                backgroundColor: AppColor.levelPurple.opacity(0.12),
                gradient: LinearGradient(
                    colors: [AppColor.levelPurple, AppColor.primary],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                cornerRadius: 6
            )

            HStack {
                Text("Lv.\(userLevel)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer()
                Text("Lv.\(min(userLevel + 1, 50))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .modifier(CardStyle())
    }

    // MARK: - 学習統計

    private var learningStatsCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("profile.stats"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppLayout.paddingMD) {
                profileStat(value: "\(totalLessonsCompleted)", label: lang.l("profile.lessons_completed"), icon: "book.fill", color: AppColor.primary)
                profileStat(value: "\(totalQuizzesCorrect)", label: lang.l("profile.quiz_correct"), icon: "checkmark.circle.fill", color: AppColor.success)
                profileStat(value: "\(currentStreak)", label: lang.l("profile.streak_days"), icon: "flame.fill", color: AppColor.accent)
            }
        }
        .modifier(CardStyle())
    }

    private func profileStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)
            Text(label)
                .font(AppFont.codeSmall)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppLayout.paddingSM)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - 獲得バッジ

    private var earnedBadgesSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack {
                Text(lang.l("profile.badges_earned_count", earnedBadges.count))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                NavigationLink(destination: BadgeListView()) {
                    Text(lang.l("profile.see_all"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.primary)
                }
            }

            if earnedBadges.isEmpty {
                Text(lang.l("profile.no_badges"))
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(AppLayout.paddingLG)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppLayout.paddingMD) {
                    ForEach(earnedBadges, id: \.badgeId) { badge in
                        earnedBadgeCell(badge)
                    }
                }
            }
        }
        .modifier(CardStyle())
    }

    private func earnedBadgeCell(_ badge: UserBadge) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(hex: badge.colorHex).opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: badge.iconName)
                    .font(.title3)
                    .foregroundStyle(Color(hex: badge.colorHex))
            }
            Text(lang.l(badge.name))
                .font(AppFont.codeSmall)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("profile.badge_earned_label", lang.l(badge.name)))
    }

    // MARK: - 未獲得バッジ

    private var lockedBadgesSection: some View {
        let earnedIds = Set(earnedBadges.map(\.badgeId))
        let locked = GamificationService.badgeDefinitions.filter { !earnedIds.contains($0.id) }

        return Group {
            if !locked.isEmpty {
                VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
                    Text(lang.l("profile.locked_badges"))
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppLayout.paddingMD) {
                        ForEach(locked.indices, id: \.self) { index in
                            lockedBadgeCell(locked[index])
                        }
                    }
                }
                .modifier(CardStyle())
            }
        }
    }

    private func lockedBadgeCell(_ def: (id: String, nameKey: String, descriptionKey: String, icon: String, color: String, condition: String)) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(AppColor.textTertiary.opacity(0.1))
                    .frame(width: 52, height: 52)
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(AppColor.textTertiary)
            }
            Text(lang.l(def.nameKey))
                .font(AppFont.codeSmall)
                .foregroundStyle(AppColor.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("profile.badge_locked_label", lang.l(def.nameKey)))
    }

    // MARK: - Data

    private func loadData() {
        let progressService = ProgressService(modelContext: modelContext)
        let gamificationService = GamificationService(modelContext: modelContext)

        let level = gamificationService.getUserLevel()
        userLevel = level.level
        totalXP = level.totalXP
        levelProgress = gamificationService.progressToNextLevel()
        levelTitle = gamificationService.currentTitle()

        totalLessonsCompleted = progressService.totalCompletedLessonCount()
        currentStreak = progressService.currentStreak()
        earnedBadges = gamificationService.getEarnedBadges()

        // 累計正解クイズ数を実績データから取得
        totalQuizzesCorrect = progressService.totalCorrectQuizCount()
    }
}
