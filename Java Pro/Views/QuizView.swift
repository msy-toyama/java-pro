//
//  QuizView.swift
//  Java Pro
//
//  クイズ出題画面。8種類の出題形式を統一的に扱い、
//  回答→実行結果演出→正誤→解説のフローを提供する。
//  XP付与・バッジ判定を統合し、ゲーミフィケーション体験を実現する。
//  ビジネスロジックはQuizViewModelに委譲し、View層を薄く保つ。
//

import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var vm: QuizViewModel

    private var lang: LanguageManager { LanguageManager.shared }

    init(quizzes: [QuizData], lessonId: String? = nil, isReviewMode: Bool = false,
         onComplete: (() -> Void)? = nil, onNextLesson: ((String) -> Void)? = nil) {
        _vm = State(initialValue: QuizViewModel(
            quizzes: quizzes, lessonId: lessonId, isReviewMode: isReviewMode,
            onComplete: onComplete, onNextLesson: onNextLesson
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.quizzes.isEmpty {
                    ContentUnavailableView(
                        lang.l("quiz.no_quiz"),
                        systemImage: "questionmark.circle",
                        description: Text(lang.l("quiz.no_quiz_message"))
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(lang.l("quiz.close")) { dismiss() }
                        }
                    }
                } else if vm.showResult {
                    QuizResultView(
                        correctCount: vm.correctCount,
                        totalCount: vm.quizzes.count,
                        earnedXP: vm.earnedXP,
                        newBadges: vm.newBadges,
                        newLevel: vm.newLevel,
                        lessonId: vm.lessonId,
                        isReviewMode: vm.isReviewMode,
                        onNextLesson: vm.onNextLesson,
                        onRetry: vm.retryQuiz
                    )
                } else { quizContent }
            }
            .navigationDestination(for: PracticeChapter.self) { chapter in
                PracticeDetailView(chapter: chapter)
            }
        }
        .confettiOverlay(isActive: $vm.showConfetti)
        .overlay {
            LevelUpOverlayView(level: vm.newLevel ?? 0, isPresented: $vm.showLevelUpOverlay)
        }
    }

    // MARK: - クイズ本体

    private var quizContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
                progressBar
                quizTypeBadge

                Text(vm.currentQuiz.question)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineSpacing(4)
                    .accessibilityLabel(lang.l("quiz.question_accessibility", vm.currentIndex + 1, vm.currentQuiz.question))

                if let code = vm.currentQuiz.code, !code.isEmpty {
                    CodeBlockView(code: code)
                }

                if vm.currentQuiz.type == .codeComplete, vm.currentQuiz.codeTemplate != nil {
                    QuizCodeCompleteView(
                        quiz: vm.currentQuiz,
                        blankSelections: $vm.blankSelections,
                        isAnswered: $vm.isAnswered,
                        onSubmit: { vm.submitCodeCompleteAnswer(modelContext: modelContext, reduceMotion: reduceMotion) }
                    )
                } else if vm.currentQuiz.type == .reorder {
                    QuizReorderView(
                        quiz: vm.currentQuiz,
                        selectedOrderIds: $vm.selectedOrderIds,
                        isAnswered: $vm.isAnswered,
                        onSubmit: { vm.submitReorderAnswer(modelContext: modelContext, reduceMotion: reduceMotion) }
                    )
                } else if vm.currentQuiz.type == .multiChoice {
                    QuizMultiChoiceView(
                        quiz: vm.currentQuiz,
                        selectedChoiceIds: $vm.selectedChoiceIds,
                        isAnswered: $vm.isAnswered,
                        onSubmit: { vm.submitMultiChoiceAnswer(modelContext: modelContext, reduceMotion: reduceMotion) }
                    )
                } else {
                    choiceAnswerArea
                }

                if vm.isAnswered {
                    if vm.showExecutionResult {
                        QuizExecutionResultSection(
                            quiz: vm.currentQuiz,
                            selectedChoiceId: vm.selectedChoiceId,
                            isAnswered: vm.isAnswered
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    explanationView
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                    if vm.isCorrect { xpEarnedBanner }
                    nextButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(AppLayout.paddingMD)
            .frame(maxWidth: horizontalSizeClass == .regular ? 640 : .infinity)
            .frame(maxWidth: .infinity)
            .id(vm.currentIndex) // クイズ切替時にスクロール位置をリセット
        }
        .background(AppColor.background)
        .navigationTitle("\(vm.currentIndex + 1)/\(vm.quizzes.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(lang.l("quiz.close")) {
                    if vm.currentIndex > 0 || vm.isAnswered {
                        vm.showDismissConfirm = true
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .alert(lang.l("quiz.dismiss_confirm_title"), isPresented: $vm.showDismissConfirm) {
            Button(lang.l("quiz.dismiss_confirm_cancel"), role: .destructive) { dismiss() }
            Button(lang.l("quiz.dismiss_confirm_continue"), role: .cancel) {}
        } message: {
            Text(lang.l("quiz.dismiss_confirm_message", vm.correctCount, vm.quizzes.count))
        }
        .onAppear {
            vm.loadSettings(modelContext: modelContext)
        }
    }

    // MARK: - 進捗バー

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColor.textTertiary.opacity(0.2))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                        colors: [AppColor.primary, AppColor.primaryLight],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(
                        width: geometry.size.width * CGFloat(vm.currentIndex + (vm.isAnswered ? 1 : 0)) / CGFloat(vm.quizzes.count),
                        height: 6
                    )
                    .animation(.spring(response: 0.4), value: vm.currentIndex)
                    .animation(.spring(response: 0.4), value: vm.isAnswered)
            }
        }
        .frame(height: 6)
        .accessibilityLabel(lang.l("quiz.progress_label", vm.currentIndex + (vm.isAnswered ? 1 : 0), vm.quizzes.count))
    }

    // MARK: - クイズ種別バッジ

    private var quizTypeBadge: some View {
        let label = vm.currentQuiz.type.displayLabel
        let color = vm.currentQuiz.type.displayColor
        return Text(label)
            .font(AppFont.caption)
            .foregroundStyle(color)
            .padding(.horizontal, AppLayout.paddingSM)
            .padding(.vertical, AppLayout.paddingXS)
            .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - 選択肢（4択・穴埋め・出力予想・エラー発見）

    private var choiceAnswerArea: some View {
        VStack(spacing: AppLayout.paddingSM) {
            ForEach(vm.currentQuiz.choices.sorted { $0.order < $1.order }) { choice in
                Button {
                    guard !vm.isAnswered else { return }
                    vm.selectedChoiceId = choice.id
                    vm.submitAnswer(modelContext: modelContext, reduceMotion: reduceMotion)
                } label: {
                    HStack(spacing: AppLayout.paddingSM) {
                        Text(choice.text)
                            .font(AppFont.body)
                            .foregroundStyle(choiceTextColor(choice))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if vm.isAnswered { choiceResultIcon(choice) }
                    }
                    .padding(AppLayout.paddingMD)
                    .background(choiceBackground(choice), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                            .stroke(choiceBorderColor(choice), lineWidth: vm.isAnswered && vm.selectedChoiceId == choice.id ? 2 : 1)
                    )
                    .scaleEffect(vm.isAnswered && choice.isCorrect && vm.correctBounce ? 1.03 : 1.0)
                    .offset(x: vm.isAnswered && vm.selectedChoiceId == choice.id && !choice.isCorrect ? vm.answerShakeOffset : 0)
                }
                .buttonStyle(.pressable(scale: 0.97))
                .disabled(vm.isAnswered)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: vm.correctBounce)
                .animation(.easeInOut(duration: 0.2), value: vm.isAnswered)
                .accessibilityLabel(choice.text)
                .accessibilityValue(vm.isAnswered ? (choice.isCorrect ? lang.l("quiz.correct_label") : (vm.selectedChoiceId == choice.id ? lang.l("quiz.incorrect_label") : "")) : (vm.selectedChoiceId == choice.id ? lang.l("quiz.selected_label") : ""))
            }
        }
    }

    // MARK: - 解説

    private var explanationView: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack {
                Image(systemName: vm.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(vm.isCorrect ? AppColor.success : AppColor.error)
                    .font(.title3)
                Text(vm.isCorrect ? lang.l("quiz.correct") : lang.l("quiz.incorrect"))
                    .font(AppFont.headline)
                    .foregroundStyle(vm.isCorrect ? AppColor.success : AppColor.error)
            }
            Text(vm.currentQuiz.explanation)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .lineSpacing(4)
        }
        .padding(AppLayout.paddingMD)
        .background(
            (vm.isCorrect ? AppColor.success : AppColor.error).opacity(0.08),
            in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
        )
    }

    private var xpEarnedBanner: some View {
        let xpAmount = vm.isReviewMode
            ? GamificationService.XPAmount.reviewCorrect
            : GamificationService.XPAmount.quizCorrect
        return HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "star.fill")
                .foregroundStyle(AppColor.xpGold)
                .accessibilityHidden(true)
            Text("+\(xpAmount) XP")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.xpGold)
        }
        .padding(.horizontal, AppLayout.paddingMD)
        .padding(.vertical, AppLayout.paddingSM)
        .background(AppColor.xpGold.opacity(0.12), in: Capsule())
        .shimmer(duration: 2.0)
        .transition(.scale.combined(with: .opacity))
        .accessibilityLabel(lang.l("quiz.xp_earned_accessibility", xpAmount))
    }

    private var nextButton: some View {
        Button {
            if vm.currentIndex + 1 < vm.quizzes.count { vm.moveToNext() }
            else { vm.completeQuizSession(modelContext: modelContext) }
        } label: {
            HStack {
                Text(vm.currentIndex + 1 < vm.quizzes.count ? lang.l("quiz.next") : lang.l("quiz.show_result"))
                    .font(AppFont.headline)
                if vm.currentIndex + 1 < vm.quizzes.count {
                    Image(systemName: "arrow.right").font(.subheadline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        }
        .buttonStyle(.pressable)
    }

    // MARK: - Choice styling (QuizChoiceStyle に委譲)

    private func choiceTextColor(_ choice: QuizChoice) -> Color {
        QuizChoiceStyle.textColor(for: choice, isAnswered: vm.isAnswered, selectedId: vm.selectedChoiceId)
    }
    private func choiceBackground(_ choice: QuizChoice) -> Color {
        QuizChoiceStyle.background(for: choice, isAnswered: vm.isAnswered, selectedId: vm.selectedChoiceId)
    }
    private func choiceBorderColor(_ choice: QuizChoice) -> Color {
        QuizChoiceStyle.borderColor(for: choice, isAnswered: vm.isAnswered, selectedId: vm.selectedChoiceId)
    }
    @ViewBuilder
    private func choiceResultIcon(_ choice: QuizChoice) -> some View {
        QuizChoiceStyle.resultIcon(for: choice, selectedId: vm.selectedChoiceId, selectedIds: vm.selectedChoiceIds)
    }
}
