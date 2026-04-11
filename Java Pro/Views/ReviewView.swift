//
//  ReviewView.swift
//  Java Pro
//
//  忘却曲線ベースの復習画面。復習が必要なクイズを一覧表示し、
//  タップで復習モードに入る。復習完了で間隔ステージが進む。
//

import SwiftUI
import SwiftData

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var reviewQuizzes: [QuizData] = []
    @State private var weakCourses: [(CourseIndex, Double)] = []
    @State private var showReviewQuiz = false

    var body: some View {
        Group {
            if reviewQuizzes.isEmpty {
                emptyState
            } else {
                reviewContent
            }
        }
        .background(AppColor.background)
        .navigationTitle("復習")
        .onAppear(perform: loadData)
        .sheet(isPresented: $showReviewQuiz) {
            QuizView(quizzes: reviewQuizzes, isReviewMode: true, onComplete: {
                // 復習完了後にリロード
                loadData()
            })
        }
    }

    // MARK: - 復習コンテンツあり

    private var reviewContent: some View {
        ScrollView {
            VStack(spacing: AppLayout.paddingLG) {
                // 復習開始カード
                startReviewCard
                    .staggeredAppear(index: 0)

                // 復習件数サマリー
                reviewSummary
                    .staggeredAppear(index: 1)

                // 苦手コース
                if !weakCourses.isEmpty {
                    weakCoursesSection
                        .staggeredAppear(index: 2)
                }
            }
            .padding(AppLayout.paddingMD)
        }
    }

    private var startReviewCard: some View {
        Button {
            showReviewQuiz = true
        } label: {
            VStack(spacing: AppLayout.paddingSM) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColor.primary)
                    .pulse(min: 0.92, max: 1.08, duration: 1.5)
                    .accessibilityHidden(true)
                Text("復習を開始する")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(reviewQuizzes.count) 問")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(AppLayout.paddingLG)
            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusLarge))
            .shadow(color: .black.opacity(0.05), radius: AppLayout.cardShadowRadius, y: AppLayout.cardShadowY)
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("復習を開始、\(reviewQuizzes.count)問")
        .accessibilityHint("復習クイズを開始します")
    }

    private var reviewSummary: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text("復習の仕組み")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                reviewStageRow(emoji: "🔴", text: "間違えた直後 → 即復習")
                reviewStageRow(emoji: "🟠", text: "1回正解 → 24時間後に復習")
                reviewStageRow(emoji: "🟡", text: "2回正解 → 3日後に復習")
                reviewStageRow(emoji: "🟢", text: "3回正解 → 7日後に復習")
                reviewStageRow(emoji: "✅", text: "4回正解 → 定着完了！")
            }
        }
        .modifier(CardStyle())
    }

    private func reviewStageRow(emoji: String, text: String) -> some View {
        HStack(spacing: AppLayout.paddingSM) {
            Text(emoji)
            Text(text)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var weakCoursesSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text("苦手なテーマ")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            ForEach(weakCourses.indices, id: \.self) { index in
                let course = weakCourses[index].0
                let rate = weakCourses[index].1
                HStack {
                    Image(systemName: course.iconName)
                        .foregroundStyle(AppColor.chapterColor(order: course.order))
                    Text(course.title)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Text("\(Int(rate * 100))%")
                        .font(AppFont.caption)
                        .foregroundStyle(rate < 0.5 ? AppColor.error : AppColor.warning)
                }
            }
        }
        .modifier(CardStyle())
    }

    // MARK: - 空状態

    private var emptyState: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppColor.success)
            Text("復習するクイズはありません")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)
            Text("レッスンを進めてクイズに回答すると\nここに復習が表示されます")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Data

    private func loadData() {
        let reviewService = ReviewService(modelContext: modelContext)
        // 全対象クイズの最新履歴を1回のクエリで一括取得
        let allLatest = reviewService.allLatestHistories()
        reviewQuizzes = reviewService.getReviewQueue(using: allLatest)

        // 苦手コース（キャッシュ済みバッチを再利用し N+1 クエリを回避）
        let weakIds = reviewService.weakCourseIds(limit: 3, using: allLatest)
        weakCourses = weakIds.compactMap { courseId -> (CourseIndex, Double)? in
            guard let course = ContentService.shared.getCourse(id: courseId) else { return nil }
            let lessons = ContentService.shared.getLessons(courseId: courseId)
            var total = 0
            var correct = 0
            for lesson in lessons {
                for quiz in lesson.quizzes {
                    if let h = allLatest[quiz.id] {
                        total += 1
                        if h.isCorrect { correct += 1 }
                    }
                }
            }
            let rate = total > 0 ? Double(correct) / Double(total) : 1.0
            return (course, rate)
        }
    }
}
