//
//  ExamSimulatorView.swift
//  Java Pro
//
//  模擬試験画面。80問のタイマー付き本番形式テスト。
//  フラグ機能・問題一覧パネル・中断/再開に対応する。
//  ビジネスロジックはExamSimulatorViewModelに委譲し、View層を薄く保つ。
//

import SwiftUI
import SwiftData
import UIKit

struct ExamSimulatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var vm: ExamSimulatorViewModel

    init(examId: String) {
        _vm = State(initialValue: ExamSimulatorViewModel(examId: examId))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.examFinished, let result = vm.examResult {
                    ExamResultView(
                        result: result,
                        topicScores: vm.topicScores,
                        quizzes: vm.quizzes,
                        answers: vm.answers,
                        multiAnswers: vm.multiAnswers
                    )
                } else if vm.loadError {
                    ContentUnavailableView(
                        "読み込みエラー",
                        systemImage: "exclamationmark.triangle.fill",
                        description: Text("試験問題の読み込みに失敗しました。\nアプリを再起動してお試しください。")
                    )
                } else if vm.quizzes.isEmpty {
                    loadingView
                } else {
                    examContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(!vm.examFinished)
            .interactiveDismissDisabled(!vm.examFinished)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !vm.examFinished && !vm.loadError {
                        Button("中断") { vm.showConfirmEnd = true }
                    }
                }
            }
            .alert("試験を終了しますか？", isPresented: $vm.showConfirmEnd) {
                Button("終了して採点", role: .destructive) { vm.finishExam(modelContext: modelContext) }
                Button("続ける", role: .cancel) {}
            } message: {
                Text("回答済み: \(vm.answeredCount)/\(vm.quizzes.count)問")
            }
            .onAppear { vm.loadExam(modelContext: modelContext) }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                vm.handleResignActive()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                vm.handleBecomeActive()
                if vm.remainingSeconds <= 0 && !vm.examFinished {
                    vm.finishExam(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: AppLayout.paddingLG) {
            ZStack {
                Circle()
                    .stroke(AppColor.primary.opacity(0.15), lineWidth: 4)
                    .frame(width: 60, height: 60)
                ProgressView()
                    .controlSize(.large)
                    .tint(AppColor.primary)
            }
            VStack(spacing: AppLayout.paddingSM) {
                Text("問題を読み込み中...")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text(vm.exam?.title ?? "模擬試験")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .transition(.opacity)
    }

    // MARK: - Exam Content

    private var examContent: some View {
        VStack(spacing: 0) {
            // ヘッダー: 問番号 + タイマー
            examHeader

            Divider()

            // 問題表示
            ScrollViewReader { proxy in
                ScrollView {
                    if let quiz = vm.currentQuiz {
                        questionView(quiz)
                            .padding(AppLayout.paddingMD)
                            .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
                            .frame(maxWidth: .infinity)
                            .id(vm.currentIndex)
                            .transition(.asymmetric(
                                insertion: .move(edge: vm.slideDirection).combined(with: .opacity),
                                removal: .move(edge: vm.slideDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.currentIndex)
            }

            Divider()

            // ナビゲーション
            examNavigation
        }
        .background(AppColor.background)
        .sheet(isPresented: $vm.showQuestionList) {
            questionListPanel
        }
        .task {
            // タイマー: VMに委譲
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                vm.timerTick(modelContext: modelContext)
            }
        }
    }

    // MARK: - Header

    private var examHeader: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("問 \(vm.currentIndex + 1) / \(vm.quizzes.count)")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.currentIndex)
                    Text("回答済み: \(vm.answeredCount)/\(vm.quizzes.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColor.textTertiary)
                        .contentTransition(.numericText())
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundStyle(vm.remainingSeconds < 600 ? AppColor.error : AppColor.textSecondary)
                        .symbolEffect(.pulse, options: .repeating, isActive: vm.remainingSeconds < 300)
                        .accessibilityHidden(true)
                    Text(vm.timeString)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(vm.remainingSeconds < 600 ? AppColor.error : AppColor.textPrimary)
                        .timerWarning(vm.remainingSeconds < 300)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("残り時間 \(vm.timeString)")
            }
            .padding(.horizontal, AppLayout.paddingMD)
            .padding(.vertical, AppLayout.paddingSM)

            // 進捗インジケーター
            GeometryReader { geo in
                let progress = vm.quizzes.isEmpty ? 0 : CGFloat(vm.answeredCount) / CGFloat(vm.quizzes.count)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColor.primary.opacity(0.08))
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.primary, AppColor.primaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 3)
        }
        .background(AppColor.cardBackground)
    }

    // MARK: - Question

    private func questionView(_ quiz: QuizData) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
            // クイズタイプバッジ
            if quiz.type == .multiChoice, let required = quiz.requiredSelections {
                Text("\(required)つ選択してください")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.levelPurple)
                    .padding(.horizontal, AppLayout.paddingSM)
                    .padding(.vertical, AppLayout.paddingXS)
                    .background(AppColor.levelPurple.opacity(0.12), in: Capsule())
            }

            Text(quiz.question)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
                .lineSpacing(4)
                .accessibilityLabel("問\(vm.currentIndex + 1)の問題: \(quiz.question)")

            if let code = quiz.code, !code.isEmpty {
                CodeBlockView(code: code)
            }

            // 選択肢
            ForEach(quiz.choices.sorted { $0.order < $1.order }) { choice in
                examChoiceButton(quiz: quiz, choice: choice)
            }
        }
    }

    private func examChoiceButton(quiz: QuizData, choice: QuizChoice) -> some View {
        let isMulti = quiz.type == .multiChoice
        let isSelected: Bool = isMulti
            ? (vm.multiAnswers[quiz.id]?.contains(choice.id) ?? false)
            : (vm.answers[quiz.id] == choice.id)

        return Button {
            vm.toggleChoice(quiz: quiz, choiceId: choice.id)
        } label: {
            HStack(spacing: AppLayout.paddingSM) {
                Image(systemName: isMulti
                      ? (isSelected ? "checkmark.square.fill" : "square")
                      : (isSelected ? "largecircle.fill.circle" : "circle"))
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.textTertiary)
                    .accessibilityHidden(true)

                Text(choice.text)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(AppLayout.paddingMD)
            .background(
                isSelected ? AppColor.primary.opacity(0.08) : AppColor.cardBackground,
                in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                    .stroke(isSelected ? AppColor.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .accessibilityLabel(choice.text)
        .accessibilityValue(isSelected ? "選択中" : "")
        .buttonStyle(.pressable(scale: 0.97))
    }

    // MARK: - Navigation

    private var examNavigation: some View {
        HStack(spacing: AppLayout.paddingSM) {
            Button {
                vm.toggleFlag()
            } label: {
                Image(systemName: vm.flaggedQuestions.contains(vm.currentIndex) ? "flag.fill" : "flag")
                    .foregroundStyle(vm.flaggedQuestions.contains(vm.currentIndex) ? AppColor.accent : AppColor.textTertiary)
                    .frame(minWidth: 44, minHeight: 44)
                    .scaleEffect(vm.flagBounce ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: vm.flagBounce)
            }
            .accessibilityLabel("フラグ")
            .accessibilityValue(vm.flaggedQuestions.contains(vm.currentIndex) ? "フラグ済み" : "未フラグ")
            .accessibilityHint("この問題にフラグを付けます")

            Spacer()

            Button { vm.goToPrevious() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(vm.currentIndex == 0)
            .accessibilityLabel("前の問題")

            Button { vm.showQuestionList = true } label: {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("問題一覧")

            Button { vm.goToNext() } label: {
                Image(systemName: vm.currentIndex == vm.quizzes.count - 1 ? "checkmark.circle.fill" : "chevron.right")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
                    .symbolEffect(.bounce, value: vm.currentIndex == vm.quizzes.count - 1)
            }
            .accessibilityLabel(vm.currentIndex == vm.quizzes.count - 1 ? "採点する" : "次の問題")
        }
        .padding(.horizontal, AppLayout.paddingMD)
        .padding(.vertical, AppLayout.paddingSM)
        .background(AppColor.cardBackground)
    }

    // MARK: - Question List Panel

    private var questionListPanel: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(vm.quizzes.indices, id: \.self) { index in
                        let quiz = vm.quizzes[index]
                        let answered = vm.answers[quiz.id] != nil || vm.multiAnswers[quiz.id] != nil
                        let flagged = vm.flaggedQuestions.contains(index)

                        Button {
                            vm.jumpToQuestion(index)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(answered ? AppColor.primary.opacity(0.15) : AppColor.cardBackground)
                                    .frame(height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(index == vm.currentIndex ? AppColor.primary : Color.gray.opacity(0.2), lineWidth: index == vm.currentIndex ? 2 : 1)
                                    )
                                VStack(spacing: 1) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(answered ? AppColor.primary : AppColor.textPrimary)
                                    if flagged {
                                        Image(systemName: "flag.fill")
                                            .font(.system(size: 8))
                                            .foregroundStyle(AppColor.accent)
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                        }
                        .accessibilityLabel("問\(index + 1)\(answered ? "、回答済み" : "、未回答")\(flagged ? "、フラグ付き" : "")")
                    }
                }
                .padding(AppLayout.paddingMD)

                // サマリー
                VStack(alignment: .leading, spacing: 6) {
                    Text("回答済み: \(vm.answeredCount)")
                        .font(AppFont.caption)
                    Text("フラグ: \(vm.flaggedQuestions.count)")
                        .font(AppFont.caption)
                    Text("未回答: \(vm.quizzes.count - vm.answeredCount)")
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.textSecondary)
                .padding(AppLayout.paddingMD)

                Button(role: .destructive) {
                    vm.showQuestionList = false
                    vm.showConfirmEnd = true
                } label: {
                    Text("試験を終了する")
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColor.error)
                .padding(.horizontal, AppLayout.paddingMD)
            }
            .navigationTitle("問題一覧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { vm.showQuestionList = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

}
