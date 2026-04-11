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
    let certLevel: String  // "silver" or "gold"

    @State private var weakTopics: [WeakTopic] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("分析中…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if weakTopics.isEmpty {
                ContentUnavailableView(
                    "弱点なし！",
                    systemImage: "checkmark.seal.fill",
                    description: Text("すべての分野でよい正答率です。\nこの調子で頑張りましょう！")
                )
            } else {
                weakTopicsList
            }
        }
        .background(AppColor.background)
        .navigationTitle("弱点分析")
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
                Text("\(weakTopics.count)分野で改善の余地があります")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text("正答率 80% 未満の分野を表示しています")
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
                    Text("正解: \(topic.totalAttempts - topic.incorrectCount)/\(topic.totalAttempts)問  (\(Int(topic.correctRate * 100))%)")
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
            Label("学習のコツ", systemImage: "graduationcap.fill")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.info)

            VStack(alignment: .leading, spacing: 8) {
                tipRow("🔄", "弱点分野のクイズを繰り返し解きましょう")
                tipRow("📖", "該当レッスンをもう一度読み返しましょう")
                tipRow("💻", "コード実行で実際に動作を確認しましょう")
                tipRow("📝", "間違えた問題はメモして定期的に復習しましょう")
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
            return "基礎からレッスンを見直すことをお勧めします"
        } else if topic.correctRate < 0.6 {
            return "クイズを繰り返し練習しましょう"
        } else {
            return "あと少し！復習モードで仕上げましょう"
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
