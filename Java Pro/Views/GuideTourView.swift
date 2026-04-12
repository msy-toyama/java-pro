//
//  GuideTourView.swift
//  Java Pro
//
//  初回訪問時の画面ガイドツアー。
//  タップで進む吹き出し型のステップバイステップ案内を表示する。
//  ホーム画面・学習画面・試験対策画面で共通利用する再利用コンポーネント。
//

import SwiftUI

// MARK: - Guide Step Model

/// ガイドツアーの1ステップを定義する。
struct GuideStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let accentColor: Color
}

// MARK: - GuideTourOverlay

/// 画面上にオーバーレイとして表示するガイドツアー。
/// タップごとにステップが進み、全ステップ完了後に自動的に閉じる。
struct GuideTourOverlay: View {
    let steps: [GuideStep]
    let onComplete: () -> Void
    private var lang: LanguageManager { LanguageManager.shared }

    @State private var currentStep = 0
    @State private var isVisible = false
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var iconBounce = false
    @State private var progressWidth: CGFloat = 0
    @State private var pulseRing = false
    @State private var isAdvancing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var step: GuideStep {
        steps[currentStep]
    }

    private var isLastStep: Bool {
        currentStep >= steps.count - 1
    }

    var body: some View {
        if steps.isEmpty {
            EmptyView()
        } else {
            tourContent
        }
    }

    private var tourContent: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black
                .opacity(isVisible ? 0.55 : 0)
                .ignoresSafeArea()
                .onTapGesture { advanceStep() }
                .accessibilityLabel(lang.l("guide.accessibility.bg"))
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(lang.l("guide.accessibility.bg_hint"))

            // ガイドカード
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: AppLayout.paddingMD) {
                    // アイコン（アニメーション付き）
                    ZStack {
                        // パルスリング（装飾目的・VoiceOverから除外）
                        Circle()
                            .stroke(step.accentColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseRing ? 1.3 : 1.0)
                            .opacity(pulseRing ? 0 : 0.6)
                            .accessibilityHidden(true)

                        Circle()
                            .fill(step.accentColor.opacity(0.12))
                            .frame(width: 68, height: 68)
                            .accessibilityHidden(true)

                        Image(systemName: step.icon)
                            .font(.system(size: 30))
                            .foregroundStyle(step.accentColor)
                            .offset(y: iconBounce ? -4 : 4)
                            .accessibilityHidden(true)
                    }
                    .padding(.top, AppLayout.paddingMD)

                    // タイトル
                    Text(step.title)
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    // メッセージ
                    Text(step.message)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, AppLayout.paddingSM)
                        .fixedSize(horizontal: false, vertical: true)

                    // 進捗インジケーター
                    HStack(spacing: 6) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentStep ? step.accentColor : AppColor.textTertiary.opacity(0.3))
                                .frame(width: index == currentStep ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        }
                    }
                    .padding(.top, AppLayout.paddingSM)
                    .accessibilityLabel(lang.l("guide.accessibility.step", currentStep + 1, steps.count))

                    // タップして進むボタン
                    Button {
                        advanceStep()
                    } label: {
                        HStack(spacing: 6) {
                            Text(isLastStep ? lang.l("guide.begin") : lang.l("guide.next"))
                                .font(AppFont.headline)
                            if !isLastStep {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppLayout.paddingXL)
                        .padding(.vertical, AppLayout.paddingSM + 2)
                        .background(step.accentColor, in: Capsule())
                    }
                    .buttonStyle(.pressable)
                    .padding(.top, AppLayout.paddingSM)
                    .accessibilityHint(isLastStep ? lang.l("guide.accessibility.end_hint") : lang.l("guide.accessibility.next_hint"))

                    // スキップ
                    if !isLastStep {
                        Button {
                            dismissTour()
                        } label: {
                            Text(lang.l("guide.skip"))
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textTertiary)
                        }
                        .accessibilityHint(lang.l("guide.accessibility.skip_hint"))
                    }

                    // ステップカウント（VoiceOverでは進捗インジケーターで読み上げ済み）
                    Text("\(currentStep + 1) / \(steps.count)")
                        .font(AppFont.codeSmall)
                        .foregroundStyle(AppColor.textTertiary)
                        .padding(.bottom, AppLayout.paddingSM)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: 340)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadiusLarge)
                        .fill(AppColor.cardBackground)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
                )
                .scaleEffect(cardScale)
                .opacity(cardOpacity)

                Spacer()
            }
        }
        .accessibilityAddTraits(.isModal)
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
                cardScale = 1.0
                cardOpacity = 1.0
            }
            if !reduceMotion {
                startIconAnimation()
                startPulse()
            }
        }
    }

    // MARK: - Actions

    private func advanceStep() {
        guard !isAdvancing else { return }
        if isLastStep {
            dismissTour()
        } else {
            isAdvancing = true
            if reduceMotion {
                currentStep += 1
                isAdvancing = false
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    cardScale = 0.9
                    cardOpacity = 0.3
                }

                Task {
                    try? await Task.sleep(for: .milliseconds(150))
                    guard currentStep < steps.count - 1 else {
                        isAdvancing = false
                        return
                    }
                    currentStep += 1
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        cardScale = 1.0
                        cardOpacity = 1.0
                    }
                    if !reduceMotion {
                        startIconAnimation()
                    }
                    isAdvancing = false
                }
            }
        }
    }

    private func dismissTour() {
        guard !isAdvancing else { return }
        isAdvancing = true
        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.3)) {
            cardScale = 0.8
            cardOpacity = 0
            isVisible = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 50 : 350))
            onComplete()
        }
    }

    private func startIconAnimation() {
        iconBounce = false
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            iconBounce = true
        }
    }

    private func startPulse() {
        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseRing = true
        }
    }
}

