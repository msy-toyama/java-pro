//
//  CertificationView.swift
//  Java Pro
//
//  資格学習ダッシュボード。Silver / Gold の学習進捗・模擬試験への導線・
//  弱点分析サマリーを一覧表示する。
//

import SwiftUI
import SwiftData

struct CertificationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var silverProgress: CertProgress?
    @State private var goldProgress: CertProgress?
    @State private var selectedCert: CertificationLevel = .silver
    @State private var selectedVersion: ExamService.JavaVersion = .se11
    @State private var selectedExamItem: ExamItem?
    @State private var showExamHistory = false
    @State private var showPaywall = false
    @State private var examAttempts: [String: Int] = [:]
    @State private var showGuideTour = false

    private var lang: LanguageManager { LanguageManager.shared }

    /// fullScreenCover(item:) 用の Identifiable ラッパー
    struct ExamItem: Identifiable, Equatable {
        let id: String
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppLayout.paddingLG) {
                    // 資格セグメント
                    certPicker
                        .staggeredAppear(index: 0)

                    // 進捗カード
                    if let progress = selectedCert == .silver ? silverProgress : goldProgress {
                        progressCard(progress)
                            .staggeredAppear(index: 1)
                    }

                    // 模擬試験セクション
                    examSection
                        .staggeredAppear(index: 2)

                    // チャプター別進捗（模擬試験の下に配置）
                    if let progress = selectedCert == .silver ? silverProgress : goldProgress {
                        topicProgressSection(progress)
                            .staggeredAppear(index: 3)
                    }

                    // 履歴リンク
                    NavigationLink {
                        ExamHistoryView(certLevel: selectedCert)
                    } label: {
                        HStack {
                            Label(lang.l("cert.exam_history"), systemImage: "clock.arrow.circlepath")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColor.textTertiary)
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(AppLayout.paddingMD)
                        .modifier(CardStyle())
                    }
                    .buttonStyle(.pressable)
                    .staggeredAppear(index: 4)
                    .accessibilityHint(lang.l("cert.exam_history_hint"))

                    // 弱点リンク
                    NavigationLink {
                        WeakPointView(certLevel: selectedCert == .gold ? "gold" : "silver")
                    } label: {
                        HStack {
                            Label(lang.l("cert.weak_points"), systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppColor.accent)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColor.textTertiary)
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(AppLayout.paddingMD)
                        .modifier(CardStyle())
                    }
                    .buttonStyle(.pressable)
                    .staggeredAppear(index: 5)
                    .accessibilityHint(lang.l("cert.weak_points_hint"))

                    // 復習セクション
                    NavigationLink {
                        ReviewView()
                    } label: {
                        HStack {
                            Label(lang.l("cert.review"), systemImage: "arrow.counterclockwise.circle.fill")
                                .foregroundStyle(AppColor.warning)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColor.textTertiary)
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(AppLayout.paddingMD)
                        .modifier(CardStyle())
                    }
                    .buttonStyle(.pressable)
                    .staggeredAppear(index: 6)
                    .accessibilityHint(lang.l("cert.review_hint"))

                    // 非公式免責表示
                    Text(lang.l("cert.disclaimer"))
                        .font(.system(size: 11))
                        .foregroundStyle(AppColor.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppLayout.paddingSM)
                }
                .padding(AppLayout.paddingMD)
            }
            .background(AppColor.background)
            .navigationTitle(lang.l("cert.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { BrandedTitleView(title: lang.l("cert.title"), icon: "medal.fill", subtitle: "Silver / Gold") } }
            .onAppear {
                loadData()
                if !showGuideTour && !UserDefaults.standard.hasSeenExamTour {
                    Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        showGuideTour = true
                    }
                }
            }
            .overlay {
                if showGuideTour {
                    GuideTourOverlay(steps: GuideTourSteps.exam) {
                        showGuideTour = false
                        UserDefaults.standard.hasSeenExamTour = true
                    }
                }
            }
            .fullScreenCover(item: $selectedExamItem) { item in
                ExamSimulatorView(examId: item.id)
            }
            .onChange(of: selectedExamItem) { oldValue, newValue in
                // 模擬試験画面が閉じられたらデータを再読み込み
                if oldValue != nil && newValue == nil {
                    loadData()
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Cert Picker

    private var certPicker: some View {
        VStack(spacing: AppLayout.paddingSM) {
            // 資格レベル選択
            Picker(lang.l("cert.level"), selection: $selectedCert) {
                Text("Silver").tag(CertificationLevel.silver)
                Text("Gold").tag(CertificationLevel.gold)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedCert) { _, _ in loadData() }

            // Javaバージョン選択
            Picker(lang.l("cert.java_version"), selection: $selectedVersion) {
                Text("SE 11").tag(ExamService.JavaVersion.se11)
                Text("SE 17").tag(ExamService.JavaVersion.se17)
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedVersion) { _, _ in loadData() }
        }
    }

    // MARK: - Progress Card

    private func progressCard(_ progress: CertProgress) -> some View {
        VStack(spacing: AppLayout.paddingSM) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Java \(selectedCert == .silver ? "Silver" : "Gold") \(selectedVersion.displayName)")
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(progress.examPassed ? lang.l("cert.passed") : lang.l("cert.progress"))
                        .font(AppFont.caption)
                        .foregroundStyle(progress.examPassed ? AppColor.success : AppColor.textSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(AppColor.textTertiary.opacity(0.2), lineWidth: 6)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: lessonProgressRate(progress))
                        .stroke(AppColor.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(lessonProgressRate(progress) * 100))%")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }

            HStack(spacing: AppLayout.paddingLG) {
                statItem(title: lang.l("cert.lessons"), value: "\(progress.completedLessons)/\(progress.totalLessons)")
                statItem(title: lang.l("cert.quiz_correct"), value: "\(progress.correctQuizzes)/\(progress.totalQuizzes)")
                if let best = progress.bestExamScore {
                    statItem(title: lang.l("cert.best_score"), value: "\(Int(best * 100))%")
                }
            }
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    private func lessonProgressRate(_ progress: CertProgress) -> Double {
        guard progress.totalLessons > 0 else { return 0 }
        return Double(progress.completedLessons) / Double(progress.totalLessons)
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(AppColor.textTertiary)
        }
    }

    // MARK: - Topic Progress

    private func topicProgressSection(_ progress: CertProgress) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("cert.chapter_progress"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            ForEach(progress.topicProgress.indices, id: \.self) { index in
                let topic = progress.topicProgress[index]
                HStack {
                    Text(topic.topic)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text("\(topic.completed)/\(topic.total)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                ProgressView(value: topic.total > 0 ? Double(topic.completed) / Double(topic.total) : 0)
                    .tint(topic.completed == topic.total && topic.total > 0 ? AppColor.success : AppColor.primary)
            }
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    // MARK: - Exam Section

    private var examSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(AppColor.primary)
                Text(lang.l("cert.mock_exam"))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
            }

            let exams = ExamService.exams(certLevel: selectedCert, javaVersion: selectedVersion)

            ForEach(exams, id: \.id) { exam in
                let attempts = examAttempts[exam.id] ?? 0
                let canAccess = StoreService.shared.canAccessExam(examId: exam.id)

                Button {
                    if canAccess {
                        selectedExamItem = ExamItem(id: exam.id)
                    } else {
                        showPaywall = true
                    }
                } label: {
                    HStack(spacing: AppLayout.paddingSM) {
                        // 試験アイコン
                        ZStack {
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                                .fill(canAccess ? AppColor.primary.opacity(0.1) : AppColor.textTertiary.opacity(0.08))
                                .frame(width: 44, height: 44)
                            Image(systemName: canAccess ? "doc.text.fill" : "lock.fill")
                                .font(.title3)
                                .foregroundStyle(canAccess ? AppColor.primary : AppColor.accent)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(lang.l(exam.titleKey))
                                    .font(AppFont.headline)
                                    .foregroundStyle(canAccess ? AppColor.textPrimary : AppColor.textTertiary)
                                if !canAccess {
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(AppColor.accent, in: Capsule())
                                }
                            }
                            Text(lang.l(exam.subtitleKey))
                                .font(.system(size: 11))
                                .foregroundStyle(AppColor.textTertiary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if attempts > 0 {
                                Text(lang.l("cert.attempt_count", attempts))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppColor.primary)
                                Text(lang.l("cert.attempt_label"))
                                    .font(.system(size: 9))
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppColor.textTertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(AppLayout.paddingMD)
                    .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                    .shadow(color: .black.opacity(0.03), radius: 4, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .stroke(canAccess ? Color.clear : AppColor.accent.opacity(0.15), lineWidth: 1)
                    )
                }
            }
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    // MARK: - Data

    private func loadData() {
        let analytics = AnalyticsService(modelContext: modelContext)
        silverProgress = analytics.certificationProgress(level: .silver)
        goldProgress = analytics.certificationProgress(level: .gold)

        let examService = ExamService(modelContext: modelContext)
        var attempts: [String: Int] = [:]
        for exam in ExamService.examDefinitions {
            attempts[exam.id] = examService.attemptCount(examId: exam.id)
        }
        examAttempts = attempts
    }
}
