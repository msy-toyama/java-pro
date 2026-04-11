//
//  CrashReportService.swift
//  Java Pro
//
//  MetricKit を使用した組み込みクラッシュ・パフォーマンス診断レポートサービス。
//  サードパーティ SDK 不要で、Apple の診断パイプラインを通じて
//  クラッシュログ・ハングレポート・ディスク書き込み超過などを受信する。
//
//  ■ 仕組み
//  - MXMetricManager のサブスクライバーとして登録
//  - iOS がバックグラウンドで収集した診断ペイロードを受信
//  - os.Logger で構造化ログに記録し、クラッシュ診断は UserDefaults に保存
//
//  ■ 使い方
//  アプリ起動時に `CrashReportService.shared.start()` を呼ぶだけ。
//

import Foundation
import MetricKit
import os

/// MetricKit ベースのクラッシュ・パフォーマンス診断サービス。
final class CrashReportService: NSObject, @unchecked Sendable {

    static let shared = CrashReportService()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.masaya.JavaPro",
        category: "CrashReport"
    )

    /// 最新のクラッシュ / ハング診断サマリ（設定画面などで表示可能）
    private(set) var lastDiagnosticSummary: String?

    private let diagnosticKey = "lastCrashDiagnostic"

    // MARK: - Lifecycle

    private override init() {
        super.init()
        lastDiagnosticSummary = UserDefaults.standard.string(forKey: diagnosticKey)
    }

    /// MetricKit レシーバーを登録する。App 起動時に1度だけ呼ぶ。
    func start() {
        MXMetricManager.shared.add(self)
        Self.logger.info("CrashReportService started — MetricKit subscriber registered")
    }

    /// アプリ終了時に呼ぶ（通常は不要だが念のため提供）。
    func stop() {
        MXMetricManager.shared.remove(self)
    }
}

// MARK: - MXMetricManagerSubscriber

extension CrashReportService: MXMetricManagerSubscriber {

    /// 日次メトリクスペイロードの受信（起動時間、メモリ、バッテリーなど）
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            Self.logger.info("MetricKit payload received — timeStampEnd: \(payload.timeStampEnd)")

            // メモリ使用量
            if let memoryMetrics = payload.memoryMetrics {
                let peakMB = memoryMetrics.peakMemoryUsage.converted(to: .megabytes).value
                Self.logger.info("Peak memory usage: \(peakMB, format: .fixed(precision: 1)) MB")
            }
        }
    }

    /// 診断ペイロード（クラッシュ・ハングなど）の受信
    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            Self.logger.warning("Diagnostic payload received — timeStampEnd: \(payload.timeStampEnd)")

            var summaryParts: [String] = []

            // クラッシュ診断
            if let crashes = payload.crashDiagnostics, !crashes.isEmpty {
                Self.logger.error("Crash diagnostics: \(crashes.count) report(s)")
                for crash in crashes {
                    let signal = crash.signal
                    let code = crash.exceptionCode?.description ?? "unknown"
                    let type = crash.exceptionType?.description ?? "unknown"
                    Self.logger.error(
                        "Crash — signal: \(signal), code: \(code), type: \(type), terminationReason: \(crash.terminationReason ?? "N/A")"
                    )
                }
                summaryParts.append("クラッシュ: \(crashes.count)件")
            }

            // ハング診断
            if let hangs = payload.hangDiagnostics, !hangs.isEmpty {
                Self.logger.warning("Hang diagnostics: \(hangs.count) report(s)")
                for hang in hangs {
                    let duration = hang.hangDuration.converted(to: .seconds).value
                    Self.logger.warning("Hang duration: \(duration, format: .fixed(precision: 1))s")
                }
                summaryParts.append("ハング: \(hangs.count)件")
            }

            // ディスク書き込み超過
            if let diskWrites = payload.diskWriteExceptionDiagnostics, !diskWrites.isEmpty {
                Self.logger.warning("Disk write exception diagnostics: \(diskWrites.count) report(s)")
                summaryParts.append("ディスク書込超過: \(diskWrites.count)件")
            }

            // CPU 超過
            if let cpuExceptions = payload.cpuExceptionDiagnostics, !cpuExceptions.isEmpty {
                Self.logger.warning("CPU exception diagnostics: \(cpuExceptions.count) report(s)")
                summaryParts.append("CPU超過: \(cpuExceptions.count)件")
            }

            // サマリーを保存
            if !summaryParts.isEmpty {
                let dateStr = payload.timeStampEnd.formatted(.dateTime.month().day().hour().minute())
                let summary = "[\(dateStr)] \(summaryParts.joined(separator: ", "))"
                lastDiagnosticSummary = summary
                UserDefaults.standard.set(summary, forKey: diagnosticKey)
                Self.logger.info("Diagnostic summary saved: \(summary)")
            }
        }
    }
}
