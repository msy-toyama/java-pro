//
//  NotificationService.swift
//  Java Pro
//
//  ローカル通知によるリマインドを管理するサービス。
//  1日1回、設定時刻にプッシュ通知を送り学習継続を促す。
//

import Foundation
import UserNotifications
import os

/// ローカル通知の権限取得・スケジュールを一元管理するサービス。
final class NotificationService: Sendable {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "daily_reminder"

    private init() {}

    // MARK: - 権限

    /// 通知権限を要求し、結果を返す。
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            AppLogger.notification.error("通知権限の要求に失敗: \(error.localizedDescription)")
            return false
        }
    }

    /// 現在の通知権限ステータスを返す。
    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - リマインド

    /// 毎日指定時刻にリマインド通知をスケジュールする。
    /// 当日分（指定時刻がまだ先の場合）＋ 先7日分を個別登録し、
    /// 毎日異なるメッセージを表示する。
    /// アプリ起動時に再度呼び出すことで、常に先7日分が補充される。
    func scheduleDailyReminder(hour: Int, minute: Int) {
        // 既存のリマインドを取り消し
        cancelDailyReminder()

        let calendar = Calendar.current
        let now = Date()

        // dayOffset = 0（当日分）から 7（7日後）まで登録
        for dayOffset in 0...7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
            dateComponents.hour = hour
            dateComponents.minute = minute

            // 当日分は指定時刻がまだ過ぎていない場合のみ登録
            if dayOffset == 0 {
                guard let scheduledDate = calendar.date(from: dateComponents),
                      scheduledDate > now else {
                    continue
                }
            }

            let content = UNMutableNotificationContent()
            content.title = "今日もJavaを学ぼう 📚"
            content.body = randomReminderBody()
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "\(reminderIdentifier)_\(dayOffset)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error {
                    AppLogger.notification.error("通知スケジュールに失敗: \(error.localizedDescription)")
                }
            }
        }
    }

    /// リマインド通知を取り消す。
    func cancelDailyReminder() {
        let identifiers = (0...7).map { "\(reminderIdentifier)_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers + [reminderIdentifier])
    }

    // MARK: - Private

    /// リマインド本文をランダムに返す（飽き防止）。
    private func randomReminderBody() -> String {
        let messages = [
            "5分だけでOK！今日のレッスンが待っています。",
            "昨日の復習が溜まっています。サクッと確認しましょう。",
            "継続は力なり！今日もJavaを一歩進めませんか？",
            "スキマ時間にクイズ1問だけ解いてみましょう。",
            "毎日続けることが上達の近道です。",
            "今日はどの章を学びますか？"
        ]
        return messages.randomElement() ?? messages[0]
    }
}
