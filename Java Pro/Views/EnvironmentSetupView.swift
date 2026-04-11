//
//  EnvironmentSetupView.swift
//  Java Pro
//
//  Java開発環境の構築ガイド目次画面。
//  Windows / Mac / DB / Web の各セットアップセクションを
//  目次形式で表示し、タップで個別ガイドに遷移する。
//

import SwiftUI

struct EnvironmentSetupView: View {
    private var sections: [SetupGuideSection] {
        PracticeService.shared.setupGuide
    }

    /// セクションIDに対応するカラー
    private func sectionColor(_ id: String) -> Color {
        switch id {
        case "windows_setup": return Color(hex: "0078D4")   // Windows blue
        case "mac_setup":     return Color(hex: "333333")   // Apple dark
        case "db_setup":      return Color(hex: "00758F")   // MySQL teal
        case "web_setup":     return Color(hex: "6DB33F")   // Spring green
        case "eclipse_web_setup": return Color(hex: "2C2255") // Eclipse purple
        default:              return AppColor.primary
        }
    }

    /// セクションIDに対応するサブタイトル
    private func sectionSubtitle(_ id: String) -> String {
        switch id {
        case "windows_setup": return "JDK のインストールと環境変数の設定"
        case "mac_setup":     return "Homebrew を使った JDK セットアップ"
        case "db_setup":      return "MySQL のインストールと接続準備"
        case "web_setup":     return "Maven / Spring Boot の開発環境構築"
        case "eclipse_web_setup": return "Eclipse で Servlet / JSP / Spring Boot"
        default:              return ""
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppLayout.paddingMD) {
                headerCard

                ForEach(sections) { section in
                    NavigationLink {
                        EnvironmentSetupDetailView(section: section)
                    } label: {
                        sectionCard(section)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppLayout.paddingMD)
        }
        .background(AppColor.background)
        .navigationTitle("環境構築ガイド")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "laptopcomputer.and.arrow.down")
                .font(.system(size: 40))
                .foregroundStyle(AppColor.primary)
            Text("開発環境を準備しよう")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            Text("必要な環境構築を選んでください。\n各ガイドをステップごとに解説します。")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppLayout.paddingLG)
        .frame(maxWidth: .infinity)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusLarge))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Section Card

    private func sectionCard(_ section: SetupGuideSection) -> some View {
        HStack(spacing: AppLayout.paddingMD) {
            ZStack {
                RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                    .fill(sectionColor(section.id).opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: section.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(sectionColor(section.id))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text(sectionSubtitle(section.id))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                Text("\(section.steps.count) ステップ")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(sectionColor(section.id))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(sectionColor(section.id).opacity(0.1), in: Capsule())
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColor.textTertiary)
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    NavigationStack {
        EnvironmentSetupView()
    }
}
