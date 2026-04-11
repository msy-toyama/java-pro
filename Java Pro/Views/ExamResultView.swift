//
//  ExamResultView.swift
//  Java Pro
//
//  模擬試験結果画面。正解数・正答率・合否・分野別正答率チャート・
//  所要時間を表示する。
//

import SwiftUI
import SwiftData

struct ExamResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let result: UserExamResult
    let topicScores: [String: Double]
    var quizzes: [QuizData] = []
    var answers: [String: String] = [:]
    var multiAnswers: [String: [String]] = [:]

    @State private var animateRing = false
    @State private var showConfetti = false
    @State private var showReview = false

    private var scoreRate: Double {
        Double(result.score) / Double(max(result.totalQuestions, 1))
    }

    private var timeString: String {
        let h = result.timeSpentSeconds / 3600
        let m = (result.timeSpentSeconds % 3600) / 60
        if h > 0 {
            return "\(h)時間\(m)分"
        }
        return "\(m)分"
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: AppLayout.paddingLG) {
                    Spacer(minLength: AppLayout.paddingMD)

                    // 結果サマリー
                    resultSummary
                        .staggeredAppear(index: 0)

                    // 分野別正答率
                    if !topicScores.isEmpty {
                        topicBreakdown
                            .staggeredAppear(index: 1)
                    }

                    // 所要時間
                    timeSection
                        .staggeredAppear(index: 2)

                    // アクションボタン
                    actionButtons
                        .staggeredAppear(index: 3)
                }
                .padding(AppLayout.paddingMD)
            }
            .background(AppColor.background)

            // 合格時コンフェッティ
            if showConfetti {
                ConfettiView(isActive: $showConfetti)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .navigationTitle("模擬試験結果")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if reduceMotion {
                animateRing = true
            } else {
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    animateRing = true
                }
            }
            if result.passed && !reduceMotion {
                Task {
                    try? await Task.sleep(for: .milliseconds(800))
                    showConfetti = true
                }
            }
        }
    }

    // MARK: - Result Summary

    private var resultSummary: some View {
        VStack(spacing: AppLayout.paddingMD) {
            // 合否判定
            ZStack {
                Circle()
                    .fill(result.passed ? AppColor.success.opacity(0.12) : AppColor.error.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateRing ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateRing)
                Circle()
                    .trim(from: 0, to: animateRing ? scoreRate : 0)
                    .stroke(
                        result.passed ? AppColor.success : AppColor.error,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0).delay(0.3), value: animateRing)
                VStack(spacing: 4) {
                    Text("\(result.score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(result.passed ? AppColor.success : AppColor.error)
                        .contentTransition(.numericText())
                    Text("/ \(result.totalQuestions)")
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            Text(result.passed ? "合格！" : "不合格")
                .font(AppFont.largeTitle)
                .foregroundStyle(result.passed ? AppColor.success : AppColor.error)

            Text("正答率: \(Int(scoreRate * 100))%  /  合格ライン: \(ExamService.passingRatePercent)%")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)

            if result.passed {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(AppColor.xpGold)
                        .accessibilityHidden(true)
                    Text("+500 XP 獲得！")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.xpGold)
                }
                .padding(AppLayout.paddingSM)
                .background(AppColor.xpGold.opacity(0.1), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                .shimmer(duration: 2.5, isActive: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.passed ? "合格" : "不合格")、スコア\(result.score)/\(result.totalQuestions)、正答率\(Int(scoreRate * 100))%")
    }

    // MARK: - Topic Breakdown

    private var topicBreakdown: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text("分野別正答率")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            ForEach(topicScores.sorted(by: { $0.value < $1.value }), id: \.key) { topic, rate in
                VStack(spacing: 4) {
                    HStack {
                        Text(topicDisplayName(topic))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(rate * 100))%")
                            .font(AppFont.caption)
                            .foregroundStyle(rate < ExamService.defaultPassingRate ? AppColor.error : AppColor.success)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppColor.textTertiary.opacity(0.15))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(rate < ExamService.defaultPassingRate ? AppColor.error : AppColor.success)
                                .frame(width: geo.size.width * (animateRing ? rate : 0), height: 8)
                                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateRing)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    private func topicDisplayName(_ key: String) -> String {
        ExamService.topicDisplayName(key)
    }

    // MARK: - Time

    private var timeSection: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundStyle(AppColor.textTertiary)
                .accessibilityHidden(true)
            Text("所要時間: \(timeString)")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: AppLayout.paddingSM) {
            if !quizzes.isEmpty {
                Button {
                    showReview = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("解答・解説を確認")
                    }
                    .font(AppFont.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.accent, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                }
                .buttonStyle(.pressable)
                .accessibilityLabel("解答と解説を確認する")
            }

            Button {
                dismiss()
            } label: {
                Text("閉じる")
                    .font(AppFont.headline)
                    .foregroundStyle(quizzes.isEmpty ? .white : AppColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        quizzes.isEmpty ? AppColor.primary : AppColor.primary.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    )
            }
            .buttonStyle(.pressable)
        }
        .padding(.top, AppLayout.paddingMD)
        .fullScreenCover(isPresented: $showReview) {
            ExamReviewView(
                quizzes: quizzes,
                answers: answers,
                multiAnswers: multiAnswers
            )
        }
    }
}
