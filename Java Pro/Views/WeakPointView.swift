//
//  WeakPointView.swift
//  Java Pro
//
//  弱点分析ビュー。正答率の低い分野をランキング表示し、
//  推奨学習アクションを提案する。CertificationView から遷移する。
//

import SwiftUI
import SwiftData

struct WeakPointView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let certLevel: String  // "silver" or "gold"

    @State private var weakTopics: [WeakTopic] = []
    @State private var isLoading = true

    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        Group {
            if isLoading {
                ProgressView(lang.l("weak.analyzing"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if weakTopics.isEmpty {
                ContentUnavailableView(
                    lang.l("weak.none_title"),
                    systemImage: "checkmark.seal.fill",
                    description: Text(lang.l("weak.none_message"))
                )
            } else {
                weakTopicsList
            }
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
        .frame(maxWidth: .infinity)
        .background(AppColor.background)
        .navigationTitle(lang.l("weak.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadWeakTopics() }
    }

    // MARK: - List

    private var weakTopicsList: some View {
        ScrollView {
            VStack(spacing: AppLayout.paddingMD) {
                // ヘッダーカード
                summaryCard
                    .staggeredAppear(index: 0)

                // 弱点トピック
                ForEach(Array(weakTopics.enumerated()), id: \.element.id) { index, topic in
                    weakTopicRow(topic, rank: index + 1)
                        .staggeredAppear(index: min(index + 1, 8))
                }

                // 学習アドバイス
                adviceCard
                    .staggeredAppear(index: min(weakTopics.count + 1, 9))
            }
            .padding(AppLayout.paddingMD)
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(AppColor.warning)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(lang.l("weak.areas_count", weakTopics.count))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("weak.threshold_note"))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    // MARK: - Weak Topic Row

    private func weakTopicRow(_ topic: WeakTopic, rank: Int) -> some View {
        VStack(spacing: AppLayout.paddingSM) {
            HStack {
                // ランク表示
                ZStack {
                    Circle()
                        .fill(rankColor(rank).opacity(0.15))
                        .frame(width: 36, height: 36)
                    Text("#\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(rankColor(rank))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.title)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(lang.l("weak.correct_detail", topic.totalAttempts - topic.incorrectCount, topic.totalAttempts, Int(topic.correctRate * 100)))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                // 正答率表示
                Text("\(Int(topic.correctRate * 100))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(rateColor(topic.correctRate))
            }

            // 正答率バー
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColor.textTertiary.opacity(0.12))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(rateColor(topic.correctRate))
                        .frame(width: geo.size.width * topic.correctRate, height: 8)
                }
            }
            .frame(height: 8)

            // 推奨アクション
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption2)
                    .foregroundStyle(AppColor.warning)
                Text(recommendedAction(topic))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    // MARK: - Advice

    private var adviceCard: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Label(lang.l("weak.study_tips"), systemImage: "graduationcap.fill")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.info)

            VStack(alignment: .leading, spacing: 8) {
                tipRow("🔄", lang.l("weak.tip.review_mistakes"))
                tipRow("📖", lang.l("weak.tip.revisit_lessons"))
                tipRow("💻", lang.l("weak.tip.run_code"))
                tipRow("📝", lang.l("weak.tip.note_mistakes"))
            }
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.info.opacity(0.06), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    private func tipRow(_ emoji: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(emoji)
                .font(.callout)
            Text(text)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    // MARK: - Helpers

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return AppColor.error
        case 2: return AppColor.warning
        case 3: return Color.orange
        default: return AppColor.textTertiary
        }
    }

    private func rateColor(_ rate: Double) -> Color {
        switch rate {
        case ..<0.4: return AppColor.error
        case ..<0.6: return AppColor.warning
        case ..<0.8: return Color.orange
        default: return AppColor.success
        }
    }

    private func recommendedAction(_ topic: WeakTopic) -> String {
        if topic.correctRate < 0.4 {
            return lang.l("weak.action.review_basics")
        } else if topic.correctRate < 0.6 {
            return lang.l("weak.action.practice_quizzes")
        } else {
            return lang.l("weak.action.almost_there")
        }
    }

    @MainActor
    private func loadWeakTopics() async {
        let analytics = AnalyticsService(modelContext: modelContext)
        let level: CertificationLevel = certLevel == "gold" ? .gold : .silver
        weakTopics = analytics.weakTopics(certLevel: level, limit: 10)
        isLoading = false
    }
}
