//
//  AppLogger.swift
//  Java Pro
//
//  os.Logger を使った構造化ログユーティリティ。
//  カテゴリごとに Logger インスタンスを提供し、
//  print() の代わりに統一的なログ出力を行う。
//

import Foundation
import os

/// アプリ全体で使用する構造化ログを提供する名前空間。
///
/// 使用例:
/// ```
/// AppLogger.swiftData.warning("fetch failed: \(error.localizedDescription)")
/// AppLogger.store.error("商品取得エラー: \(error)")
/// ```
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.masaya.JavaPro"

    /// SwiftData 関連（fetch / save / migration）
    static let swiftData  = Logger(subsystem: subsystem, category: "SwiftData")

    /// StoreKit 関連（商品取得 / 購入 / 復元）
    static let store      = Logger(subsystem: subsystem, category: "StoreKit")

    /// コンテンツ読込（JSON デコード / リソース検索）
    static let content    = Logger(subsystem: subsystem, category: "Content")

    /// 通知（権限要求 / スケジュール）
    static let notification = Logger(subsystem: subsystem, category: "Notification")

    /// ゲーミフィケーション（XP / バッジ / ストリーク）
    static let gamification = Logger(subsystem: subsystem, category: "Gamification")

    /// サウンド再生
    static let sound      = Logger(subsystem: subsystem, category: "Sound")

    /// ViewModel 層
    static let viewModel  = Logger(subsystem: subsystem, category: "ViewModel")

    /// アプリライフサイクル（起動 / コンテナ初期化）
    static let app        = Logger(subsystem: subsystem, category: "App")
}
