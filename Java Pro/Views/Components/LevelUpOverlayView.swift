//
//  LevelUpOverlayView.swift
//  Java Pro
//
//  レベルアップ時のフルスクリーンオーバーレイアニメーション。
//  Reduce Motion 有効時はアニメーションを省略する。
//

import SwiftUI

/// レベルアップを祝福するフルスクリーンオーバーレイ。
struct LevelUpOverlayView: View {
    let level: Int
    @Binding var isPresented: Bool
    private var lang: LanguageManager { LanguageManager.shared }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showCircle = false
    @State private var showText = false
    @State private var showDismiss = false
    @State private var ringScale: CGFloat = 0.3
    @State private var textOffset: CGFloat = 40
    @State private var overlayOpacity: Double = 0

    var body: some View {
        if isPresented {
            ZStack {
                // 背景
                Color.black.opacity(overlayOpacity * 0.6)
                    .ignoresSafeArea()
                    .onTapGesture { dismissOverlay() }

                VStack(spacing: 24) {
                    Spacer()

                    // リングアニメーション
                    ZStack {
                        // 外側の輝くリング
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [.purple, .blue, .cyan, .green, .yellow, .orange, .red, .purple],
                                    center: .center
                                ),
                                lineWidth: 6
                            )
                            .frame(width: 180, height: 180)
                            .scaleEffect(ringScale)
                            .opacity(showCircle ? 1 : 0)

                        // 背景の塗り
                        Circle()
                            .fill(AppColor.levelPurple.opacity(0.15))
                            .frame(width: 160, height: 160)
                            .scaleEffect(ringScale)

                        VStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(AppColor.levelPurple)
                                .accessibilityHidden(true)

                            Text(lang.l("level_up.title"))
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(AppColor.levelPurple)
                        }
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : textOffset)
                    }

                    // レベル表示
                    Text(lang.l("level_up.level", level))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.levelPurple, .purple.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(showText ? 1 : 0)
                        .scaleEffect(showText ? 1.0 : 0.5)
                        .shimmer(duration: 2.0, isActive: showText)

                    // タイトル
                    Text(levelTitle)
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textSecondary)
                        .opacity(showText ? 1 : 0)

                    Spacer()

                    // 閉じるボタン
                    if showDismiss {
                        Button {
                            dismissOverlay()
                        } label: {
                            Text(lang.l("level_up.tap_continue"))
                                .font(AppFont.callout)
                                .foregroundStyle(AppColor.textSecondary)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 32)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .transition(.opacity)
                    }

                    Spacer(minLength: 60)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(lang.l("level_up.accessibility_label", level, levelTitle))
            .accessibilityAddTraits(.isModal)
            .transition(.opacity)
            .onAppear { startAnimation() }
        }
    }

    private var levelTitle: String {
        var titleKey = "home.default_title"
        for (lv, key) in GamificationService.levelTitles.sorted(by: { $0.key < $1.key }) {
            if level >= lv { titleKey = key }
        }
        return lang.l(titleKey)
    }

    private func startAnimation() {
        if reduceMotion {
            overlayOpacity = 1
            showCircle = true
            showText = true
            ringScale = 1.0
            showDismiss = true
            return
        }

        withAnimation(.easeIn(duration: 0.3)) {
            overlayOpacity = 1
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
            showCircle = true
            ringScale = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
            showText = true
            textOffset = 0
        }
        withAnimation(.easeIn(duration: 0.3).delay(1.2)) {
            showDismiss = true
        }
    }

    private func dismissOverlay() {
        if reduceMotion {
            isPresented = false
            return
        }
        withAnimation(.easeOut(duration: 0.25)) {
            overlayOpacity = 0
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            isPresented = false
        }
    }
}
