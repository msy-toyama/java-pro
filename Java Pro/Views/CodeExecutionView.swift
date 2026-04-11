//
//  CodeExecutionView.swift
//  Java Pro
//
//  コード実行結果をターミナル風に演出するビュー。
//  3パターン: ✅正常正解(緑) / ⚠️正常不正解(黄) / ❌エラー(赤)
//  タイプライターアニメーションで臨場感を演出する。
//

import SwiftUI

// MARK: - 実行結果の表示パターン

enum ExecutionPattern {
    /// 正常実行・正解
    case successCorrect
    /// 正常実行・不正解
    case successIncorrect
    /// エラー（コンパイル / 実行時例外）
    case error
}

// MARK: - CodeExecutionView

/// コード実行結果をターミナル風UIで表示するビュー。
struct CodeExecutionView: View {
    let result: ExecutionResult
    let pattern: ExecutionPattern
    let title: String?

    @State private var displayedText = ""
    @State private var isAnimating = false
    @State private var showHeader = false
    @State private var showBody = false
    @State private var animationTask: Task<Void, Never>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(result: ExecutionResult, pattern: ExecutionPattern, title: String? = nil) {
        self.result = result
        self.pattern = pattern
        self.title = title
    }

    /// 選択肢の正誤と実行結果から自動判定するイニシャライザ。
    init(result: ExecutionResult, isCorrectChoice: Bool) {
        self.result = result
        if result.hasError {
            self.pattern = .error
        } else if isCorrectChoice {
            self.pattern = .successCorrect
        } else {
            self.pattern = .successIncorrect
        }
        self.title = nil
    }

    private var headerColor: Color {
        switch pattern {
        case .successCorrect:   return AppColor.terminalGreen
        case .successIncorrect: return AppColor.terminalYellow
        case .error:            return AppColor.terminalRed
        }
    }

    private var headerIcon: String {
        switch pattern {
        case .successCorrect:   return "checkmark.circle.fill"
        case .successIncorrect: return "exclamationmark.triangle.fill"
        case .error:            return "xmark.octagon.fill"
        }
    }

    private var headerText: String {
        if let title { return title }
        switch pattern {
        case .successCorrect:   return "実行結果（正常）"
        case .successIncorrect: return "実行結果（正常・期待と異なる出力）"
        case .error:            return "実行結果（エラー）"
        }
    }

    private var outputText: String {
        if result.hasError {
            if let errorMessage = result.errorMessage {
                return errorMessage
            }
            return result.output.isEmpty ? "エラーが発生しました" : result.output
        }
        return result.output.isEmpty ? "(出力なし)" : result.output
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ターミナルヘッダー
            terminalHeader
                .opacity(showHeader ? 1 : 0)
                .offset(y: showHeader ? 0 : -8)

            // ターミナル本体
            terminalBody
                .opacity(showBody ? 1 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                .stroke(headerColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            animationTask?.cancel()
            animationTask = nil
        }
    }

    // MARK: - Components

    private var terminalHeader: some View {
        HStack(spacing: 6) {
            // 信号灯風ドット
            HStack(spacing: 4) {
                Circle().fill(Color.red.opacity(0.8)).frame(width: 8, height: 8)
                Circle().fill(Color.yellow.opacity(0.8)).frame(width: 8, height: 8)
                Circle().fill(Color.green.opacity(0.8)).frame(width: 8, height: 8)
            }
            .accessibilityHidden(true)

            Spacer()

            Image(systemName: headerIcon)
                .font(.caption2)
                .foregroundStyle(headerColor)
                .accessibilityHidden(true)

            Text(headerText)
                .font(AppFont.codeSmall)
                .foregroundStyle(headerColor)

            Spacer()

            // exit code
            Text("exit: \(result.exitCode)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(AppColor.codeText.opacity(0.5))
        }
        .padding(.horizontal, AppLayout.paddingSM)
        .padding(.vertical, 6)
        .background(Color(hex: "0F172A"))
    }

    private var terminalBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            // プロンプト行
            HStack(spacing: 4) {
                Text("$")
                    .font(AppFont.codeSmall)
                    .foregroundStyle(headerColor)
                Text("java Main.java")
                    .font(AppFont.codeSmall)
                    .foregroundStyle(AppColor.codeText.opacity(0.6))
            }

            // 出力テキスト（タイプライターアニメーション）
            Text(displayedText)
                .font(AppFont.code)
                .foregroundStyle(result.hasError ? AppColor.terminalRed : AppColor.codeText)
                .lineSpacing(2)
                .textSelection(.enabled)

            // エラー種別（ある場合）
            if let errorType = result.errorType, result.hasError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .accessibilityHidden(true)
                    Text(errorType)
                        .font(AppFont.codeSmall)
                }
                .foregroundStyle(AppColor.terminalRed.opacity(0.8))
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppLayout.paddingSM)
        .background(AppColor.codeBackground)
    }

    // MARK: - Animation

    private func startAnimation() {
        if reduceMotion {
            showHeader = true
            showBody = true
            displayedText = outputText
            return
        }
        // ヘッダーをフェードイン
        withAnimation(.easeOut(duration: 0.3)) {
            showHeader = true
        }

        // 0.2秒後にボディ表示開始
        animationTask?.cancel()
        animationTask = Task {
            try? await Task.sleep(for: .milliseconds(200))
            if Task.isCancelled { return }
            withAnimation(.easeOut(duration: 0.2)) {
                showBody = true
            }
            // タイプライターアニメーション開始
            await startTypewriter()
        }
    }

    private func startTypewriter() async {
        let text = outputText
        guard !text.isEmpty else {
            displayedText = text
            return
        }

        isAnimating = true
        displayedText = ""

        let characters = Array(text)
        let totalDuration = min(Double(characters.count) * 0.025, 1.5)  // 最大1.5秒
        let intervalMs = Int(totalDuration / Double(characters.count) * 1000)

        for (index, char) in characters.enumerated() {
            try? await Task.sleep(for: .milliseconds(intervalMs))
            if Task.isCancelled { return }
            displayedText.append(char)
            if index == characters.count - 1 {
                isAnimating = false
            }
        }
    }
}

