//
//  EnvironmentSetupDetailView.swift
//  Java Pro
//
//  特定の環境構築セクション（Windows/Mac/DB/Web）の
//  ステップ形式ガイドを表示する詳細画面。
//  EnvironmentSetupView（目次画面）から遷移する。
//

import SwiftUI

struct EnvironmentSetupDetailView: View {
    let section: SetupGuideSection
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
                // セクションヘッダー
                HStack(spacing: AppLayout.paddingSM) {
                    ZStack {
                        Circle()
                            .fill(AppColor.primary.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: section.iconName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColor.primary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.title)
                            .font(AppFont.title3)
                            .foregroundStyle(AppColor.textPrimary)
                        Text(lang.l("env_setup.step_count", section.steps.count))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textTertiary)
                    }
                }
                .padding(.bottom, AppLayout.paddingSM)

                // ステップ一覧
                ForEach(Array(section.steps.enumerated()), id: \.element.id) { index, step in
                    stepView(step, number: index + 1)
                }
            }
            .padding(AppLayout.paddingMD)
        }
        .background(AppColor.background)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Step

    private func stepView(_ step: SetupStep, number: Int) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack(alignment: .top, spacing: AppLayout.paddingSM) {
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(AppColor.primary)
                    .clipShape(Circle())

                Text(step.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
            }

            RichBodyView(text: step.body)

            if let code = step.code, !code.isEmpty {
                codeBlock(code)
            }

            if let tip = step.tip, !tip.isEmpty {
                tipBanner(tip)
            }
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Code Block

    private func codeBlock(_ code: String) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Group {
                if JavaSyntaxHighlighter.looksLikeJava(code) {
                    Text(JavaSyntaxHighlighter.highlight(code))
                } else {
                    Text(code)
                        .foregroundStyle(AppColor.codeText)
                }
            }
            .font(AppFont.code)
            .textSelection(.enabled)
            .padding(AppLayout.paddingSM)
        }
        .background(AppColor.codeBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
    }

    // MARK: - Tip Banner

    private func tipBanner(_ tip: String) -> some View {
        HStack(alignment: .top, spacing: AppLayout.paddingSM) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(AppColor.accent)
                .font(.caption)
                .accessibilityHidden(true)
            Text(tip)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppLayout.paddingSM)
        .background(AppColor.accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
    }
}

#Preview {
    NavigationStack {
        EnvironmentSetupDetailView(
            section: SetupGuideSection(
                id: "preview",
                title: "Windows での Java セットアップ",
                iconName: "desktopcomputer",
                steps: [
                    SetupStep(id: "s1", title: "JDKをダウンロード", body: "Oracle公式サイトからJDK 17以降をダウンロードします。", code: nil, tip: "LTS版がおすすめです"),
                    SetupStep(id: "s2", title: "環境変数の設定", body: "JAVA_HOMEを設定しPATHに追加します。", code: "set JAVA_HOME=C:\\Program Files\\Java\\jdk-17", tip: nil)
                ]
            )
        )
    }
}
