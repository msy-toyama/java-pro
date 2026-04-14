//
//  LessonListView.swift
//  Java Pro
//
//  特定コース内のレッスン一覧。各レッスンの進捗状態を
//  ステップコネクタとアニメーションで視覚的に表示する。
//

import SwiftUI
import SwiftData

struct LessonListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let course: CourseIndex
    @Binding var navigationPath: NavigationPath

    @State private var lessons: [LessonData] = []
    @State private var progressMap: [String: LessonStatus] = [:]
    @State private var appearedItems: Set<String> = []
    private var lang: LanguageManager { LanguageManager.shared }

    private var courseColor: Color {
        AppColor.chapterColor(order: course.order)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                // ヘッダー
                courseHeader
                    .padding(.bottom, AppLayout.paddingLG)

                // レッスンリスト（ステップインジケータ付き）
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    let status = progressMap[lesson.id] ?? .notStarted
                    let isLast = index == lessons.count - 1

                    NavigationLink(value: lesson) {
                        HStack(alignment: .top, spacing: 0) {
                            // ステップインジケータ
                            stepIndicator(index: index, status: status, isLast: isLast)

                            // コンテンツカード
                            LessonRowView(
                                lesson: lesson,
                                status: status,
                                color: courseColor,
                                lessonNumber: index + 1
                            )
                        }
                    }
                    .buttonStyle(.pressable)
                    .opacity(appearedItems.contains(lesson.id) ? 1 : 0)
                    .offset(x: appearedItems.contains(lesson.id) ? 0 : 24)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                        value: appearedItems.contains(lesson.id)
                    )
                    .onAppear {
                        appearedItems.insert(lesson.id)
                    }
                }
            }
            .padding(AppLayout.paddingMD)
            .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppColor.background)
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(for: LessonData.self) { lesson in
            LessonDetailView(lesson: lesson, navigationPath: $navigationPath)
        }
        .onAppear(perform: loadData)
    }

    private func stepIndicator(index: Int, status: LessonStatus, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            // 上部ライン
            if index > 0 {
                Rectangle()
                    .fill(status == .completed || progressMap[lessons[max(0, index - 1)].id] == .completed ? courseColor : AppColor.textTertiary.opacity(0.2))
                    .frame(width: 2, height: 16)
            } else {
                Spacer().frame(width: 2, height: 16)
            }

            // ドット
            ZStack {
                Circle()
                    .fill(stepDotColor(status))
                    .frame(width: 24, height: 24)
                Image(systemName: stepDotIcon(status))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }

            // 下部ライン
            if !isLast {
                Rectangle()
                    .fill(status == .completed ? courseColor : AppColor.textTertiary.opacity(0.2))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 32)
        .accessibilityHidden(true)
    }

    private func stepDotColor(_ status: LessonStatus) -> Color {
        switch status {
        case .completed: return courseColor
        case .inProgress: return courseColor.opacity(0.7)
        case .notStarted: return AppColor.textTertiary.opacity(0.3)
        }
    }

    private func stepDotIcon(_ status: LessonStatus) -> String {
        switch status {
        case .completed: return "checkmark"
        case .inProgress: return "play.fill"
        case .notStarted: return "circle.fill"
        }
    }

    private var courseHeader: some View {
        VStack(spacing: AppLayout.paddingSM) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [courseColor.opacity(0.2), courseColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: course.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(courseColor)
            }
            Text(course.subtitle)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            // 進捗バー
            let completed = lessons.filter { progressMap[$0.id] == .completed }.count
            let total = lessons.count
            if total > 0 {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(courseColor.opacity(0.12))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(courseColor)
                                .frame(width: geo.size.width * min(1.0, Double(completed) / Double(total)), height: 6)
                                .animation(.spring(response: 0.5), value: completed)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, AppLayout.paddingLG)

                    Text(lang.l("lesson_list.completed_count", completed, total))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
        }
        .padding(.vertical, AppLayout.paddingMD)
    }

    private func loadData() {
        lessons = ContentService.shared.getLessons(courseId: course.id)
        let service = ProgressService(modelContext: modelContext)
        // バッチフェッチ: 全レッスン進捗を1回のクエリで取得（N+1防止）
        let allProgress = service.allLessonProgressMap()
        for lesson in lessons {
            progressMap[lesson.id] = allProgress[lesson.id] ?? .notStarted
        }
    }
}

// MARK: - レッスン行

struct LessonRowView: View {
    let lesson: LessonData
    let status: LessonStatus
    let color: Color
    var lessonNumber: Int = 1
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        HStack(spacing: AppLayout.paddingSM) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Lesson \(lessonNumber)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(color.opacity(0.7))
                    if status == .completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColor.success)
                    }
                }
                Text(lesson.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                HStack(spacing: AppLayout.paddingSM) {
                    Label(lang.l("common.about_minutes", lesson.estimatedMinutes), systemImage: "clock")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Label(lang.l("common.quiz_count", lesson.quizzes.count), systemImage: "questionmark.circle")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColor.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lang.l("lesson_list.lesson_accessibility", lesson.title, statusLabel, lesson.estimatedMinutes))
    }

    private var statusLabel: String {
        switch status {
        case .notStarted: return lang.l("lesson_list.status.not_started")
        case .inProgress: return lang.l("lesson_list.status.in_progress")
        case .completed: return lang.l("lesson_list.status.completed")
        }
    }
}
