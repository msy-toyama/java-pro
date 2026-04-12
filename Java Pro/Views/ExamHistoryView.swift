//
//  ExamHistoryView.swift
//  Java Pro
//
//  過去の模擬試験結果一覧を表示するビュー。
//  成績サマリー + カードベースの履歴表示でプロ品質のUIを実現。
//

import SwiftUI
import SwiftData

struct ExamHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    let certLevel: CertificationLevel

    @State private var history: [UserExamResult] = []

    private var lang: LanguageManager { LanguageManager.shared }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: lang.isJapanese ? "ja_JP" : "en_US")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = lang.isJapanese ? "yyyy/MM/dd HH:mm" : "MMM d, yyyy h:mm a"
        return f
    }

    var body: some View {
        Group {
            if history.isEmpty {
                ContentUnavailableView(
                    lang.l("exam_history.empty_title"),
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(lang.l("exam_history.empty_message"))
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: AppLayout.paddingMD) {
                        // 成績サマリーカード
                        summaryCard
                            .staggeredAppear(index: 0)

                        // 履歴一覧
                        LazyVStack(spacing: AppLayout.paddingSM) {
                            ForEach(Array(history.enumerated()), id: \.element.id) { index, result in
                                examCard(result)
                                    .staggeredAppear(index: min(index + 1, 10))
                            }
                        }
                    }
                    .padding(AppLayout.paddingMD)
                }
                .background(AppColor.background)
            }
        }
        .navigationTitle(certLevel == .gold ? lang.l("exam_history.gold_title") : lang.l("exam_history.silver_title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadHistory()
        }
    }

    // MARK: - サマリーカード

    private var summaryCard: some View {
        let passCount = history.filter(\.passed).count
        let bestScore: Double = history.map { Double($0.score) / Double(max($0.totalQuestions, 1)) }.max() ?? 0
        let avgScore: Double = history.isEmpty ? 0 : history.map { Double($0.score) / Double(max($0.totalQuestions, 1)) }.reduce(0, +) / Double(history.count)

        return VStack(spacing: AppLayout.paddingSM) {
            HStack {
                Text(lang.l("exam_history.summary"))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(lang.l("exam_history.attempt_count", history.count))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            HStack(spacing: 0) {
                summaryStatItem(
                    value: "\(passCount)/\(history.count)",
                    label: lang.l("exam_history.pass"),
                    color: AppColor.success
                )
                Divider().frame(height: 40)
                summaryStatItem(
                    value: "\(Int(bestScore * 100))%",
                    label: lang.l("exam_history.best_accuracy"),
                    color: AppColor.primary
                )
                Divider().frame(height: 40)
                summaryStatItem(
                    value: "\(Int(avgScore * 100))%",
                    label: lang.l("exam_history.avg_accuracy"),
                    color: AppColor.accent
                )
            }

            // 成績推移バー
            if history.count >= 2 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lang.l("exam_history.chart_title"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                    trendChart
                }
                .padding(.top, 4)
            }
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
    }

    private func summaryStatItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(AppColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    /// 簡易的な正答率推移チャート（最大10件）
    private var trendChart: some View {
        let recent = Array(history.prefix(10).reversed())
        return GeometryReader { geo in
            let w = geo.size.width
            let h: CGFloat = 48
            let step = recent.count > 1 ? w / CGFloat(recent.count - 1) : w
            let passingRate = ExamService.defaultPassingRate

            ZStack(alignment: .topLeading) {
                // 合格ライン
                Path { path in
                    let y = h * (1 - passingRate)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: w, y: y))
                }
                .stroke(AppColor.success.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                // 推移ライン
                Path { path in
                    for (i, result) in recent.enumerated() {
                        let rate = Double(result.score) / Double(max(result.totalQuestions, 1))
                        let x = recent.count > 1 ? step * CGFloat(i) : w / 2
                        let y = h * (1 - rate)
                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(AppColor.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // ドット
                ForEach(Array(recent.enumerated()), id: \.offset) { i, result in
                    let rate = Double(result.score) / Double(max(result.totalQuestions, 1))
                    let x = recent.count > 1 ? step * CGFloat(i) : w / 2
                    let y = h * (1 - rate)
                    Circle()
                        .fill(result.passed ? AppColor.success : AppColor.error)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
            .frame(height: h)
        }
        .frame(height: 48)
        .accessibilityHidden(true)
    }

    // MARK: - 履歴カード

    private func examCard(_ result: UserExamResult) -> some View {
        HStack(spacing: AppLayout.paddingSM) {
            // 合否アイコン
            ZStack {
                Circle()
                    .fill(result.passed ? AppColor.success.opacity(0.15) : AppColor.error.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: result.passed ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(result.passed ? AppColor.success : AppColor.error)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(result.passed ? lang.l("exam_history.pass_label") : lang.l("exam_history.fail_label"))
                        .font(AppFont.headline)
                        .foregroundStyle(result.passed ? AppColor.success : AppColor.error)
                    Spacer()
                    Text(self.dateFormatter.string(from: result.completedAt))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }

                HStack(spacing: AppLayout.paddingSM) {
                    Label("\(result.score)/\(result.totalQuestions)", systemImage: "checkmark.circle")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)

                    let rate = Double(result.score) / Double(max(result.totalQuestions, 1))
                    Text(lang.l("exam_history.accuracy_percent", Int(rate * 100)))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)

                    Spacer()

                    let minutes = result.timeSpentSeconds / 60
                    Label(lang.l("exam_history.time_minutes", minutes), systemImage: "clock")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
        }
        .padding(AppLayout.paddingSM + 2)
        .modifier(CardStyle())
    }

    // MARK: - Load

    private func loadHistory() {
        let service = ExamService(modelContext: modelContext)
        history = service.examHistory(certLevel: certLevel)
    }
}