//
//  QuizChoiceStyle.swift
//  Java Pro
//
//  QuizView のクイズ選択肢スタイリングヘルパー。
//  選択肢のテキスト色・背景色・ボーダー色・アイコンの
//  ロジックを集約し、QuizView の見通しを改善する。
//

import SwiftUI

/// クイズ選択肢のスタイリングを集中管理するユーティリティ。
enum QuizChoiceStyle {

    // MARK: - 単一選択スタイル

    /// 単一選択の選択肢テキスト色
    static func textColor(for choice: QuizChoice, isAnswered: Bool, selectedId: String?) -> Color {
        guard isAnswered else { return AppColor.textPrimary }
        if choice.isCorrect { return AppColor.success }
        if choice.id == selectedId { return AppColor.error }
        return AppColor.textSecondary
    }

    /// 単一選択の選択肢背景色
    static func background(for choice: QuizChoice, isAnswered: Bool, selectedId: String?) -> Color {
        guard isAnswered else {
            return selectedId == choice.id ? AppColor.primaryLight.opacity(0.15) : AppColor.cardBackground
        }
        if choice.isCorrect { return AppColor.success.opacity(0.08) }
        if choice.id == selectedId { return AppColor.error.opacity(0.08) }
        return AppColor.cardBackground
    }

    /// 単一選択の選択肢ボーダー色
    static func borderColor(for choice: QuizChoice, isAnswered: Bool, selectedId: String?) -> Color {
        guard isAnswered else {
            return selectedId == choice.id ? AppColor.primary : Color.gray.opacity(0.2)
        }
        if choice.isCorrect { return AppColor.success }
        if choice.id == selectedId { return AppColor.error }
        return Color.gray.opacity(0.1)
    }

    // MARK: - 複数選択スタイル

    /// 複数選択のチェックボックスアイコン名
    static func multiIcon(for choice: QuizChoice, isAnswered: Bool, selectedIds: [String]) -> String {
        if isAnswered {
            return choice.isCorrect ? "checkmark.square.fill" : (selectedIds.contains(choice.id) ? "xmark.square.fill" : "square")
        }
        return selectedIds.contains(choice.id) ? "checkmark.square.fill" : "square"
    }

    /// 複数選択のアイコン色
    static func multiIconColor(for choice: QuizChoice, isAnswered: Bool, selectedIds: [String]) -> Color {
        if isAnswered {
            return choice.isCorrect ? AppColor.success : (selectedIds.contains(choice.id) ? AppColor.error : AppColor.textTertiary)
        }
        return selectedIds.contains(choice.id) ? AppColor.primary : AppColor.textTertiary
    }

    /// 複数選択のテキスト色
    static func multiTextColor(for choice: QuizChoice, isAnswered: Bool, selectedIds: [String]) -> Color {
        guard isAnswered else { return AppColor.textPrimary }
        if choice.isCorrect { return AppColor.success }
        if selectedIds.contains(choice.id) { return AppColor.error }
        return AppColor.textSecondary
    }

    /// 複数選択の背景色
    static func multiBackground(for choice: QuizChoice, isAnswered: Bool, selectedIds: [String]) -> Color {
        guard isAnswered else {
            return selectedIds.contains(choice.id) ? AppColor.primaryLight.opacity(0.15) : AppColor.cardBackground
        }
        if choice.isCorrect { return AppColor.success.opacity(0.08) }
        if selectedIds.contains(choice.id) { return AppColor.error.opacity(0.08) }
        return AppColor.cardBackground
    }

    /// 複数選択のボーダー色
    static func multiBorderColor(for choice: QuizChoice, isAnswered: Bool, selectedIds: [String]) -> Color {
        guard isAnswered else {
            return selectedIds.contains(choice.id) ? AppColor.primary : Color.gray.opacity(0.2)
        }
        if choice.isCorrect { return AppColor.success }
        if selectedIds.contains(choice.id) { return AppColor.error }
        return Color.gray.opacity(0.1)
    }

    // MARK: - コード補完スタイル

    /// 穴埋め選択肢のテキスト色
    static func blankTextColor(for blank: BlankDefinition, choice: BlankChoice, isAnswered: Bool, selections: [String: String]) -> Color {
        guard isAnswered else { return AppColor.textPrimary }
        if choice.isCorrect { return AppColor.success }
        if selections[blank.id] == choice.id { return AppColor.error }
        return AppColor.textSecondary
    }

    /// 穴埋め選択肢の背景色
    static func blankBackground(for blank: BlankDefinition, choice: BlankChoice, isAnswered: Bool, selections: [String: String]) -> Color {
        guard isAnswered else {
            return selections[blank.id] == choice.id ? AppColor.primaryLight.opacity(0.15) : AppColor.cardBackground
        }
        if choice.isCorrect { return AppColor.success.opacity(0.08) }
        if selections[blank.id] == choice.id { return AppColor.error.opacity(0.08) }
        return AppColor.cardBackground
    }

    // MARK: - 結果アイコン

    /// 回答後の正解/不正解アイコン
    @ViewBuilder
    static func resultIcon(for choice: QuizChoice, selectedId: String?, selectedIds: [String]) -> some View {
        if choice.isCorrect {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColor.success)
                .transition(.scale)
        } else if choice.id == selectedId || selectedIds.contains(choice.id) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(AppColor.error)
                .transition(.scale)
        }
    }
}
