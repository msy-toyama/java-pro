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
                .accessibilityLabel("ガイドツアー背景")
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("タップして次のステップへ進みます")

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
                    .accessibilityLabel("ステップ \(currentStep + 1) / \(steps.count)")

                    // タップして進むボタン
                    Button {
                        advanceStep()
                    } label: {
                        HStack(spacing: 6) {
                            Text(isLastStep ? "はじめる" : "次へ")
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
                    .accessibilityHint(isLastStep ? "ガイドツアーを終了してアプリを開始します" : "次のガイドステップに進みます")

                    // スキップ
                    if !isLastStep {
                        Button {
                            dismissTour()
                        } label: {
                            Text("スキップ")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textTertiary)
                        }
                        .accessibilityHint("ガイドツアーをスキップします")
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
enum GuideTourSteps {

    /// ホーム画面のガイドツアー（初回表示時）
    static let home: [GuideStep] = [
        GuideStep(
            icon: "hand.wave.fill",
             title: "ようこそ プロプロ へ！",
            message: "このホーム画面があなたの学習ダッシュボードです。\n今日の学習状況がひと目でわかります。",
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "star.fill",
            title: "XPを貯めてレベルアップ",
            message: "レッスンやクイズを完了するとXP（経験値）がもらえます。\nXPを貯めてレベルを上げましょう！",
            accentColor: AppColor.xpGold
        ),
        GuideStep(
            icon: "flame.fill",
            title: "連続学習でストリーク獲得",
            message: "毎日学習を続けると連続日数が増えます。\nストリークを伸ばしてモチベーションを維持しましょう！",
            accentColor: AppColor.accent
        ),
        GuideStep(
            icon: "trophy.fill",
            title: "バッジを集めよう",
            message: "学習の節目や達成条件に応じてバッジが獲得できます。\nレッスン完了・ストリーク継続・試験合格など\nさまざまなバッジを目指しましょう！",
            accentColor: AppColor.levelPurple
        ),
        GuideStep(
            icon: "target",
            title: "目標を設定して学習",
            message: "1日の学習時間の目標を設定できます。\n目標を達成すると進捗バーが満たされます。\n無理なく自分のペースで続けましょう！",
            accentColor: AppColor.success
        )
    ]

    /// 学習画面（コース一覧）のガイドツアー
    static var learn: [GuideStep] {[
        GuideStep(
            icon: "book.fill",
            title: "学習コース",
            message: "Javaの基礎から応用まで、体系的に学べる\n全\(ContentService.shared.totalLessonCount)レッスンが用意されています。\n上から順番に進めるのがおすすめです。",
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "list.bullet.rectangle.portrait",
            title: "レッスンの進め方",
            message: "各レッスンは解説→コード例→クイズの流れです。\nクイズに正解するとレッスンが完了し、\nXPが獲得できます。",
            accentColor: AppColor.success
        ),
        GuideStep(
            icon: "lock.open.fill",
            title: "無料 & Proコンテンツ",
            message: "入門〜継承までのレッスンは無料で学べます。\nポリモーフィズム以降のコンテンツは\nProプランですべてアクセスできます。",
            accentColor: AppColor.accent
        ),
        GuideStep(
            icon: "arrow.counterclockwise.circle.fill",
            title: "復習で定着",
            message: "完了したレッスンは時間をあけて復習できます。\n間隔反復学習で記憶の定着率がアップします。",
            accentColor: AppColor.warning
        )
    ]}

    /// 実践演習画面のガイドツアー
    static let practice: [GuideStep] = [
        GuideStep(
            icon: "chevron.left.forwardslash.chevron.right",
            title: "実践演習",
            message: "学んだ知識を実際のコードで確認できます。\n各章のテーマに沿った\nコーディング課題に挑戦しましょう。",
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "wrench.and.screwdriver.fill",
            title: "まずは環境構築",
            message: "最初に環境構築ガイドを見て\nJavaの実行環境を準備してください。\nWindows/Mac 両方の手順を用意しています。",
            accentColor: AppColor.success
        ),
        GuideStep(
            icon: "lightbulb.fill",
            title: "ヒントと解答付き",
            message: "わからない問題にはヒントが用意されています。\n解答コードにはコメント付きで\n初学者でも理解できるようにしています。",
            accentColor: AppColor.accent
        ),
        GuideStep(
            icon: "square.and.arrow.down",
            title: ".java ファイルをダウンロード",
            message: "解答コードは .java ファイルとして\nダウンロードできます。\nお手元の環境で実行して動作を確認しましょう。",
            accentColor: Color(hex: "#6366F1")
        )
    ]

    /// 試験対策画面のガイドツアー
    static let exam: [GuideStep] = [
        GuideStep(
            icon: "graduationcap.fill",
            title: "試験対策モード",
            message: "Oracle Java認定資格の\nSilver / Gold 試験対策ができます。\n学習進捗と模擬試験をここで管理します。",
            accentColor: AppColor.primary
        ),
        GuideStep(
            icon: "doc.text.fill",
            title: "模擬試験にチャレンジ",
            message: "本番に近い形式の模擬試験を受けられます。\nタイマー付きで時間管理の練習もできます。\nSE 11 と SE 17 の両方に対応しています。",
            accentColor: AppColor.info
        ),
        GuideStep(
            icon: "exclamationmark.shield.fill",
            title: "非公式の模擬試験です",
            message: "本アプリの模擬試験はOracle公式ではありません。\n本番の出題傾向に基づいた学習用教材として\n作成しています。実力チェックにご活用ください。",
            accentColor: AppColor.warning
        ),
        GuideStep(
            icon: "chart.bar.fill",
            title: "弱点を分析",
            message: "模擬試験の結果からトピック別の正答率を分析し、\n弱点を可視化します。\n苦手分野を重点的に復習しましょう。",
            accentColor: AppColor.error
        ),
        GuideStep(
            icon: "checkmark.seal.fill",
            title: "合格を目指そう",
            message: "合格ラインは正答率\(ExamService.passingRatePercent)%です。\n模擬試験を繰り返し受けて\n確実に合格できる力を身につけましょう！",
            accentColor: AppColor.success
        )
    ]
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
