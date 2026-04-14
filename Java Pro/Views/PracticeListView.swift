//
//  PracticeListView.swift
//  Java Pro
//
//  実践演習一覧画面。教材学習と同じカテゴリ分けで演習問題を表示し、
//  環境構築ガイドへのリンクも提供する。
//

import SwiftUI

struct PracticeListView: View {
    @State private var showPaywall = false
    @State private var appearedItems: Set<String> = []
    @State private var collapsedSections: Set<String> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var lang: LanguageManager { LanguageManager.shared }

    private var chapters: [PracticeChapter] {
        PracticeService.shared.practiceChapters
    }

    /// カテゴリ定義: 教材学習と同じ並び順・ラベル・アイコン・カラー
    private var categoryDefinitions: [(key: String, title: String, icon: String, color: Color)] {[
        ("basics",            lang.l("learn.category.basics"),          "book.fill",                         AppColor.success),
        ("oop",               lang.l("learn.category.oop"),        "cube.fill",                         Color(hex: "#6366F1")),
        ("error_handling",    lang.l("learn.category.errorhandling"),          "exclamationmark.shield.fill",       AppColor.error),
        ("standard_library",  lang.l("learn.category.api"),     "shippingbox.fill",                  Color(hex: "#06B6D4")),
        ("data_collections",  lang.l("learn.category.generics"),    "tray.2.fill",                       Color(hex: "#3B82F6")),
        ("functional_stream", lang.l("learn.category.functional"),         "chevron.left.forwardslash.chevron.right", Color(hex: "#10B981")),
        ("database_web",      lang.l("learn.category.web"),      "globe",                             Color(hex: "#F97316")),
        ("concurrency_io",    lang.l("learn.category.concurrency"),      "arrow.triangle.branch",             Color(hex: "#D946EF")),
        ("modules_i18n",      lang.l("learn.category.modules"),          "square.grid.3x3.fill",              Color(hex: "#F59E0B")),
    ]}

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppLayout.paddingSM + 2) {
                // エラー表示
                if let error = PracticeService.shared.loadError {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColor.error)
                        Text(error)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(AppLayout.paddingMD)
                    .frame(maxWidth: .infinity)
                    .background(AppColor.error.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                }

                // 環境構築ガイドカード
                setupGuideCard
                    .padding(.bottom, AppLayout.paddingSM)

                // カテゴリ別セクション
                let grouped = groupedChapters

                ForEach(grouped, id: \.title) { section in
                    let isCollapsed = collapsedSections.contains(section.title)

                    categoryHeader(section.title, icon: section.icon, color: section.color, isCollapsed: isCollapsed, count: section.chapters.count)
                        .padding(.top, section.title == grouped.first?.title ? 0 : AppLayout.paddingSM)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                if isCollapsed {
                                    collapsedSections.remove(section.title)
                                } else {
                                    collapsedSections.insert(section.title)
                                }
                            }
                        }

                    if !isCollapsed {
                        ForEach(Array(section.chapters.enumerated()), id: \.element.id) { index, chapter in
                            let accessible = StoreService.shared.canAccess(
                                courseId: chapter.id,
                                certLevel: chapter.certificationLevel
                            )
                            Group {
                                if accessible {
                                    NavigationLink(value: chapter) {
                                        PracticeChapterCard(chapter: chapter, isLocked: false)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.pressable)
                                    .accessibilityLabel(lang.l("practice.exercises_count", chapter.title, chapter.exercises.count))
                                    .accessibilityHint(lang.l("practice.open_exercises_hint"))
                                } else {
                                    Button { showPaywall = true } label: {
                                        PracticeChapterCard(chapter: chapter, isLocked: true)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.pressable)
                                    .accessibilityLabel(lang.l("practice.locked_label", chapter.title))
                                    .accessibilityHint(lang.l("practice.premium_hint"))
                                }
                            }
                            .opacity(appearedItems.contains(chapter.id) ? 1 : 0)
                            .offset(y: appearedItems.contains(chapter.id) ? 0 : (reduceMotion ? 0 : 16))
                            .animation(
                                reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.85)
                                .delay(Double(index) * 0.04),
                                value: appearedItems.contains(chapter.id)
                            )
                            .onAppear { appearedItems.insert(chapter.id) }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(AppLayout.paddingMD)
            .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppColor.background)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Setup Guide Card

    private var setupGuideCard: some View {
        NavigationLink {
            EnvironmentSetupView()
        } label: {
            HStack(spacing: AppLayout.paddingMD) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.success.opacity(0.18), AppColor.success.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.title2)
                        .foregroundStyle(AppColor.success)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.l("practice.env_guide"))
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(lang.l("practice.env_guide_desc"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(AppLayout.paddingMD)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(AppColor.success.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(lang.l("practice.env_guide"))
        .accessibilityHint(lang.l("practice.env_guide_hint"))
    }

    // MARK: - Category Header

    private func categoryHeader(_ title: String, icon: String, color: Color, isCollapsed: Bool = false, count: Int = 0) -> some View {
        HStack(spacing: AppLayout.paddingSM) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            if isCollapsed {
                Text("\(count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.1), in: Capsule())
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColor.textTertiary)
                .rotationEffect(.degrees(isCollapsed ? -90 : 0))
        }
        .padding(.horizontal, AppLayout.paddingXS)
        .contentShape(Rectangle())
    }

    // MARK: - Grouped Chapters (カテゴリ別)

    private struct CategorySection {
        let title: String
        let icon: String
        let color: Color
        let chapters: [PracticeChapter]
    }

    private var groupedChapters: [CategorySection] {
        var sections: [CategorySection] = []
        for def in categoryDefinitions {
            let matched = chapters.filter { $0.category == def.key }
            if !matched.isEmpty {
                sections.append(CategorySection(
                    title: def.title,
                    icon: def.icon,
                    color: def.color,
                    chapters: matched
                ))
            }
        }
        return sections
    }
}

// MARK: - Practice Chapter Card

private struct PracticeChapterCard: View {
    let chapter: PracticeChapter
    var isLocked: Bool = false
    private var lang: LanguageManager { LanguageManager.shared }

    private var chapterColor: Color {
        // カテゴリに応じた色を返す
        let colorMap: [String: Color] = [
            "basics": AppColor.success,
            "oop": Color(hex: "#6366F1"),
            "error_handling": AppColor.error,
            "standard_library": Color(hex: "#06B6D4"),
            "data_collections": Color(hex: "#3B82F6"),
            "functional_stream": Color(hex: "#10B981"),
            "database_web": Color(hex: "#F97316"),
            "concurrency_io": Color(hex: "#D946EF"),
            "modules_i18n": Color(hex: "#F59E0B"),
        ]
        return colorMap[chapter.category] ?? AppColor.textSecondary
    }

    var body: some View {
        HStack(spacing: AppLayout.paddingMD) {
            ZStack {
                RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                    .fill(
                        LinearGradient(
                            colors: [chapterColor.opacity(0.18), chapterColor.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                VStack(spacing: 0) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(chapterColor)
                    Text(lang.l("common.quiz_count", chapter.exercises.count))
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(chapterColor.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title)
                    .font(AppFont.headline)
                    .foregroundStyle(isLocked ? AppColor.textTertiary : AppColor.textPrimary)
                    .lineLimit(1)
                Text(chapter.subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)

                if isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColor.accent)
                        Text(lang.l("practice.premium"))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppColor.accent)
                    }
                } else {
                    difficultyIndicator
                }
            }

            Spacer()

            Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                .font(.caption)
                .foregroundStyle(isLocked ? AppColor.accent : AppColor.textTertiary)
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(isLocked ? AppColor.accent.opacity(0.15) : Color.clear, lineWidth: 1)
        )
        .opacity(isLocked ? 0.85 : 1.0)
    }

    private var difficultyIndicator: some View {
        let maxDiff = chapter.exercises.map(\.difficulty).max() ?? 1
        let label = switch maxDiff {
        case 1: lang.l("practice.difficulty.beginner")
        case 2: lang.l("practice.difficulty.intermediate")
        default: lang.l("practice.difficulty.advanced")
        }
        return HStack(spacing: 2) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= maxDiff ? chapterColor : chapterColor.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(AppColor.textTertiary)
        }
    }
}


#Preview {
    NavigationStack {
        PracticeListView()
    }
}
