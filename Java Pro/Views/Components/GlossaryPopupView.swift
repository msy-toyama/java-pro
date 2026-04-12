//
//  GlossaryPopupView.swift
//  Java Pro
//
//  レッスン本文中の [[用語]] リンクをタップした際に表示されるコンパクトなポップアップ。
//  用語の定義を即座に確認できるUI。シート形式で表示する。
//

import SwiftUI

/// レッスン内用語リンクのタップで表示する軽量ポップアップ。
struct GlossaryPopupView: View {
    let entry: GlossaryEntry
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ドラッグインジケータ
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 3)
                    .fill(AppColor.textTertiary.opacity(0.3))
                    .frame(width: 40, height: 5)
                Spacer()
            }
            .padding(.top, AppLayout.paddingSM + 2)
            .padding(.bottom, AppLayout.paddingSM)

            // 用語ヘッダー
            HStack(spacing: AppLayout.paddingSM) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.primary.opacity(0.15), AppColor.primary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Text(String(entry.term.prefix(1)))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.primary)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.term)
                        .font(AppFont.title3)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(entry.reading)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColor.textTertiary)
                }
                .accessibilityLabel("閉じる")
            }
            .padding(.horizontal, AppLayout.paddingMD)

            Divider()
                .padding(.vertical, AppLayout.paddingSM + 2)
                .padding(.horizontal, AppLayout.paddingMD)

            // 定義
            Text(entry.definition)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .lineSpacing(6)
                .padding(.horizontal, AppLayout.paddingMD)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 6)

            // 関連レッスン（コンパクト表示）
            if !entry.relatedLessonIds.isEmpty {
                relatedLessonsCompact
                    .padding(.top, AppLayout.paddingSM + 2)
                    .opacity(appeared ? 1 : 0)
            }

            Spacer()
                .frame(height: AppLayout.paddingLG)
        }
        .background(AppColor.cardBackground)
        .presentationDetents([.height(280)])
        .presentationCornerRadius(AppLayout.cornerRadiusLarge)
        .presentationDragIndicator(.hidden)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(0.1)) {
                appeared = true
            }
        }
    }

    private var relatedLessonsCompact: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("関連レッスン")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColor.textTertiary)
                .textCase(.uppercase)
                .padding(.horizontal, AppLayout.paddingMD)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppLayout.paddingSM) {
                    ForEach(entry.relatedLessonIds, id: \.self) { lessonId in
                        if let lesson = ContentService.shared.getLesson(id: lessonId) {
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.caption2)
                                    .foregroundStyle(AppColor.primary)
                                    .accessibilityHidden(true)
                                Text(lesson.title)
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, AppLayout.paddingSM)
                            .padding(.vertical, AppLayout.paddingXS + 2)
                            .background(AppColor.primary.opacity(0.06), in: Capsule())
                        }
                    }
                }
                .padding(.horizontal, AppLayout.paddingMD)
            }
        }
    }
}
