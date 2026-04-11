//
//  QuizAnswerViews.swift
//  Java Pro
//
//  QuizView から抽出した回答エリア部品。
//  並び替え・複数選択・コード補完の3形式を独立した View として提供する。
//

import SwiftUI

// MARK: - 並び替え回答エリア

struct QuizReorderView: View {
    let quiz: QuizData
    @Binding var selectedOrderIds: [String]
    @Binding var isAnswered: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: AppLayout.paddingSM) {
            if !selectedOrderIds.isEmpty {
                VStack(spacing: 4) {
                    Text("あなたの並び順：")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    ForEach(Array(selectedOrderIds.enumerated()), id: \.element) { index, choiceId in
                        if let choice = quiz.choices.first(where: { $0.id == choiceId }) {
                            HStack {
                                Text("\(index + 1).")
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                                    .frame(width: 24)
                                Text(choice.text)
                                    .font(AppFont.body)
                                Spacer()
                                if !isAnswered {
                                    Button {
                                        withAnimation(AppAnimation.quick) {
                                            selectedOrderIds.removeAll { $0 == choiceId }
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(AppColor.textTertiary)
                                    }
                                    .accessibilityLabel("取り消す")
                                }
                            }
                            .padding(AppLayout.paddingSM)
                            .background(AppColor.primaryLight.opacity(0.15), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                        }
                    }
                }
            }
            let remaining = quiz.choices.filter { !selectedOrderIds.contains($0.id) }
            if !remaining.isEmpty && !isAnswered {
                ForEach(remaining.sorted { $0.order < $1.order }) { choice in
                    Button {
                        withAnimation(AppAnimation.quick) {
                            selectedOrderIds.append(choice.id)
                        }
                    } label: {
                        Text(choice.text)
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppLayout.paddingMD)
                            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.pressable(scale: 0.97))
                    .accessibilityLabel(choice.text)
                    .accessibilityHint("タップして並び順に追加")
                }
            }
            if selectedOrderIds.count == quiz.choices.count && !isAnswered {
                Button {
                    onSubmit()
                } label: {
                    Text("この順番で回答する")
                        .font(AppFont.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                }
                .buttonStyle(.pressable)
                .padding(.top, AppLayout.paddingSM)
            }
        }
    }
}

// MARK: - 複数選択回答エリア

struct QuizMultiChoiceView: View {
    let quiz: QuizData
    @Binding var selectedChoiceIds: [String]
    @Binding var isAnswered: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: AppLayout.paddingSM) {
            if let required = quiz.requiredSelections {
                Text("\(required)つ選択してください")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            ForEach(quiz.choices.sorted { $0.order < $1.order }) { choice in
                Button {
                    guard !isAnswered else { return }
                    if let idx = selectedChoiceIds.firstIndex(of: choice.id) {
                        selectedChoiceIds.remove(at: idx)
                    } else {
                        if let required = quiz.requiredSelections,
                           selectedChoiceIds.count >= required {
                            selectedChoiceIds.removeFirst()
                        }
                        selectedChoiceIds.append(choice.id)
                    }
                } label: {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: QuizChoiceStyle.multiIcon(for: choice, isAnswered: isAnswered, selectedIds: selectedChoiceIds))
                            .foregroundStyle(QuizChoiceStyle.multiIconColor(for: choice, isAnswered: isAnswered, selectedIds: selectedChoiceIds))
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text(choice.text)
                            .font(AppFont.body)
                            .foregroundStyle(QuizChoiceStyle.multiTextColor(for: choice, isAnswered: isAnswered, selectedIds: selectedChoiceIds))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if isAnswered {
                            QuizChoiceStyle.resultIcon(for: choice, selectedId: nil, selectedIds: selectedChoiceIds)
                        }
                    }
                    .padding(AppLayout.paddingMD)
                    .background(
                        QuizChoiceStyle.multiBackground(for: choice, isAnswered: isAnswered, selectedIds: selectedChoiceIds),
                        in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                            .stroke(QuizChoiceStyle.multiBorderColor(for: choice, isAnswered: isAnswered, selectedIds: selectedChoiceIds), lineWidth: selectedChoiceIds.contains(choice.id) ? 2 : 1)
                    )
                }
                .buttonStyle(.pressable(scale: 0.97))
                .disabled(isAnswered)
                .accessibilityLabel(choice.text)
                .accessibilityValue(selectedChoiceIds.contains(choice.id) ? "選択中" : "")
            }
            if !isAnswered && !selectedChoiceIds.isEmpty {
                let isReady = quiz.requiredSelections.map { selectedChoiceIds.count >= $0 } ?? true
                Button {
                    onSubmit()
                } label: {
                    Text("この選択で回答する（\(selectedChoiceIds.count)個選択中）")
                        .font(AppFont.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isReady ? AppColor.primary : AppColor.textTertiary,
                                    in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                }
                .buttonStyle(.pressable)
                .disabled(!isReady)
                .padding(.top, AppLayout.paddingSM)
            }
        }
    }
}

// MARK: - コード補完回答エリア

struct QuizCodeCompleteView: View {
    let quiz: QuizData
    @Binding var blankSelections: [String: String]
    @Binding var isAnswered: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            CodeBlockView(code: formattedTemplate())
            if let blanks = quiz.blanks {
                ForEach(blanks, id: \.id) { blank in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(blank.label)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColor.primary.opacity(0.12), in: Capsule())
                        ForEach(blank.choices, id: \.id) { choice in
                            Button {
                                guard !isAnswered else { return }
                                blankSelections[blank.id] = choice.id
                            } label: {
                                HStack {
                                    Text(choice.text)
                                        .font(AppFont.code)
                                        .foregroundStyle(QuizChoiceStyle.blankTextColor(for: blank, choice: choice, isAnswered: isAnswered, selections: blankSelections))
                                    Spacer()
                                    if blankSelections[blank.id] == choice.id {
                                        Image(systemName: isAnswered ? (choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill") : "circle.fill")
                                            .foregroundStyle(isAnswered ? (choice.isCorrect ? AppColor.success : AppColor.error) : AppColor.primary)
                                            .font(.caption)
                                    }
                                }
                                .padding(AppLayout.paddingSM)
                                .background(
                                    QuizChoiceStyle.blankBackground(for: blank, choice: choice, isAnswered: isAnswered, selections: blankSelections),
                                    in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                                        .stroke(blankSelections[blank.id] == choice.id ? AppColor.primary : Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.pressable(scale: 0.97))
                            .disabled(isAnswered)
                            .accessibilityLabel(choice.text)
                            .accessibilityValue(blankSelections[blank.id] == choice.id ? "選択中" : "")
                        }
                    }
                }
            }
            if let blanks = quiz.blanks, blankSelections.count == blanks.count && !isAnswered {
                Button {
                    onSubmit()
                } label: {
                    Text("この組み合わせで回答する")
                        .font(AppFont.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                }
                .buttonStyle(.pressable)
                .padding(.top, AppLayout.paddingSM)
            }
        }
    }

    private func formattedTemplate() -> String {
        var template = quiz.codeTemplate ?? ""
        if let blanks = quiz.blanks {
            for blank in blanks {
                let placeholder = "__BLANK_\(blank.id.replacingOccurrences(of: "blank_", with: ""))__"
                if let selectedId = blankSelections[blank.id],
                   let choice = blank.choices.first(where: { $0.id == selectedId }) {
                    template = template.replacingOccurrences(of: placeholder, with: "[\(choice.text)]")
                } else {
                    template = template.replacingOccurrences(of: placeholder, with: "[\(blank.label)]")
                }
            }
        }
        return template
    }
}