// MARK: - クイズ解答後の実行結果表示

/// クイズの選択肢を選んだ後に表示する実行結果セクション。
struct QuizExecutionResultSection: View {
    let quiz: QuizData
    let selectedChoiceId: String?
    let isAnswered: Bool

    var body: some View {
        if isAnswered {
            VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
                // 選んだ選択肢の実行結果
                if let selectedId = selectedChoiceId,
                   let choice = quiz.choices.first(where: { $0.id == selectedId }),
                   let result = choice.executionResult {
                    Text("あなたの選択の実行結果")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    CodeExecutionView(
                        result: result,
                        isCorrectChoice: choice.isCorrect
                    )
                }

                // 正解の選択肢の実行結果（不正解だった場合のみ表示）
                if let selectedId = selectedChoiceId,
                   let selected = quiz.choices.first(where: { $0.id == selectedId }),
                   !selected.isCorrect,
                   let correctChoice = quiz.choices.first(where: { $0.isCorrect }),
                   let correctResult = correctChoice.executionResult {
                    Text("正解の実行結果")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    CodeExecutionView(
                        result: correctResult,
                        pattern: .successCorrect,
                        title: "正解: \(correctChoice.text)"
                    )
                }

                // クイズ全体の実行結果（outputPredict 等）
                if let result = quiz.executionResult {
                    Text("このコードの実行結果")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    CodeExecutionView(
                        result: result,
                        pattern: result.hasError ? .error : .successCorrect
                    )
                }

                // errorFind: 修正後の実行結果
                if let fixedResult = quiz.fixedExecutionResult {
                    Text("修正後の実行結果")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    CodeExecutionView(
                        result: fixedResult,
                        pattern: .successCorrect,
                        title: "修正後（正常実行）"
                    )
                }
            }
            .padding(.top, AppLayout.paddingSM)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .opacity
            ))
        }
    }
}

// MARK: - Preview

#Preview("Success Correct") {
    CodeExecutionView(
        result: ExecutionResult(
            output: "Hello, World!\n42",
            exitCode: 0,
            hasError: false,
            errorMessage: nil,
            errorType: nil
        ),
        pattern: .successCorrect
    )
    .padding()
}

#Preview("Error") {
    CodeExecutionView(
        result: ExecutionResult(
            output: "",
            exitCode: 1,
            hasError: true,
            errorMessage: "Main.java:3: error: ';' expected\n        System.out.println(\"Hello\")\n                                   ^",
            errorType: "CompilationError"
        ),
        pattern: .error
    )
    .padding()
}
