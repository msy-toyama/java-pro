//
//  Java_ProApp.swift
//  Java Pro
//
//  Created by 小林将也 on 2026/04/05.
//

import SwiftUI
import SwiftData
import os

@main
struct Java_ProApp: App {
    /// SwiftData コンテナ（ユーザー学習データ用）
    let modelContainer: ModelContainer

    init() {
        // テスト環境では空スキーマのインメモリコンテナを使用（テスト側コンテナとのスキーマ競合を回避）
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            modelContainer = try! ModelContainer(
                for: Schema([]),
                configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
            )
            return
        }

        // VersionedSchema を使用してスキーマバージョンを管理
        let schema = Schema(versionedSchema: JavaProSchemaV2.self)
        let config = ModelConfiguration(
            "JavaProStore",
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            // MigrationPlan を指定してコンテナを初期化
            // スキーマ変更時は JavaProMigrationPlan が自動的にデータを移行する
            modelContainer = try ModelContainer(
                for: schema,
                migrationPlan: JavaProMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            // マイグレーション失敗時のフォールバック
            AppLogger.app.error("SwiftData コンテナ初期化エラー: \(error)")
            #if DEBUG
            do {
                // 開発中のみ: ストアファイルを削除して再試行
                Self.deleteExistingStore(named: "JavaProStore")
                modelContainer = try ModelContainer(
                    for: schema,
                    migrationPlan: JavaProMigrationPlan.self,
                    configurations: [config]
                )
            } catch {
                // 最終フォールバック: インメモリで起動（データは揮発）
                AppLogger.app.error("SwiftData ストア再作成にも失敗。インメモリで起動: \(error)")
                let memoryConfig = ModelConfiguration(
                    "JavaProMemory",
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                do {
                    modelContainer = try ModelContainer(
                        for: schema,
                        migrationPlan: JavaProMigrationPlan.self,
                        configurations: [memoryConfig]
                    )
                } catch {
                    // DEBUGでもインメモリが失敗する場合は空スキーマで起動
                    AppLogger.app.fault("DEBUG: インメモリも失敗: \(error)")
                    // 空スキーマ + インメモリは OS レベル障害以外では失敗しない
                    modelContainer = try! ModelContainer(
                        for: Schema([]),
                        configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
                    )
                }
            }
            #else
            // 本番: ユーザーデータを削除せずインメモリで起動
            AppLogger.app.error("本番環境マイグレーションエラー。インメモリで起動: \(error)")
            UserDefaults.standard.set(true, forKey: "dataRecoveryMode")
            let memoryConfig = ModelConfiguration(
                "JavaProMemory",
                schema: schema,
                isStoredInMemoryOnly: true
            )
            do {
                modelContainer = try ModelContainer(
                    for: schema,
                    migrationPlan: JavaProMigrationPlan.self,
                    configurations: [memoryConfig]
                )
            } catch {
                // fatalError ではなく MigrationPlan なしで最低限の起動を試みる
                AppLogger.app.fault("インメモリ ModelContainer も失敗: \(error)")
                let bareConfig = ModelConfiguration(
                    isStoredInMemoryOnly: true
                )
                do {
                    modelContainer = try ModelContainer(
                        for: schema,
                        configurations: [bareConfig]
                    )
                } catch {
                    // 最終手段: 空のスキーマでコンテナ生成（データ操作は全て失敗するが起動はする）
                    AppLogger.app.fault("致命的エラー — 最小限モードで起動: \(error)")
                    // 空スキーマ + インメモリは OS レベル障害以外では失敗しない
                    modelContainer = try! ModelContainer(
                        for: Schema([]),
                        configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
                    )
                }
            }
            #endif
        }

        // MetricKit クラッシュ・パフォーマンス診断の受信を開始（テスト環境ではスキップ）
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            CrashReportService.shared.start()
        }

        // 教材コンテンツの先行読み込み（バックグラウンドでJSON解析、結果のみメインスレッドで反映）
        Task {
            await ContentService.shared.loadAllContentAsync()
        }
    }

    /// 指定名の SwiftData ストアファイルを削除する。
    /// ⚠️ この関数は開発中の初期化エラー回復用。App Store リリース後は使用しないこと。
    private static func deleteExistingStore(named name: String) {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        let extensions = ["store", "store-shm", "store-wal"]
        for ext in extensions {
            let url = appSupport.appendingPathComponent("\(name).\(ext)")
            try? FileManager.default.removeItem(at: url)
        }
        let sqliteExts = ["sqlite", "sqlite-shm", "sqlite-wal"]
        for ext in sqliteExts {
            let url = appSupport.appendingPathComponent("\(name).\(ext)")
            try? FileManager.default.removeItem(at: url)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
