//
//  QuizResultView.swift
//  Java Pro
//
//  クイズ完了後の結果表示画面。スコア、獲得XP、バッジ、
//  次のレッスンへのナビゲーション等を提供する。
//  QuizView.swift から分離して責務を明確化。
//

import SwiftUI

struct QuizResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let correctCount: Int
    let totalCount: Int
    let earnedXP: Int
    let newBadges: [String]
    let newLevel: Int?
    let lessonId: String?
    let isReviewMode: Bool
    let onNextLesson: ((String) -> Void)?
    let onRetry: () -> Void

    /// 結果画面に入った瞬間にアニメーションを発火させるフラグ
    @State private var animateIn = false
    @State private var isNavigating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Navigation helpers

    private var nextLessonId: String? {
        guard let lessonId else { return nil }
        return ContentService.shared.getNextLessonId(after: lessonId)
    }

    private var nextCourseFirstLessonId: String? {
        guard let lessonId else { return nil }
        return ContentService.shared.getNextCourseFirstLessonId(after: lessonId)
    }

    private var nextCourseTitle: String? {
        guard let lessonId else { return nil }
        return ContentService.shared.getNextCourseTitle(after: lessonId)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppLayout.paddingLG) {
                Spacer(minLength: AppLayout.paddingXL)

                scoreCircle

                Text(resultMessage)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                rateText

                if earnedXP > 0 { xpCard }
                if let level = newLevel { levelUpCard(level: level) }
                if !newBadges.isEmpty { badgesCard }

                // 関連する実践演習への案内
                if let chapter = relatedPracticeChapter {
                    practiceExerciseBanner(chapter: chapter)
                }

                Spacer(minLength: AppLayout.paddingMD)

                actionButtons
                    .padding(.bottom, AppLayout.paddingXL)
            }
            .padding(.horizontal, AppLayout.paddingMD)
            .frame(maxWidth: horizontalSizeClass == .regular ? 640 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppColor.background)
        .navigationTitle("クイズ結果")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("閉じる") { dismiss() }
            }
        }
        .onAppear {
            // 結果画面表示時にアニメーションを発火（reduceMotion時は即座に最終状態）
            if reduceMotion {
                animateIn = true
            } else {
                withAnimation { animateIn = true }
            }
        }
    }

    // MARK: - Score Circle

    private var scoreCircle: some View {
        ZStack {
            Circle()
                .fill(resultColor.opacity(0.12))
                .frame(width: 160, height: 160)
                .scaleEffect(animateIn ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateIn)
            Circle()
                .trim(from: 0, to: animateIn ? CGFloat(correctCount) / CGFloat(max(totalCount, 1)) : 0)
                .stroke(resultColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0).delay(0.3), value: animateIn)
            VStack(spacing: 4) {
                Text("\(correctCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(resultColor)
                    .contentTransition(.numericText())
                Text("/ \(totalCount)")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    // MARK: - Rate Text

    private var rateText: some View {
        let rate = Int(Double(correctCount) / Double(max(totalCount, 1)) * 100)
        return Text("正解率: \(rate)%")
            .font(AppFont.callout)
            .foregroundStyle(AppColor.textSecondary)
            .accessibilityLabel("スコア \(correctCount)/\(totalCount)、正解率\(rate)%")
    }

    // MARK: - XP Card

    private var xpCard: some View {
        HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "star.fill")
                .foregroundStyle(AppColor.xpGold)
                .font(.title2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("+\(earnedXP) XP 獲得！")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.xpGold)
                if correctCount == totalCount {
                    Text("パーフェクトボーナス含む")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.xpGold.opacity(0.1), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    // MARK: - Level Up Card

    private func levelUpCard(level: Int) -> some View {
        VStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(AppColor.levelPurple)
                .accessibilityHidden(true)
            Text("レベルアップ！")
                .font(AppFont.title)
                .foregroundStyle(AppColor.levelPurple)
            Text("Level \(level)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.levelPurple)
        }
        .padding(AppLayout.paddingMD)
        .frame(maxWidth: .infinity)
        .background(AppColor.levelPurple.opacity(0.1), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    // MARK: - Badges Card

    private var badgesCard: some View {
        VStack(spacing: AppLayout.paddingSM) {
            Text("新しいバッジを獲得！")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.accent)
            ForEach(newBadges, id: \.self) { badgeId in
                if let def = GamificationService.badgeDefinitions.first(where: { $0.id == badgeId }) {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: def.icon)
                            .font(.title2)
                            .foregroundStyle(Color(hex: def.color))
                        VStack(alignment: .leading) {
                            Text(def.name).font(AppFont.headline).foregroundStyle(AppColor.textPrimary)
                            Text(def.description).font(AppFont.caption).foregroundStyle(AppColor.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(AppLayout.paddingSM)
                    .background(Color(hex: def.color).opacity(0.08), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                }
            }
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.accent.opacity(0.05), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    // MARK: - Result Helpers

    /// このクイズのレッスンに対応する実践演習チャプター
    private var relatedPracticeChapter: PracticeChapter? {
        guard let lessonId else { return nil }
        let courseId = String(lessonId.prefix(while: { $0 != "_" }))
        return PracticeService.shared.practiceChapters.first { $0.id == courseId }
    }

    private var resultColor: Color {
        let rate = Double(correctCount) / Double(max(totalCount, 1))
        if rate >= 0.8 { return AppColor.success }
        if rate >= 0.5 { return AppColor.accent }
        return AppColor.error
    }

    private var resultMessage: String {
        let rate = Double(correctCount) / Double(max(totalCount, 1))
        if rate >= 1.0 { return "パーフェクト！" }
        if rate >= 0.8 { return "素晴らしい！" }
        if rate >= 0.5 { return "いい感じです！" }
        return "もう一度挑戦しましょう"
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: AppLayout.paddingSM) {
            // 次のレッスンへ
            if let nextId = nextLessonId, onNextLesson != nil {
                Button {
                    guard !isNavigating else { return }
                    isNavigating = true
                    onNextLesson?(nextId)
                    Task {
                        try? await Task.sleep(for: .milliseconds(100))
                        dismiss()
                    }
                } label: {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                        Text("次のレッスンへ")
                            .font(AppFont.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppColor.primary, AppColor.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    )
                    .shadow(color: AppColor.primary.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.pressable)
            }

            // 次のコンテンツへ（コース最終レッスン完了時）
            if nextLessonId == nil, let nextCourseId = nextCourseFirstLessonId, onNextLesson != nil {
                Button {
                    guard !isNavigating else { return }
                    isNavigating = true
                    onNextLesson?(nextCourseId)
                    Task {
                        try? await Task.sleep(for: .milliseconds(100))
                        dismiss()
                    }
                } label: {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: "book.and.wrench.fill")
                            .font(.title3)
                        VStack(spacing: 2) {
                            Text("次のコンテンツへ")
                                .font(AppFont.headline)
                            if let title = nextCourseTitle {
                                Text(title)
                                    .font(AppFont.caption)
                                    .opacity(0.8)
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppColor.success, Color(hex: "059669")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    )
                    .shadow(color: AppColor.success.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.pressable)
            }

            // もう一度挑戦（正解率80%未満の場合表示）
            if Double(correctCount) / Double(max(totalCount, 1)) < 0.8, !isReviewMode {
                Button {
                    onRetry()
                } label: {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                        Text("もう一度挑戦")
                            .font(AppFont.headline)
                    }
                    .foregroundStyle(AppColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .stroke(AppColor.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.pressable)
            }

            // 閉じる
            Button { dismiss() } label: {
                Text("閉じる")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.pressable)
        }
        .padding(.horizontal, AppLayout.paddingLG)
    }

    // MARK: - Practice Exercise Banner

    private func practiceExerciseBanner(chapter: PracticeChapter) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack(spacing: AppLayout.paddingSM) {
                Image(systemName: "hammer.fill")
                    .font(.title3)
                    .foregroundStyle(AppColor.practiceIndigo)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("学んだ内容を実践しよう！")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(chapter.title) の実践演習 \(chapter.exercises.count)問")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            NavigationLink(value: chapter) {
                HStack(spacing: 6) {
                    Text("実践演習に挑戦")
                        .font(AppFont.callout)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppColor.practiceIndigo, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
            }
            .buttonStyle(.pressable)
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.practiceIndigo.opacity(0.06), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(AppColor.practiceIndigo.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview("高スコア") {
    NavigationStack {
        QuizResultView(
            correctCount: 4,
            totalCount: 5,
            earnedXP: 60,
            newBadges: ["quiz_10"],
            newLevel: 3,
            lessonId: nil,
            isReviewMode: false,
            onNextLesson: nil,
            onRetry: {}
        )
    }
}

#Preview("低スコア") {
    NavigationStack {
        QuizResultView(
            correctCount: 1,
            totalCount: 5,
            earnedXP: 10,
            newBadges: [],
            newLevel: nil,
            lessonId: nil,
            isReviewMode: false,
            onNextLesson: nil,
            onRetry: {}
        )
    }
}
