//
//  StoreService.swift
//  Java Pro
//
//  StoreKit 2 を使った課金管理サービス。
//  ¥480 の買い切りで全コンテンツを解放する。
//  無料範囲: Beginner (ch01-ch09) + SE11 Silver 模擬試験1
//

import Foundation
import StoreKit
import SwiftUI
import os

/// アプリ内課金の商品ID。
enum StoreProductID: String, CaseIterable {
    case fullAccess = "com.javapro.fullaccess"
}

/// 課金状態を管理するサービス（StoreKit 2）。
@MainActor
@Observable
final class StoreService {
    static let shared = StoreService()

    // MARK: - Published State

    /// ロード済みの商品
    var products: [Product] = []
    /// フルアクセスを購入済みか
    var fullAccessUnlocked: Bool = false
    /// 処理中フラグ
    var isPurchasing: Bool = false
    /// エラーメッセージ
    var errorMessage: String?

    private var transactionListener: Task<Void, Never>?

    // MARK: - Debug Override

    /// デバッグビルドでは全機能を解放する。
    /// リリース時は false にする。
    #if DEBUG
    var debugUnlockAll: Bool = true
    #else
    var debugUnlockAll: Bool = false
    #endif

    // MARK: - 後方互換プロパティ

    /// プレミアム判定（後方互換性のために維持）
    var isPremium: Bool { fullAccessUnlocked || debugUnlockAll }
    /// 広告非表示判定（フルアクセスに含まれる）
    var adRemoved: Bool { fullAccessUnlocked || debugUnlockAll }
    /// Silver解放判定（フルアクセスに含まれる）
    var silverUnlocked: Bool { fullAccessUnlocked || debugUnlockAll }
    /// Gold解放判定（フルアクセスに含まれる）
    var goldUnlocked: Bool { fullAccessUnlocked || debugUnlockAll }

    // MARK: - Init

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await refreshPurchaseStatus() }
    }

    // MARK: - 商品ロード

    func loadProducts() async {
        do {
            let ids = StoreProductID.allCases.map(\.rawValue)
            products = try await Product.products(for: Set(ids))
                .sorted { $0.price < $1.price }
        } catch {
            AppLogger.store.error("商品取得エラー: \(error)")
            errorMessage = "商品情報の取得に失敗しました。通信状況をご確認ください。"
        }
    }

    /// 指定IDの商品を返す。
    func product(for id: StoreProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    // MARK: - 購入

    func purchase(_ productId: StoreProductID) async -> Bool {
        guard let product = product(for: productId) else {
            errorMessage = "商品が見つかりません"
            return false
        }
        return await purchase(product)
    }

    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchase(transaction)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                errorMessage = "購入の承認を待っています"
                return false
            @unknown default:
                errorMessage = "予期しない購入結果が返されました。しばらく待ってから再試行してください"
                return false
            }
        } catch {
            errorMessage = "購入エラー: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - 復元

    func restorePurchases() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshPurchaseStatus()
        } catch {
            errorMessage = "復元エラー: \(error.localizedDescription)"
        }
    }

    // MARK: - コンテンツアクセス判定

    /// 指定コースがアクセス可能か判定する。
    func canAccess(courseId: String, certLevel: CertificationLevel?) -> Bool {
        if fullAccessUnlocked || debugUnlockAll { return true }

        switch certLevel {
        case .beginner, .none:
            // 入門(ch01-ch08): 無料
            return true
        case .silver, .gold:
            // Silver/Gold範囲: フルアクセス購入が必要
            return false
        }
    }

    /// 指定模擬試験がアクセス可能か判定する。
    func canAccessExam(examId: String) -> Bool {
        if fullAccessUnlocked || debugUnlockAll { return true }

        switch examId {
        case "se11_silver_1":
            // SE11 Silver 模擬試験1: 無料
            return true
        default:
            // その他すべて: フルアクセス購入が必要
            return false
        }
    }

    /// いずれかの購入済みか。
    var hasAnyPurchase: Bool {
        fullAccessUnlocked
    }

    // MARK: - Private

    /// 購入状況を全トランザクションから更新する。
    func refreshPurchaseStatus() async {
        var newFullAccess = false

        for await verification in StoreKit.Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(verification) else { continue }
            if transaction.productID == StoreProductID.fullAccess.rawValue {
                newFullAccess = true
            }
        }

        fullAccessUnlocked = newFullAccess
    }

    /// トランザクション更新を監視する。
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await verification in StoreKit.Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = verification {
                    await self.updatePurchase(transaction)
                    await transaction.finish()
                }
            }
        }
    }

    private func updatePurchase(_ transaction: StoreKit.Transaction) async {
        await refreshPurchaseStatus()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
