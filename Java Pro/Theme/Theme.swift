//
//  Theme.swift
//  Java Pro
//
//  アプリ全体のデザイントークン定義。
//  色・フォント・間隔・角丸などを一元管理し、
//  画面間で統一感を保ちつつ保守性を高める。
//  ダークモード完全対応。
//

import SwiftUI

// MARK: - カラーパレット

/// アプリのブランドカラーとセマンティックカラー。ダークモード対応。
enum AppColor {
    // ブランドカラー（ダークモードでも同系統を維持）
    static let primary      = Color(hex: "3B82F6")  // Javaブルー
    static let primaryDark  = Color(hex: "1D4ED8")
    static let primaryLight = Color(hex: "93C5FD")
    static let accent       = Color(hex: "F59E0B")  // モチベーションオレンジ
    static let accentLight  = Color(hex: "FCD34D")

    // セマンティックカラー
    static let success      = Color(hex: "10B981")
    static let error        = Color(hex: "EF4444")
    static let warning      = Color(hex: "F59E0B")
    static let info         = Color(hex: "3B82F6")

    // 背景（ライト/ダーク適応）
    static let background     = Color("Background", bundle: nil)
    static let cardBackground = Color("CardBackground", bundle: nil)
    static let codeBackground = Color(hex: "1E293B")
    static let codeText       = Color(hex: "E2E8F0")

    // テキスト（ライト/ダーク適応）
    static let textPrimary   = Color("TextPrimary", bundle: nil)
    static let textSecondary = Color("TextSecondary", bundle: nil)
    static let textTertiary  = Color("TextTertiary", bundle: nil)

    // XP / ゲーミフィケーション
    static let xpGold        = Color(hex: "FFD700")
    static let levelPurple   = Color(hex: "8B5CF6")
    static let badgeBronze   = Color(hex: "CD7F32")
    static let badgeSilver   = Color(hex: "C0C0C0")
    static let badgeGold     = Color(hex: "FFD700")

    // 実践演習
    static let practiceIndigo = Color(hex: "6366F1")
    static let practiceViolet = Color(hex: "8B5CF6")

    // クイズタイプ別カラー
    static let quizCyan       = Color(hex: "06B6D4")  // コード補完
    static let quizMagenta    = Color(hex: "D946EF")  // 試験形式

    // 実行結果演出
    static let terminalGreen  = Color(hex: "22C55E")
    static let terminalYellow = Color(hex: "EAB308")
    static let terminalRed    = Color(hex: "EF4444")

    // 章別カラー（コース一覧のアクセントに使用）
    static let chapterColors: [Color] = [
        Color(hex: "3B82F6"), // 入門 - ブルー
        Color(hex: "8B5CF6"), // 出力変数 - パープル
        Color(hex: "EC4899"), // 演算子 - ピンク
        Color(hex: "F59E0B"), // 条件分岐 - アンバー
        Color(hex: "10B981"), // 繰り返し - エメラルド
        Color(hex: "06B6D4"), // 配列 - シアン
        Color(hex: "6366F1"), // メソッド - インディゴ
        Color(hex: "D946EF"), // 文字列 - フクシア
        Color(hex: "EF4444"), // クラス - レッド
        Color(hex: "14B8A6"), // カプセル化 - ティール
        Color(hex: "F97316"), // 継承 - オレンジ
        Color(hex: "0EA5E9"), // ポリモーフィズム - スカイ
        Color(hex: "A855F7"), // 抽象化 - バイオレット
        Color(hex: "DC2626"), // 例外 - クリムゾン
        Color(hex: "65A30D"), // API - ライム
    ]

    /// 章の順序からカラーを取得する。
    static func chapterColor(order: Int) -> Color {
        let index = max(0, order - 1)
        return chapterColors[index % chapterColors.count]
    }
}

// MARK: - フォントスタイル

/// アプリ全体で使う書式スタイル。
enum AppFont {
    static let largeTitle  = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title       = Font.system(.title2, design: .rounded, weight: .bold)
    static let title3      = Font.system(.title3, design: .rounded, weight: .semibold)
    static let headline    = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body        = Font.system(.body, design: .default)
    static let callout     = Font.system(.callout, design: .default)
    static let caption     = Font.system(.caption, design: .default, weight: .medium)
    static let code        = Font.system(.callout, design: .monospaced)
    static let codeSmall   = Font.system(.caption, design: .monospaced)
}

// MARK: - レイアウト定数

/// 間隔・角丸・シャドウなどのレイアウトトークン。
enum AppLayout {
    static let paddingXS: CGFloat  = 4
    static let paddingSM: CGFloat  = 8
    static let paddingMD: CGFloat  = 16
    static let paddingLG: CGFloat  = 24
    static let paddingXL: CGFloat  = 32

    static let cornerRadius: CGFloat      = 12
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 20

    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat      = 2

    static let iconSizeSM: CGFloat = 20
    static let iconSizeMD: CGFloat = 28
    static let iconSizeLG: CGFloat = 44
}

// MARK: - アニメーション

/// 共通アニメーション定義。
enum AppAnimation {
    static let quick    = Animation.easeOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let spring   = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let bounce   = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let typewriter = Animation.easeInOut(duration: 0.03) // タイプライター1文字ずつ
}

// MARK: - カードスタイル修飾子

/// 統一されたカードスタイルを適用する ViewModifier。ダークモード対応。
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var padding: CGFloat = AppLayout.paddingMD

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.06),
                radius: AppLayout.cardShadowRadius,
                y: AppLayout.cardShadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : .clear, lineWidth: 1)
            )
    }
}

extension View {
    /// 統一カードスタイルを適用する。
    func cardStyle(padding: CGFloat = AppLayout.paddingMD) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

// MARK: - グラスモーフィズム修飾子

/// 半透明ガラス風背景。アクセント演出に使う。
struct GlassStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3), lineWidth: 0.5)
            )
    }
}

extension View {
    func glassStyle() -> some View {
        modifier(GlassStyle())
    }
}

// MARK: - Color 16進数対応

extension Color {
    /// 16進数文字列からColorを生成する。"#" 付きでも付きなしでも可。
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 特徴チップ（オンボーディング等で使用）

struct FeatureChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(AppFont.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, AppLayout.paddingSM)
        .padding(.vertical, AppLayout.paddingXS)
        .background(color.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - プレス感のあるボタンスタイル

/// タップ時にスケールダウン＋スプリング復帰するボタンスタイル。
/// 高品質アプリに欠かせないマイクロインタラクション。
struct PressableButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
    static func pressable(scale: CGFloat = 0.96) -> PressableButtonStyle {
        PressableButtonStyle(scaleAmount: scale)
    }
}

// MARK: - ブランドタイトル は ThemeComponents.swift に移動
