//
//  SaveErrorNotifier.swift
//  Java Pro
//
//  SwiftData の保存エラーをView層に通知するための共有サービス。
//  ProgressService, GamificationService 等が saveContext() 失敗時に呼び出し、
//  RootView がアラートとして表示する。
//

import Foundation

/// データ保存エラーをUIに通知するシングルトン。
@MainActor
@Observable
final class SaveErrorNotifier {
    static let shared = SaveErrorNotifier()

    /// 最新のエラーメッセージ。nil でなければアラートを表示する。
    var lastError: String?

    private init() {}

    /// 保存エラーを報告する。
    func report(_ error: Error) {
        let msg = LanguageManager.shared.l("save_error.message")
        lastError = "\(msg)\n\(error.localizedDescription)"
    }

    /// エラーをクリアする。
    func clear() {
        lastError = nil
    }
}
