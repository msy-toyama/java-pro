//
//  LanguageManager.swift
//  Java Pro
//
//  アプリ内言語切替を管理するサービス。
//  ユーザーの言語選択を永続化し、UIテキストのローカライズを一元的に提供する。
//  JSON ベースの文字列辞書を使用し、Swift 6 の MainActor 分離に準拠する。
//

import Foundation
import os

// MARK: - 言語列挙型

/// アプリがサポートする言語。
enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case japanese = "ja"
    case english = "en"

    /// 言語の自国語表記。
    var displayName: String {
        switch self {
        case .japanese: "日本語"
        case .english: "English"
        }
    }

    /// 言語選択UIで使用する副題。
    var subtitle: String {
        switch self {
        case .japanese: "Japanese"
        case .english: "英語"
        }
    }

    /// BCP 47 言語コード。
    var bcp47Code: String { rawValue }
}

// MARK: - 言語マネージャ

/// アプリ全体のUI文字列ローカライズを管理するシングルトン。
/// `@Observable` で SwiftUI のビュー再描画を自動的にトリガーする。
///
/// 使用方法:
/// ```swift
/// // View 内で（@Observable の自動トラッキング）
/// private var lang = LanguageManager.shared
/// Text(lang.l("tab.home"))
///
/// // フォーマット文字列
/// Text(lang.l("settings.daily_goal", 15))
/// ```
@MainActor
@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    /// 現在選択されている言語。変更時に文字列辞書を再ロードする。
    private(set) var currentLanguage: AppLanguage

    /// ローカライズ文字列辞書（key → value）。
    private var strings: [String: String] = [:]

    /// 日本語かどうか。
    var isJapanese: Bool { currentLanguage == .japanese }

    // MARK: - 初期化

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage")
        currentLanguage = AppLanguage(rawValue: saved ?? "ja") ?? .japanese
        loadStrings()
    }

    // MARK: - 言語切替

    /// 言語変更時に投稿される通知名。通知のリスケジュールなどに使用する。
    static let languageDidChangeNotification = Notification.Name("languageDidChange")

    /// 言語を切り替える。文字列辞書をリロードし、UI更新をトリガーする。
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        loadStrings()

        // コンテンツデータも言語に応じて再ロード
        Task {
            await ContentService.shared.reloadForLanguageChange()
            PracticeService.shared.reloadForLanguageChange()
        }

        // 通知文面を新しい言語で再スケジュールさせるために通知を投稿
        NotificationCenter.default.post(name: Self.languageDidChangeNotification, object: nil)
    }

    // MARK: - ローカライズアクセサ

    /// キーに対応するローカライズ文字列を返す。
    /// キーが見つからない場合はキー自体を返す（開発時に未翻訳を検知しやすくするため）。
    func l(_ key: String) -> String {
        strings[key] ?? key
    }

    /// フォーマットパラメータ付きローカライズ文字列を返す。
    /// - Example: `lang.l("settings.daily_goal", 15)` → "1日の目標: 15分"
    func l(_ key: String, _ args: CVarArg...) -> String {
        let format = strings[key] ?? key
        return String(format: format, arguments: args)
    }

    // MARK: - 通知用文字列取得（Sendable コンテキスト向け）

    /// 通知サービス等の非 MainActor コンテキスト用にローカライズ済み文字列配列を返す。
    /// 呼び出し側（MainActor）で取得してから Sendable コンテキストに渡す。
    func notificationStrings() -> (title: String, bodies: [String]) {
        let title = l("notification.title")
        let bodies = (1...6).map { l("notification.body.\($0)") }
        return (title, bodies)
    }

    // MARK: - 内部

    /// Resources/ フォルダから言語対応の文字列JSONを読み込む。
    private func loadStrings() {
        let fileName = "strings_\(currentLanguage.rawValue)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            AppLogger.app.error("文字列ファイル \(fileName).json が見つかりません")
            strings = [:]
            return
        }
        do {
            let data = try Data(contentsOf: url)
            strings = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            AppLogger.app.error("文字列ファイルのパースに失敗: \(error)")
            strings = [:]
        }
    }
}
