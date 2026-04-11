//
//  AppearanceManager.swift
//  Java Pro
//
//  ダークモード設定の即時反映を実現する共有マネージャー。
//  SettingsView で変更された外観設定を RootView に即座に伝播する。
//

import SwiftUI

/// アプリ全体の外観設定を管理するシングルトン。`@Observable` でUI即時反映。
@MainActor
@Observable
final class AppearanceManager {
    static let shared = AppearanceManager()

    /// nil = システム追従, .dark = ダーク, .light = ライト
    var colorSchemeOverride: ColorScheme?

    private init() {}

    /// AppSettings の isDarkMode から外観を同期する。
    func sync(from isDarkMode: Bool?) {
        if let isDark = isDarkMode {
            colorSchemeOverride = isDark ? .dark : .light
        } else {
            colorSchemeOverride = nil
        }
    }

    /// isDarkMode を更新し、即座に反映する。
    func setDarkMode(_ isDarkMode: Bool?) {
        sync(from: isDarkMode)
    }
}
