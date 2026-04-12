//
//  DateExtensions.swift
//  Java Pro
//
//  日付関連のヘルパー。連続日数・復習間隔の計算に使用する。
//

import Foundation

extension Date {
    // MARK: - 日付文字列

    /// "yyyy-MM-dd" 形式の文字列を返す（ローカルタイムゾーン基準）。
    var dateString: String {
        Self.dateStringFormatter.string(from: self)
    }

    private static let dateStringFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()

    /// "yyyy-MM-dd" 文字列から Date に変換するイニシャライザ。
    init?(dateString: String) {
        guard let date = Self.dateStringFormatter.date(from: dateString) else {
            return nil
        }
        self = date
    }

    // MARK: - 日付比較

    /// 今日かどうか（ローカルタイムゾーン基準）。
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// 昨日かどうか。
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// 指定日数前の日付を返す。
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }

    /// 指定日数後の日付を返す。
    func daysLater(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// 2つの日付間の暦日数差。
    func daysDifference(from other: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: other)
        let end = calendar.startOfDay(for: self)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    // MARK: - 表示用

    /// 「今日」「昨日」「4/5」等の短い表示文字列。
    var shortDisplayString: String {
        if isToday { return LanguageManager.shared.l("date.today") }
        if isYesterday { return LanguageManager.shared.l("date.yesterday") }
        return Self.shortDisplayFormatter.string(from: self)
    }

    private static var shortDisplayFormatter: DateFormatter {
        let f = DateFormatter()
        let lang = LanguageManager.shared
        f.locale = Locale(identifier: lang.isJapanese ? "ja_JP" : "en_US")
        f.dateFormat = lang.isJapanese ? "M/d" : "MMM d"
        return f
    }
}
