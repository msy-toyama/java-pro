//
//  ConfettiView.swift
//  Java Pro
//
//  正解・レベルアップ時の紙吹雪アニメーション。
//  Reduce Motion が有効な場合はアニメーションなしで即座にフェードアウトする。
//

import SwiftUI

/// 紙吹雪パーティクルを画面に散らすオーバーレイビュー。
struct ConfettiView: View {
    @Binding var isActive: Bool
    var particleCount: Int = 60
    var duration: Double = 2.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var particles: [ConfettiParticle] = []
    @State private var animationProgress: CGFloat = 0
    @State private var cleanupTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    particle.shape
                        .foregroundStyle(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(animationProgress * particle.spinSpeed))
                        .position(
                            x: particle.startX * geo.size.width + animationProgress * particle.driftX,
                            y: reduceMotion
                                ? geo.size.height * 0.5
                                : -particle.size + animationProgress * (geo.size.height + particle.size * 2) * particle.speedMultiplier
                        )
                        .opacity(animationProgress < 0.8 ? 1.0 : max(0, 1.0 - (animationProgress - 0.8) / 0.2))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            if isActive { startConfetti() }
        }
        .onChange(of: isActive) { _, active in
            if active { startConfetti() }
        }
    }

    private func startConfetti() {
        // 前回のクリーンアップタスクをキャンセル（高速トグル対策）
        cleanupTask?.cancel()

        particles = (0..<particleCount).map { _ in ConfettiParticle.random() }
        animationProgress = 0

        if reduceMotion {
            // Reduce Motion: 即座に表示してフェードアウトのみ
            animationProgress = 0.5
            withAnimation(.easeOut(duration: 0.5)) {
                animationProgress = 1.0
            }
        } else {
            withAnimation(.easeOut(duration: duration)) {
                animationProgress = 1.0
            }
        }

        // 終了後に非アクティブに
        cleanupTask = Task {
            try? await Task.sleep(for: .seconds(reduceMotion ? 0.6 : duration + 0.2))
            guard !Task.isCancelled else { return }
            isActive = false
            particles = []
        }
    }
}

// MARK: - パーティクル

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let shape: AnyView
    let size: CGFloat
    let startX: CGFloat       // 0-1 の水平位置割合
    let driftX: CGFloat       // 水平ドリフト量
    let spinSpeed: Double     // 回転速度
    let speedMultiplier: CGFloat  // 落下速度倍率

    static func random() -> ConfettiParticle {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .cyan
        ]
        let shapes: [AnyView] = [
            AnyView(Circle()),
            AnyView(Rectangle()),
            AnyView(RoundedRectangle(cornerRadius: 2)),
            AnyView(Capsule()),
        ]
        return ConfettiParticle(
            color: colors.randomElement() ?? .red,
            shape: shapes.randomElement() ?? AnyView(Circle()),
            size: CGFloat.random(in: 4...10),
            startX: CGFloat.random(in: 0...1),
            driftX: CGFloat.random(in: -60...60),
            spinSpeed: Double.random(in: 180...720),
            speedMultiplier: CGFloat.random(in: 0.7...1.3)
        )
    }
}

// MARK: - ViewModifier

extension View {
    /// 紙吹雪を表示するオーバーレイを付与する。
    func confettiOverlay(isActive: Binding<Bool>, particleCount: Int = 60) -> some View {
        overlay {
            if isActive.wrappedValue {
                ConfettiView(isActive: isActive, particleCount: particleCount)
            }
        }
    }
}
