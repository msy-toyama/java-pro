//
//  ThemeComponents.swift
//  Java Pro
//
//  再利用可能なUIコンポーネントとトランジション修飾子。
//  フローティングパーティクル、スライドトランジション、
//  セクション出現、タイマー警告、成功バウンス、ブランドタイトルを提供する。
//

import SwiftUI

// MARK: - フローティングパーティクル（LaunchScreen用）

/// 小さな光の粒子が浮遊する背景演出。
struct FloatingParticlesView: View {
    let particleCount: Int
    let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    init(count: Int = 20, color: Color = .white) {
        self.particleCount = count
        self.color = color
    }

    var body: some View {
        if reduceMotion || scenePhase != .active {
            Color.clear
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 20)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    for i in 0..<particleCount {
                        let seed = Double(i) * 137.508  // 黄金角ベース
                        let x = (sin(time * 0.3 + seed) * 0.4 + 0.5) * size.width
                        let y = (cos(time * 0.2 + seed * 0.7) * 0.4 + 0.5) * size.height
                        let alpha = sin(time * 0.5 + seed) * 0.3 + 0.3
                        let radius = CGFloat(2 + sin(time + seed) * 1.5)

                        context.opacity = max(0.05, alpha)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                            with: .color(color)
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - スライドトランジション

/// 横スライドで問題を切り替えるトランジション修飾子。
struct SlideTransitionModifier: ViewModifier {
    let id: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .id(id)
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.82), value: id)
    }
}

extension View {
    /// コンテンツをスライドトランジションで切り替え。試験画面の問題遷移に。
    func slideTransition(id: Int) -> some View {
        modifier(SlideTransitionModifier(id: id))
    }
}

// MARK: - セクション出現アニメーション

/// List セクションが出現時にフェードインする修飾子。
struct SectionAppearModifier: ViewModifier {
    let index: Int
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .onAppear {
                guard !appeared else { return }
                if reduceMotion {
                    appeared = true
                    return
                }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.08)) {
                    appeared = true
                }
            }
    }
}

extension View {
    /// セクション出現アニメーション。設定画面のセクションなどに。
    func sectionAppear(index: Int) -> some View {
        modifier(SectionAppearModifier(index: index))
    }
}

// MARK: - タイマー警告アニメーション

/// 残り時間が少ないときに点滅する修飾子。
struct TimerWarningModifier: ViewModifier {
    let isWarning: Bool
    @State private var blinking = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isWarning && blinking && !reduceMotion ? 0.4 : 1.0)
            .animation(
                isWarning && !reduceMotion
                    ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                    : nil,
                value: blinking
            )
            .onChange(of: isWarning) { _, newValue in
                blinking = newValue
            }
            .onAppear {
                if isWarning { blinking = true }
            }
    }
}

extension View {
    /// タイマー警告点滅エフェクト。残り時間が少ないときに。
    func timerWarning(_ isWarning: Bool) -> some View {
        modifier(TimerWarningModifier(isWarning: isWarning))
    }
}

// MARK: - 成功バウンスアニメーション

/// 正解時や達成時にバウンスするアニメーション修飾子。
struct SuccessBounceModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var scale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _, newValue in
                guard newValue, !reduceMotion else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    scale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.15)) {
                    scale = 1.0
                }
                // Reset trigger after animation
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    trigger = false
                }
            }
    }
}

extension View {
    /// 成功バウンスアニメーション。正解時やバッジ獲得時に。
    func successBounce(trigger: Binding<Bool>) -> some View {
        modifier(SuccessBounceModifier(trigger: trigger))
    }
}

// MARK: - ブランドタイトル

/// ナビゲーションバーの `.principal` に配置するブランドタイトル。
struct BrandedTitleView: View {
    let title: String
    let icon: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.primary, AppColor.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
        }
    }
}
