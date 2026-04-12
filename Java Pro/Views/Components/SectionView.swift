//
//  SectionView.swift
//  Java Pro
//
//  レッスン内のセクション（概要・ルール・コード・ポイント・補足）を
//  リッチカード形式で表示するView。LessonDetailViewから抽出。
//

import SwiftUI

struct SectionView: View {
    let section: LessonSection
    var sectionNumber: Int = 1
    var totalSections: Int = 1
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // セクションヘッダー（カラーバー付き）
            HStack(spacing: AppLayout.paddingSM) {
                // カラードインジケータ
                RoundedRectangle(cornerRadius: 2)
                    .fill(sectionColor)
                    .frame(width: 4, height: 28)

                Image(systemName: sectionIcon)
                    .foregroundStyle(sectionColor)
                    .font(.subheadline)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(sectionTypeLabel)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(sectionColor)
                        .textCase(.uppercase)
                    Text(section.title)
                        .font(AppFont.title3)
                        .foregroundStyle(AppColor.textPrimary)
                }

                Spacer()

                Text("\(sectionNumber)/\(totalSections)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppColor.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColor.textTertiary.opacity(0.08), in: Capsule())
            }
            .padding(.horizontal, AppLayout.paddingMD)
            .padding(.top, AppLayout.paddingMD)
            .padding(.bottom, AppLayout.paddingSM)

            Divider()
                .padding(.horizontal, AppLayout.paddingMD)

            // コンテンツ
            VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
                // 本文
                if let body = section.body, !body.isEmpty {
                    RichBodyView(text: body)
                }

                // コードブロック
                if let code = section.code, !code.isEmpty {
                    CodeBlockView(code: code)
                }

                // 補足ノート
                if let note = section.note, !note.isEmpty {
                    noteView(note)
                }
            }
            .padding(AppLayout.paddingMD)
        }
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(sectionColor.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func noteView(_ note: String) -> some View {
        HStack(alignment: .top, spacing: AppLayout.paddingSM) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.accent.opacity(0.15), AppColor.accent.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(AppColor.accent)
                    .font(.caption2)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(lang.l("section.note_label"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColor.accent)
                    .textCase(.uppercase)
                RichBodyView.styledText(note)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(AppLayout.paddingSM + 2)
        .background(AppColor.accent.opacity(0.06), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                .stroke(AppColor.accent.opacity(0.12), lineWidth: 1)
        )
    }

    private var sectionTypeLabel: String {
        switch section.sectionType {
        case .overview: return lang.l("section.type.overview")
        case .rule:     return lang.l("section.type.rule")
        case .code:     return lang.l("section.type.code")
        case .point:    return lang.l("section.type.point")
        case .tip:      return lang.l("section.type.tip")
        }
    }

    private var sectionIcon: String {
        switch section.sectionType {
        case .overview: return "doc.text"
        case .rule:     return "checkmark.shield"
        case .code:     return "chevron.left.forwardslash.chevron.right"
        case .point:    return "star.fill"
        case .tip:      return "lightbulb.fill"
        }
    }

    private var sectionColor: Color {
        Self.color(for: section.sectionType)
    }

    static func color(for type: LessonSection.SectionType) -> Color {
        switch type {
        case .overview: return AppColor.info
        case .rule:     return AppColor.primary
        case .code:     return AppColor.success
        case .point:    return AppColor.accent
        case .tip:      return AppColor.warning
        }
    }
}
