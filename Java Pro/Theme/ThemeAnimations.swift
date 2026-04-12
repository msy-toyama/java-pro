//
//  ThemeAnimations.swift
//  Java Pro
//
//  アニメーション関連のViewModifierとユーティリティコンポーネント。
//  カード入場、シマー、パルス、プログレスバー、
//  グローカード、カウントアップアニメーションを提供する。
//

import SwiftUI

// MARK: - カード入場アニメーション

/// 段階的にフェードイン＋スライドアップするカード入場修飾子。
struct StaggeredCardAppear: ViewModifier {
    let index: Int
    let totalCount: Int
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                if reduceMotion {
                    appeared = true
                    return
                }
                let delay = Double(index) * 0.06
                withAnimation(.spring(response: 0.5, dampingFraction: 0.78).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    /// 段階的入場アニメーション。indexが大きいほど遅延する。
    func staggeredAppear(index: Int, total: Int = 10) -> some View {
        modifier(StaggeredCardAppear(index: index, totalCount: total))
    }
}

// MARK: - シマーエフェクト

/// 対角線方向に光のグラデーションがスライドするプレミアム感のある演出。
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0
    let duration: Double
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(duration: Double = 2.5, isActive: Bool = true) {
        self.duration = duration
        self.isActive = isActive
    }

    private var shouldAnimate: Bool { isActive && !reduceMotion }

    func body(content: Content) -> some View {
        content
            .overlay {
                if shouldAnimate {
                    GeometryReader { geo in
                        let width = geo.size.width
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: max(0, phase - 0.15)),
                                .init(color: .white.opacity(0.25), location: max(0, min(1, phase))),
                                .init(color: .clear, location: min(1, phase + 0.15)),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: width * 2)
                        .offset(x: -width * 0.5)
                        .blendMode(.overlay)
                    }
                    .clipped()
                }
            }
            .onAppear {
                guard shouldAnimate else { return }
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 2.0
                }
            }
    }
}

extension View {
    /// シマー（光沢スライド）エフェクト。レベルバッジや重要要素に。
    func shimmer(duration: Double = 2.5, isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(duration: duration, isActive: isActive))
    }
}

// MARK: - パルスエフェクト

/// 対象ビューをゆっくり拡縮してアテンションを引く。
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let minScale: CGFloat
    let maxScale: CGFloat
    let duration: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: Double = 1.2) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing && !reduceMotion ? maxScale : (reduceMotion ? 1.0 : minScale))
            .animation(
                reduceMotion ? nil : .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                guard !reduceMotion else { return }
                isPulsing = true
            }
    }
}

extension View {
    /// パルス（拡縮繰り返し）アニメーション。ストリーク炎やCTAに。
    func pulse(min: CGFloat = 0.95, max: CGFloat = 1.05, duration: Double = 1.2) -> some View {
        modifier(PulseModifier(minScale: min, maxScale: max, duration: duration))
    }
}

// MARK: - アニメ付きプログレスバー

/// 出現時に 0 → 実値までアニメーションするプログレスバー。
struct AnimatedProgressBar: View {
    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let gradient: LinearGradient?
    let cornerRadius: CGFloat

    @State private var animatedProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        progress: Double,
        height: CGFloat = 6,
        backgroundColor: Color = AppColor.primary.opacity(0.12),
        foregroundColor: Color = AppColor.primary,
        gradient: LinearGradient? = nil,
        cornerRadius: CGFloat = 4
    ) {
        self.progress = progress
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.gradient = gradient
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)
                if let gradient {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(gradient)
                        .frame(width: geometry.size.width * animatedProgress, height: height)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * animatedProgress, height: height)
                }
            }
        }
        .frame(height: height)
        .accessibilityLabel(LanguageManager.shared.l("common.progress"))
        .accessibilityValue("\(Int(progress * 100))%")
        .onAppear {
            if reduceMotion {
                animatedProgress = progress
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - グロー付きカードスタイル

/// 重要なカード（レベル表示など）にグロー効果を追加するスタイル。
struct GlowCardStyle: ViewModifier {
    let glowColor: Color
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(AppLayout.paddingMD)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .shadow(
                color: colorScheme == .dark
                    ? glowColor.opacity(0.15)
                    : .black.opacity(0.06),
                radius: colorScheme == .dark ? 12 : AppLayout.cardShadowRadius,
                y: AppLayout.cardShadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(
                        colorScheme == .dark
                            ? glowColor.opacity(0.2)
                            : glowColor.opacity(0.08),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    /// グロー効果付きカードスタイル。レベルカードやXP表示に。
    func glowCard(color: Color = AppColor.primary) -> some View {
        modifier(GlowCardStyle(glowColor: color))
    }
}

// MARK: - カウントアップアニメーション

/// 数値を 0 からターゲットまでカウントアップ表示する。
struct CountUpText: View {
    let target: Int
    let font: Font
    let color: Color
    let duration: Double

    @State private var displayValue: Int = 0
    @State private var animationTask: Task<Void, Never>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(_ target: Int, font: Font = AppFont.title, color: Color = AppColor.textPrimary, duration: Double = 0.8) {
        self.target = target
        self.font = font
        self.color = color
        self.duration = duration
    }

    var body: some View {
        Text("\(displayValue)")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .accessibilityValue("\(target)")
            .onAppear {
                if reduceMotion || target == 0 {
                    displayValue = target
                    return
                }
                animateCount()
            }
            .onChange(of: target) { _, newValue in
                if reduceMotion {
                    displayValue = newValue
                } else {
                    animateCount()
                }
            }
            .onDisappear {
                animationTask?.cancel()
                animationTask = nil
            }
    }

    private func animateCount() {
        animationTask?.cancel()

        let steps = min(target, 30)
        guard steps > 0 else {
            displayValue = target
            return
        }
        let interval = duration / Double(steps)
        let capturedTarget = target
        animationTask = Task {
            for i in 1...steps {
                try? await Task.sleep(for: .milliseconds(Int(interval * 1000)))
                if Task.isCancelled { return }
                withAnimation(.easeOut(duration: 0.1)) {
                    displayValue = capturedTarget * i / steps
                }
            }
            if !Task.isCancelled {
                withAnimation { displayValue = capturedTarget }
            }
        }
    }
}
