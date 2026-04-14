//
//  CourseListView.swift
//  Java Pro
//
//  コース一覧画面。全コースをカード形式で表示し、
//  各コースの進捗率とロック状態をアニメーション付きで表示する。
//

import SwiftUI
import SwiftData

struct CourseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var courses: [CourseIndex] = []
    @State private var completedCounts: [String: Int] = [:]
    @State private var showPaywall = false
    @State private var appearedItems: Set<String> = []
    @State private var showGuideTour = false
    @State private var showPracticeTour = false
    @State private var navigationPath = NavigationPath()
    @State private var selectedMode: LearnMode = .course
    @State private var collapsedSections: Set<String> = []
    private var lang: LanguageManager { LanguageManager.shared }

    /// 学習モード切替
    enum LearnMode: CaseIterable {
        case course
        case practice
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // モード切替 Picker
                Picker(lang.l("learn.mode.label"), selection: $selectedMode) {
                    ForEach(LearnMode.allCases, id: \.self) { mode in
                        Text(mode == .course ? lang.l("learn.mode.textbook") : lang.l("learn.mode.practice")).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppLayout.paddingMD)
                .padding(.vertical, AppLayout.paddingSM)

                switch selectedMode {
                case .course:
                    courseListContent
                case .practice:
                    PracticeListView()
                }
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
            .frame(maxWidth: .infinity)
            .background(AppColor.background)
            .navigationTitle(lang.l("learn.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandedTitleView(title: lang.l("learn.title"), icon: "book.fill", subtitle: lang.l("learn.courses"))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        GlossaryView()
                    } label: {
                        Image(systemName: "character.book.closed.fill")
                            .foregroundStyle(AppColor.primary)
                    }
                    .accessibilityLabel(lang.l("learn.glossary"))
                }
            }
            .navigationDestination(for: CourseIndex.self) { course in
                LessonListView(course: course, navigationPath: $navigationPath)
            }
            .navigationDestination(for: PracticeChapter.self) { chapter in
                PracticeDetailView(chapter: chapter)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onAppear {
                loadData()
                PracticeService.shared.loadPracticeData()
                if !showGuideTour && !UserDefaults.standard.hasSeenLearnTour {
                    Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        showGuideTour = true
                    }
                }
            }
            .onChange(of: selectedMode) { _, newMode in
                if newMode == .practice && !showPracticeTour && !showGuideTour && !UserDefaults.standard.hasSeenPracticeTour {
                    Task {
                        try? await Task.sleep(for: .milliseconds(400))
                        showPracticeTour = true
                    }
                }
            }
            .overlay {
                if showGuideTour {
                    GuideTourOverlay(steps: GuideTourSteps.learn) {
                        showGuideTour = false
                        UserDefaults.standard.hasSeenLearnTour = true
                    }
                } else if showPracticeTour {
                    GuideTourOverlay(steps: GuideTourSteps.practice) {
                        showPracticeTour = false
                        UserDefaults.standard.hasSeenPracticeTour = true
                    }
                }
            }
        }
    }

    // MARK: - Course List Content (教材学習)

    private var courseListContent: some View {
        ScrollView {
            LazyVStack(spacing: AppLayout.paddingSM + 2) {
                // セクション分け: 無料 / Silver / Gold
                let grouped = groupedCourses

                ForEach(grouped, id: \.title) { section in
                    let isCollapsed = collapsedSections.contains(section.title)

                    sectionHeader(section.title, icon: section.icon, color: section.color, isCollapsed: isCollapsed, count: section.courses.count)
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
                        ForEach(Array(section.courses.enumerated()), id: \.element.id) { index, course in
                            let accessible = StoreService.shared.canAccess(
                                courseId: course.id,
                                certLevel: course.certificationLevel
                            )
                            Group {
                                if accessible {
                                    NavigationLink(value: course) {
                                        CourseCardView(
                                            course: course,
                                            completedCount: completedCounts[course.id] ?? 0,
                                            isLocked: false
                                        )
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.pressable)
                                    .accessibilityLabel(lang.l("learn.course_lessons_completed", course.title, completedCounts[course.id] ?? 0, course.lessonCount))
                                    .accessibilityHint(lang.l("learn.open_lesson_list"))
                                } else {
                                    Button { showPaywall = true } label: {
                                        CourseCardView(
                                            course: course,
                                            completedCount: completedCounts[course.id] ?? 0,
                                            isLocked: true
                                        )
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.pressable)
                                    .accessibilityLabel(lang.l("learn.course_locked", course.title))
                                    .accessibilityHint(lang.l("learn.show_premium_hint"))
                                }
                            }
                            .opacity(appearedItems.contains(course.id) ? 1 : 0)
                            .offset(y: appearedItems.contains(course.id) ? 0 : (reduceMotion ? 0 : 16))
                            .animation(
                                reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.85)
                                .delay(Double(index) * 0.04),
                                value: appearedItems.contains(course.id)
                            )
                            .onAppear {
                                appearedItems.insert(course.id)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                }
                .padding(AppLayout.paddingMD)
            }
        }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String, color: Color, isCollapsed: Bool = false, count: Int = 0) -> some View {
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

    // MARK: - Grouped Courses

    private struct CourseSection {
        let title: String
        let icon: String
        let color: Color
        let courses: [CourseIndex]
    }

    /// カテゴリ定義: 表示順・ラベル・アイコン・カラーのマッピング
    private static let categoryDefinitions: [(key: String, titleKey: String, icon: String, color: Color)] = [
        ("basics",            "learn.category.basics",          "book.fill",                         AppColor.success),
        ("oop",               "learn.category.oop",        "cube.fill",                         Color(hex: "#6366F1")),
        ("error_handling",    "learn.category.errorhandling",          "exclamationmark.shield.fill",       AppColor.error),
        ("standard_library",  "learn.category.api",     "shippingbox.fill",                  Color(hex: "#06B6D4")),
        ("data_collections",  "learn.category.generics",    "tray.2.fill",                       Color(hex: "#3B82F6")),
        ("functional_stream", "learn.category.functional",         "chevron.left.forwardslash.chevron.right", Color(hex: "#10B981")),
        ("database_web",      "learn.category.web",      "globe",                             Color(hex: "#F97316")),
        ("concurrency_io",    "learn.category.concurrency",      "arrow.triangle.branch",             Color(hex: "#D946EF")),
        ("modules_i18n",      "learn.category.modules",          "square.grid.3x3.fill",              Color(hex: "#F59E0B")),
        ("exam_practice",     "learn.category.exam",               "trophy.fill",                       AppColor.accent),
    ]

    private var groupedCourses: [CourseSection] {
        var sections: [CourseSection] = []
        for def in Self.categoryDefinitions {
            let matched = courses
                .filter { $0.category == def.key }
                .sorted { $0.order < $1.order }
            if !matched.isEmpty {
                sections.append(CourseSection(
                    title: LanguageManager.shared.l(def.titleKey),
                    icon: def.icon,
                    color: def.color,
                    courses: matched
                ))
            }
        }
        // 未分類コース（category が nil または未知の値）
        let knownKeys = Set(Self.categoryDefinitions.map(\.key))
        let uncategorized = courses.filter { knownKeys.contains($0.category ?? "") == false }
        if !uncategorized.isEmpty {
            sections.append(CourseSection(title: LanguageManager.shared.l("learn.category.other"), icon: "folder", color: AppColor.textSecondary, courses: uncategorized))
        }
        return sections
    }

    private func loadData() {
        courses = ContentService.shared.getAllCourses()
        let progressService = ProgressService(modelContext: modelContext)
        // バッチフェッチ: 全完了レッスンIDを1回で取得し、コース別に集計
        let allCompletedIds = progressService.allCompletedLessonIds()
        for course in courses {
            let lessonIds = Set(ContentService.shared.getLessons(courseId: course.id).map(\.id))
            completedCounts[course.id] = allCompletedIds.filter { lessonIds.contains($0) }.count
        }
    }
}

// MARK: - コースカード

struct CourseCardView: View {
    let course: CourseIndex
    let completedCount: Int
    var isLocked: Bool = false
    private var lang: LanguageManager { LanguageManager.shared }

    private var progress: Double {
        course.lessonCount > 0 ? Double(completedCount) / Double(course.lessonCount) : 0
    }

    private var courseColor: Color {
        AppColor.chapterColor(order: course.order)
    }

    var body: some View {
        HStack(spacing: AppLayout.paddingMD) {
            // アイコン
            ZStack {
                RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                    .fill(
                        LinearGradient(
                            colors: [courseColor.opacity(0.18), courseColor.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: course.iconName)
                    .font(.title2)
                    .foregroundStyle(courseColor)
                    .accessibilityHidden(true)

                // 完了バッジ
                if progress >= 1.0 {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(AppColor.success)
                                .background(Circle().fill(AppColor.cardBackground).padding(-1))
                        }
                        Spacer()
                    }
                    .frame(width: 52, height: 52)
                }
            }

            // テキスト
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(AppFont.headline)
                    .foregroundStyle(isLocked ? AppColor.textTertiary : AppColor.textPrimary)
                Text(course.subtitle)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)

                // 進捗バー
                if !isLocked {
                    HStack(spacing: AppLayout.paddingSM) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2.5)
                                    .fill(courseColor.opacity(0.12))
                                RoundedRectangle(cornerRadius: 2.5)
                                    .fill(
                                        LinearGradient(
                                            colors: [courseColor, courseColor.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress)
                            }
                        }
                        .frame(height: 5)
                        Text("\(completedCount)/\(course.lessonCount)")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(AppColor.textTertiary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColor.accent)
                        Text(lang.l("learn.premium"))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppColor.accent)
                    }
                }
            }

            Spacer()

            Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                .font(.caption)
                .foregroundStyle(isLocked ? AppColor.accent : AppColor.textTertiary)
                .accessibilityHidden(true)
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
}

#Preview {
    NavigationStack {
        CourseListView()
    }
    .modelContainer(PreviewContainer.shared)
}
