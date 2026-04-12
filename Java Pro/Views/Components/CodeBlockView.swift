//
//  CodeBlockView.swift
//  Java Pro
//
//  コードブロックをターミナル風UIで表示するView。
//  コピー機能付き。LessonDetailViewから抽出。
//

import SwiftUI

struct CodeBlockView: View {
    let code: String
    @State private var showCopied = false
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダーバー
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: "FF5F56")).frame(width: 8, height: 8)
                    Circle().fill(Color(hex: "FFBD2E")).frame(width: 8, height: 8)
                    Circle().fill(Color(hex: "27C93F")).frame(width: 8, height: 8)
                }
                .accessibilityHidden(true)
                .padding(.leading, 4)

                Spacer()

                Button {
                    UIPasteboard.general.string = code
                    withAnimation(AppAnimation.quick) { showCopied = true }
                    Task {
                        try? await Task.sleep(for: .milliseconds(1500))
                        withAnimation(AppAnimation.quick) { showCopied = false }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        Text(showCopied ? lang.l("code_block.copied") : lang.l("code_block.copy"))
                    }
                    .font(AppFont.codeSmall)
                    .foregroundStyle(showCopied ? AppColor.terminalGreen : AppColor.codeText.opacity(0.5))
                }
                .accessibilityLabel(showCopied ? lang.l("code_block.accessibility.copied") : lang.l("code_block.accessibility.copy"))
            }
            .padding(.horizontal, AppLayout.paddingSM + 2)
            .padding(.vertical, AppLayout.paddingSM)
            .background(Color(hex: "0F172A"))

            Divider()
                .overlay(Color.white.opacity(0.06))

            // コード本体（シンタックスハイライト適用）
            ScrollView(.horizontal, showsIndicators: false) {
                Text(JavaSyntaxHighlighter.highlight(code))
                    .font(AppFont.code)
                    .padding(AppLayout.paddingMD)
            }
        }
        .background(AppColor.codeBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
    }
}
