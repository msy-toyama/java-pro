//
//  ExamReviewView.swift
//  Java Pro
//
//  模擬試験の解答・解説レビュー画面。
//  各問題のユーザー回答・正解・正誤・解説を表示する。
//

import SwiftUI

struct ExamReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let quizzes: [QuizData]
    let answers: [String: String]           // quizId -> choiceId
    let multiAnswers: [String: [String]]    // quizId -> [choiceId]

    @State private var currentIndex = 0
    @State private var filterIncorrectOnly = false

    private var filteredQuizzes: [QuizData] {
        if filterIncorrectOnly {
            return quizzes.filter { !isCorrect(quiz: $0) }
        }
        return quizzes
    }

    private var currentQuiz: QuizData? {
        filteredQuizzes.indices.contains(currentIndex) ? filteredQuizzes[currentIndex] : nil
    }

    private var correctCount: Int {
        quizzes.filter { isCorrect(quiz: $0) }.count
    }

    private var incorrectCount: Int {
        quizzes.count - correctCount
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // フィルターバー
                filterBar

                Divider()

                if filteredQuizzes.isEmpty {
                    ContentUnavailableView(
                        "すべて正解です！",
                        systemImage: "checkmark.circle.fill",
                        description: Text("不正解の問題はありません。")
                    )
                } else {
                    // 問題ヘッダー
                    reviewHeader

                    Divider()

                    // 解説コンテンツ
                    ScrollView {
                        if let quiz = currentQuiz {
                            reviewQuestionView(quiz)
                                .padding(AppLayout.paddingMD)
                                .id(currentIndex) // 問題切替時にスクロール位置をリセット
                        }
                    }

                    Divider()

                    // ナビゲーション
                    reviewNavigation
                }
            }
            .background(AppColor.background)
            .navigationTitle("解答・解説")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: AppLayout.paddingSM) {
            filterButton(title: "全問題 (\(quizzes.count))", active: !filterIncorrectOnly) {
                filterIncorrectOnly = false
                currentIndex = 0
            }
            filterButton(title: "不正解のみ (\(incorrectCount))", active: filterIncorrectOnly) {
                filterIncorrectOnly = true
                currentIndex = 0
            }
        }
        .padding(.horizontal, AppLayout.paddingMD)
        .padding(.vertical, AppLayout.paddingSM)
        .background(AppColor.cardBackground)
    }

    private func filterButton(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.caption)
                .fontWeight(active ? .semibold : .regular)
                .foregroundStyle(active ? .white : AppColor.textSecondary)
                .padding(.horizontal, AppLayout.paddingSM)
                .padding(.vertical, 6)
                .background(
                    active ? AppColor.primary : AppColor.textTertiary.opacity(0.15),
                    in: Capsule()
                )
        }
        .buttonStyle(.pressable(scale: 0.95))
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    // MARK: - Header

    private var reviewHeader: some View {
        HStack {
            // 問番号と正誤マーク
            if let quiz = currentQuiz {
                let originalIndex = quizzes.firstIndex(where: { $0.id == quiz.id }) ?? currentIndex
                let correct = isCorrect(quiz: quiz)

                HStack(spacing: 6) {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(correct ? AppColor.success : AppColor.error)
                        .accessibilityHidden(true)
                    Text("問 \(originalIndex + 1)")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("問\(originalIndex + 1)、\(correct ? "正解" : "不正解")")
            }

            Spacer()

            Text("\(currentIndex + 1) / \(filteredQuizzes.count)")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.horizontal, AppLayout.paddingMD)
        .padding(.vertical, AppLayout.paddingSM)
        .background(AppColor.cardBackground)
    }

    // MARK: - Question Review

    private func reviewQuestionView(_ quiz: QuizData) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
            // 問題タイプバッジ
            HStack(spacing: 6) {
                quizTypeBadge(quiz)
                if let topic = quiz.certificationTopic {
                    Text(topicDisplayName(topic))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                        .padding(.horizontal, AppLayout.paddingSM)
                        .padding(.vertical, AppLayout.paddingXS)
                        .background(AppColor.textTertiary.opacity(0.1), in: Capsule())
                }
            }

            // 問題文
            Text(quiz.question)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
                .lineSpacing(4)

            // コードブロック
            if let code = quiz.code, !code.isEmpty {
                CodeBlockView(code: code)
            }

            // 選択肢（正誤表示）
            VStack(spacing: 8) {
                ForEach(quiz.choices.sorted { $0.order < $1.order }) { choice in
                    reviewChoiceRow(quiz: quiz, choice: choice)
                }
            }

            // 解説
            if !quiz.explanation.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(AppColor.accent)
                            .accessibilityHidden(true)
                        Text("解説")
                            .font(AppFont.headline)
                            .foregroundStyle(AppColor.textPrimary)
                    }

                    Text(quiz.explanation)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineSpacing(4)
                }
                .padding(AppLayout.paddingMD)
                .background(AppColor.accent.opacity(0.06), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColor.accent.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    private func reviewChoiceRow(quiz: QuizData, choice: QuizChoice) -> some View {
        let isMulti = quiz.type == .multiChoice
        let userSelected: Bool = isMulti
            ? (multiAnswers[quiz.id]?.contains(choice.id) ?? false)
            : (answers[quiz.id] == choice.id)
        let isCorrectChoice = choice.isCorrect

        // 状態: 正解を選んだ / 不正解を選んだ / 正解だが選ばなかった / 不正解で選ばなかった
        let backgroundColor: Color
        let borderColor: Color
        let iconName: String
        let iconColor: Color

        if userSelected && isCorrectChoice {
            // 正解を選んだ
            backgroundColor = AppColor.success.opacity(0.08)
            borderColor = AppColor.success
            iconName = isMulti ? "checkmark.square.fill" : "checkmark.circle.fill"
            iconColor = AppColor.success
        } else if userSelected && !isCorrectChoice {
            // 不正解を選んだ
            backgroundColor = AppColor.error.opacity(0.08)
            borderColor = AppColor.error
            iconName = isMulti ? "xmark.square.fill" : "xmark.circle.fill"
            iconColor = AppColor.error
        } else if !userSelected && isCorrectChoice {
            // 正解だが選ばなかった
            backgroundColor = AppColor.success.opacity(0.04)
            borderColor = AppColor.success.opacity(0.5)
            iconName = isMulti ? "square" : "circle"
            iconColor = AppColor.success
        } else {
            // 不正解で選ばなかった（普通）
            backgroundColor = AppColor.cardBackground
            borderColor = Color.gray.opacity(0.2)
            iconName = isMulti ? "square" : "circle"
            iconColor = AppColor.textTertiary
        }

        return HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)

            Text(choice.text)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.leading)

            Spacer()

            // 正解マーク
            if isCorrectChoice {
                Text("正解")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColor.success)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.success.opacity(0.12), in: Capsule())
            }

            // ユーザーが選択したが不正解
            if userSelected && !isCorrectChoice {
                Text("あなたの回答")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColor.error)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.error.opacity(0.12), in: Capsule())
            }
        }
        .padding(AppLayout.paddingMD)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                .stroke(borderColor, lineWidth: userSelected || isCorrectChoice ? 2 : 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(choice.text)、\(isCorrectChoice ? "正解" : "不正解")\(userSelected ? "、選択済み" : "")")
    }

    @ViewBuilder
    private func quizTypeBadge(_ quiz: QuizData) -> some View {
        let label = quiz.type.displayLabel
        let color = quiz.type.displayColor
        Text(label)
            .font(AppFont.caption)
            .foregroundStyle(color)
            .padding(.horizontal, AppLayout.paddingSM)
            .padding(.vertical, AppLayout.paddingXS)
            .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - Navigation

    private var reviewNavigation: some View {
        HStack(spacing: AppLayout.paddingMD) {
            Button {
                if currentIndex > 0 {
                    if reduceMotion {
                        currentIndex -= 1
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentIndex -= 1
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("前へ")
                }
                .font(AppFont.callout)
            }
            .disabled(currentIndex == 0)
            .buttonStyle(.pressable(scale: 0.93))

            Spacer()

            // ページ番号
            Text("\(currentIndex + 1) / \(filteredQuizzes.count)")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()

            Button {
                if currentIndex < filteredQuizzes.count - 1 {
                    if reduceMotion {
                        currentIndex += 1
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentIndex += 1
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("次へ")
                    Image(systemName: "chevron.right")
                }
                .font(AppFont.callout)
            }
            .disabled(currentIndex >= filteredQuizzes.count - 1)
            .buttonStyle(.pressable(scale: 0.93))
        }
        .padding(.horizontal, AppLayout.paddingMD)
        .padding(.vertical, AppLayout.paddingSM)
        .background(AppColor.cardBackground)
    }

    // MARK: - Helpers

    private func isCorrect(quiz: QuizData) -> Bool {
        if quiz.type == .multiChoice {
            let correctIds = Set(quiz.choices.filter(\.isCorrect).map(\.id))
            return Set(multiAnswers[quiz.id] ?? []) == correctIds
        } else {
            let correctId = quiz.choices.first(where: \.isCorrect)?.id
            return answers[quiz.id] == correctId
        }
    }

    private func topicDisplayName(_ key: String) -> String {
        ExamService.topicDisplayName(key)
    }
}
