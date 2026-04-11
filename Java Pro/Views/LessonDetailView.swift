//
//  LessonDetailView.swift
//  Java Pro
//
//  レッスン本文表示画面。セクションごとに概要・ルール・コード・ポイントを表示し、
//  最後にクイズへ遷移するボタンを配置する。
//  スクロール連動アニメーション・段階的フェードイン・リッチカードで最高品質UIを実現。
//

import SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let lesson: LessonData
    var navigationPath: Binding<NavigationPath>?

    @State private var showQuiz = false
    @State private var isCompleted = false
    @State private var showCompletionBanner = false
    @State private var visibleSections: Set<Int> = []
    @State private var headerAppeared = false
    @State private var quizButtonScale: CGFloat = 1.0
    @State private var navigateToNextLesson: String?

    private var sortedSections: [LessonSection] {
        lesson.contents.sorted { $0.order < $1.order }
    }

    /// このレッスンが属するコースに対応する実践演習チャプター
    private var relatedPracticeChapter: PracticeChapter? {
        // lessonId "ch02_01" → courseId "ch02"
        let courseId = String(lesson.id.prefix(while: { $0 != "_" }))
        // 末尾が数字で終わるchXXの前にある'_'を無視（ch02_01→ch02）
        return PracticeService.shared.practiceChapters.first { $0.id == courseId }
    }

    var body: some View {
        scrollContent
            .background(AppColor.background)
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                if navigationPath != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            navigationPath?.wrappedValue = NavigationPath()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "list.bullet")
                                Text("一覧")
                                    .font(AppFont.caption)
                            }
                        }
                        .accessibilityLabel("学習一覧へ戻る")
                    }
                }
            }
            .overlay(alignment: .top) {
                if showCompletionBanner {
                    completionBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showQuiz) {
                QuizView(quizzes: lesson.quizzes, lessonId: lesson.id, onComplete: {
                    withAnimation(AppAnimation.spring) {
                        isCompleted = true
                        showCompletionBanner = true
                    }
                    let settings = ProgressService(modelContext: modelContext).getSettings()
                    if settings.hapticFeedbackEnabled {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                    SoundService.shared.play(.lessonComplete)
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        withAnimation { showCompletionBanner = false }
                    }
                }, onNextLesson: { nextLessonId in
                    navigateToNextLesson = nextLessonId
                })
                .interactiveDismissDisabled(true) // クイズ中のスワイプ中断を防止
            }
            .navigationDestination(item: $navigateToNextLesson) { nextId in
                if let nextLesson = ContentService.shared.getLesson(id: nextId) {
                    LessonDetailView(lesson: nextLesson, navigationPath: navigationPath)
                } else {
                    ContentUnavailableView(
                        "レッスンが見つかりません",
                        systemImage: "exclamationmark.triangle",
                        description: Text("コンテンツの読み込みに失敗しました")
                    )
                }
            }
            .onAppear {
                let service = ProgressService(modelContext: modelContext)
                // 既存の完了状態を反映（再訪問時にバッジ表示）
                if let progress = service.getLessonProgress(lessonId: lesson.id) {
                    isCompleted = progress.status == .completed
                }
                // 完了済みレッスンはinProgressに戻さない
                service.startLesson(lessonId: lesson.id)
                withAnimation(.easeOut(duration: 0.5)) {
                    headerAppeared = true
                }
            }
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                // レッスンヘッダー
                lessonHeader
                    .padding(.horizontal, AppLayout.paddingMD)
                    .padding(.bottom, AppLayout.paddingLG)

                // セクション一覧（カード形式 + フェードイン）
                ForEach(Array(sortedSections.enumerated()), id: \.element.id) { index, section in
                    sectionCard(section: section, index: index)
                        .padding(.horizontal, AppLayout.paddingMD)
                        .padding(.bottom, AppLayout.paddingMD)
                        .opacity(visibleSections.contains(index) ? 1 : 0)
                        .offset(y: visibleSections.contains(index) ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06),
                            value: visibleSections.contains(index)
                        )
                        .onAppear {
                            visibleSections.insert(index)
                        }
                }

                // 関連する実践演習へのリンク
                if let practiceChapter = relatedPracticeChapter {
                    practiceExerciseLink(chapter: practiceChapter)
                        .padding(.horizontal, AppLayout.paddingMD)
                        .padding(.top, AppLayout.paddingSM)
                }

                // クイズへ進むボタン
                if !lesson.quizzes.isEmpty {
                    quizButton
                        .padding(.horizontal, AppLayout.paddingMD)
                        .padding(.top, AppLayout.paddingSM)
                        .padding(.bottom, AppLayout.paddingXL)
                }
            }
            .padding(.top, AppLayout.paddingMD)
            .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Lesson Header

    private var lessonHeader: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            // ステータスバッジ行
            HStack(spacing: AppLayout.paddingSM) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .accessibilityHidden(true)
                    Text("約\(lesson.estimatedMinutes)分")
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.textSecondary)
                .padding(.horizontal, AppLayout.paddingSM)
                .padding(.vertical, AppLayout.paddingXS)
                .background(AppColor.textTertiary.opacity(0.1), in: Capsule())

                HStack(spacing: 4) {
                    Image(systemName: "questionmark.circle")
                        .font(.caption2)
                        .accessibilityHidden(true)
                    Text("\(lesson.quizzes.count)問")
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.primary)
                .padding(.horizontal, AppLayout.paddingSM)
                .padding(.vertical, AppLayout.paddingXS)
                .background(AppColor.primary.opacity(0.1), in: Capsule())

                Spacer()

                if isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("完了")
                            .font(AppFont.caption)
                    }
                    .foregroundStyle(AppColor.success)
                    .padding(.horizontal, AppLayout.paddingSM)
                    .padding(.vertical, AppLayout.paddingXS)
                    .background(AppColor.success.opacity(0.1), in: Capsule())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .opacity(headerAppeared ? 1 : 0)
            .offset(y: headerAppeared ? 0 : 10)

            // サマリー
            Text(lesson.summary)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(3)
                .opacity(headerAppeared ? 1 : 0)
                .offset(y: headerAppeared ? 0 : 10)

            // セクション数インジケータ
            HStack(spacing: 6) {
                ForEach(0..<sortedSections.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(visibleSections.contains(index) ? sectionColorForIndex(index) : AppColor.textTertiary.opacity(0.2))
                        .frame(height: 3)
                        .animation(.easeInOut(duration: 0.3), value: visibleSections.contains(index))
                }
            }
            .padding(.top, AppLayout.paddingXS)
        }
    }

    private func sectionColorForIndex(_ index: Int) -> Color {
        guard index < sortedSections.count else { return AppColor.primary }
        let section = sortedSections[index]
        return SectionView.color(for: section.sectionType)
    }

    // MARK: - Section Card

    private func sectionCard(section: LessonSection, index: Int) -> some View {
        SectionView(section: section, sectionNumber: index + 1, totalSections: sortedSections.count)
    }

    // MARK: - Quiz Button

    private var quizButton: some View {
        Button {
            showQuiz = true
        } label: {
            HStack(spacing: AppLayout.paddingSM) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("クイズに挑戦")
                        .font(AppFont.headline)
                    Text("\(lesson.quizzes.count)問のクイズで理解度をチェック")
                        .font(.system(size: 11))
                        .opacity(0.85)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.white)
            .padding(AppLayout.paddingMD)
            .background(
                LinearGradient(
                    colors: [AppColor.primary, AppColor.primaryDark],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
            )
            .shadow(color: AppColor.primary.opacity(0.3), radius: 8, y: 4)
        }
        .scaleEffect(quizButtonScale)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                quizButtonScale = pressing ? 0.96 : 1.0
            }
        }, perform: {})
    }

    // MARK: - Completion Banner

    private var completionBanner: some View {
        HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "party.popper.fill")
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("レッスン完了！")
                    .font(AppFont.headline)
                Text("おめでとうございます 🎉")
                    .font(AppFont.caption)
                    .opacity(0.9)
            }
        }
        .foregroundStyle(.white)
        .padding(AppLayout.paddingMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppColor.success, Color(hex: "059669")],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
        )
        .shadow(color: AppColor.success.opacity(0.3), radius: 8, y: 4)
        .padding(.horizontal, AppLayout.paddingMD)
        .padding(.top, AppLayout.paddingSM)
    }

    // MARK: - Practice Exercise Link

    private func practiceExerciseLink(chapter: PracticeChapter) -> some View {
        NavigationLink(value: chapter) {
            HStack(spacing: AppLayout.paddingSM) {
                ZStack {
                    Circle()
                        .fill(AppColor.practiceIndigo.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.practiceIndigo)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("関連する実践演習")
                        .font(AppFont.callout)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(chapter.title) — \(chapter.exercises.count)問の演習")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(AppLayout.paddingMD)
            .background(AppColor.practiceIndigo.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(AppColor.practiceIndigo.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// SectionView, RichBodyView, MarkdownTableView → Views/Components/SectionView.swift, RichBodyView.swift
// CodeBlockView → Views/Components/CodeBlockView.swift