// MARK: - Guide Tour Definitions

/// 各画面のガイドツアーステップ定義。
@MainActor
enum GuideTourSteps {
    private static var lang: LanguageManager { LanguageManager.shared }

    /// ホーム画面のガイドツアー（初回表示時）
    static var home: [GuideStep] {[
        GuideStep(
            icon: "hand.wave.fill",
             title: lang.l("guide.home.welcome.title"),
            message: lang.l("guide.home.welcome.message"),
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "star.fill",
            title: lang.l("guide.home.xp.title"),
            message: lang.l("guide.home.xp.message"),
            accentColor: AppColor.xpGold
        ),
        GuideStep(
            icon: "flame.fill",
            title: lang.l("guide.home.streak.title"),
            message: lang.l("guide.home.streak.message"),
            accentColor: AppColor.accent
        ),
        GuideStep(
            icon: "trophy.fill",
            title: lang.l("guide.home.badges.title"),
            message: lang.l("guide.home.badges.message"),
            accentColor: AppColor.levelPurple
        ),
        GuideStep(
            icon: "target",
            title: lang.l("guide.home.goal.title"),
            message: lang.l("guide.home.goal.message"),
            accentColor: AppColor.success
        )
    ]}

    /// 学習画面（コース一覧）のガイドツアー
    static var learn: [GuideStep] {[
        GuideStep(
            icon: "book.fill",
            title: lang.l("guide.learn.courses.title"),
            message: lang.l("guide.learn.courses.message", ContentService.shared.totalLessonCount),
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "list.bullet.rectangle.portrait",
            title: lang.l("guide.learn.lesson_flow.title"),
            message: lang.l("guide.learn.lesson_flow.message"),
            accentColor: AppColor.success
        ),
        GuideStep(
            icon: "lock.open.fill",
            title: lang.l("guide.learn.pro.title"),
            message: lang.l("guide.learn.pro.message"),
            accentColor: AppColor.accent
        ),
        GuideStep(
            icon: "arrow.counterclockwise.circle.fill",
            title: lang.l("guide.learn.review.title"),
            message: lang.l("guide.learn.review.message"),
            accentColor: AppColor.warning
        )
    ]}

    /// 実践演習画面のガイドツアー
    static var practice: [GuideStep] {[
        GuideStep(
            icon: "chevron.left.forwardslash.chevron.right",
            title: lang.l("guide.practice.title"),
            message: lang.l("guide.practice.message"),
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "wrench.and.screwdriver.fill",
            title: lang.l("guide.practice.setup.title"),
            message: lang.l("guide.practice.setup.message"),
            accentColor: AppColor.success
        ),
        GuideStep(
            icon: "lightbulb.fill",
            title: lang.l("guide.practice.hints.title"),
            message: lang.l("guide.practice.hints.message"),
            accentColor: AppColor.accent
        ),
        GuideStep(
            icon: "square.and.arrow.down",
            title: lang.l("guide.practice.download.title"),
            message: lang.l("guide.practice.download.message"),
            accentColor: Color(hex: "#6366F1")
        )
    ]}

    /// 試験対策画面のガイドツアー
    static var exam: [GuideStep] {[
        GuideStep(
            icon: "graduationcap.fill",
            title: lang.l("guide.exam.title"),
            message: lang.l("guide.exam.message"),
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "doc.text.fill",
            title: lang.l("guide.exam.mock.title"),
            message: lang.l("guide.exam.mock.message"),
            accentColor: AppColor.info
        ),
        GuideStep(
            icon: "exclamationmark.shield.fill",
            title: lang.l("guide.exam.disclaimer.title"),
            message: lang.l("guide.exam.disclaimer.message"),
            accentColor: AppColor.warning
        ),
        GuideStep(
            icon: "chart.bar.fill",
            title: lang.l("guide.exam.analysis.title"),
            message: lang.l("guide.exam.analysis.message"),
            accentColor: AppColor.error
        ),
        GuideStep(
            icon: "checkmark.seal.fill",
            title: lang.l("guide.exam.goal.title"),
            message: lang.l("guide.exam.goal.message", ExamService.passingRatePercent),
            accentColor: AppColor.success
        )
    ]}
}

// MARK: - UserDefaults Keys for Tour State

extension UserDefaults {
    private enum TourKeys {
        static let hasSeenHomeTour = "hasSeenHomeTour"
        static let hasSeenLearnTour = "hasSeenLearnTour"
        static let hasSeenExamTour = "hasSeenExamTour"
        static let hasSeenPracticeTour = "hasSeenPracticeTour"
    }

    var hasSeenHomeTour: Bool {
        get { bool(forKey: TourKeys.hasSeenHomeTour) }
        set { set(newValue, forKey: TourKeys.hasSeenHomeTour) }
    }

    var hasSeenLearnTour: Bool {
        get { bool(forKey: TourKeys.hasSeenLearnTour) }
        set { set(newValue, forKey: TourKeys.hasSeenLearnTour) }
    }

    var hasSeenExamTour: Bool {
        get { bool(forKey: TourKeys.hasSeenExamTour) }
        set { set(newValue, forKey: TourKeys.hasSeenExamTour) }
    }

    var hasSeenPracticeTour: Bool {
        get { bool(forKey: TourKeys.hasSeenPracticeTour) }
        set { set(newValue, forKey: TourKeys.hasSeenPracticeTour) }
    }
}
