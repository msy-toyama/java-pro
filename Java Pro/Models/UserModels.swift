//
//  UserModels.swift
//  Java Pro
//
//  SwiftData で端末ローカルに永続化するユーザー状態モデル。
//  教材マスタ (JSON) とは分離し、ユーザー固有データのみを保持する。
//

import Foundation
import SwiftData

// MARK: - レッスン進捗

/// ユーザーの各レッスンへの取り組み状態。
@Model
final class UserLessonProgress {
    @Attribute(.unique)
    var lessonId: String
    var statusRaw: String
    var startedAt: Date?
    var completedAt: Date?

    /// 便利アクセサ。SwiftData は Codable enum を直接扱えるが、
    /// マイグレーション耐性のため Raw 値で保存する。
    var status: LessonStatus {
        get { LessonStatus(rawValue: statusRaw) ?? .notStarted }
        set { statusRaw = newValue.rawValue }
    }

    init(lessonId: String, status: LessonStatus = .notStarted) {
        self.lessonId = lessonId
        self.statusRaw = status.rawValue
    }
}

/// レッスンの取り組み状態。
enum LessonStatus: String, Codable, Sendable {
    case notStarted
    case inProgress
    case completed
}

// MARK: - クイズ回答履歴

/// クイズ1問への回答記録。復習スケジュールの算出に使う。
@Model
final class UserQuizHistory {
    /// 回答ごとの一意ID。
    @Attribute(.unique)
    var id: String
    /// 対象クイズID。
    var quizId: String
    /// 回答日時。
    var answeredAt: Date
    /// 正解したか。
    var isCorrect: Bool
    /// 連続正解数。誤答でリセット。
    var streakCount: Int
    /// 復習間隔ステージ（0=即時, 1=24h, 2=3日, 3=7日, 4=完了）。
    var intervalStage: Int

    init(quizId: String, isCorrect: Bool, streakCount: Int = 0, intervalStage: Int = 0) {
        self.id = UUID().uuidString
        self.quizId = quizId
        self.answeredAt = Date()
        self.isCorrect = isCorrect
        self.streakCount = streakCount
        self.intervalStage = intervalStage
    }
}

// MARK: - 日次学習記録（連続日数の算出用）

/// 1日あたりの学習実績を記録する。
@Model
final class UserDailyRecord {
    /// "yyyy-MM-dd" 形式の日付文字列。
    @Attribute(.unique)
    var dateString: String
    /// その日に完了したレッスン数。
    var completedLessons: Int
    /// その日に回答したクイズ数。
    var completedQuizzes: Int
    /// その日に獲得したXP。
    var earnedXP: Int
    /// その日の実際の学習時間（秒）。アプリがフォアグラウンドにあった秒数を積算する。
    var studySeconds: Int

    init(dateString: String) {
        self.dateString = dateString
        self.completedLessons = 0
        self.completedQuizzes = 0
        self.earnedXP = 0
        self.studySeconds = 0
    }
}

// MARK: - アプリ設定

/// アプリ全体の設定。端末に1レコードだけ保持する（シングルトンパターン）。
@Model
final class AppSettings {
    /// シングルトン保証用の固定ID。常に "app_settings" を使用する。
    @Attribute(.unique)
    var id: String
    var notificationsEnabled: Bool
    var adRemoved: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var hasCompletedOnboarding: Bool
    /// ダークモード設定（true=ダーク, false=ライト, nil=システム追従）
    var isDarkMode: Bool?
    /// 目標とする資格レベル
    var selectedCertificationRaw: String
    /// 1日の学習目標（分）
    var dailyGoalMinutes: Int
    /// 触覚フィードバック有効
    var hapticFeedbackEnabled: Bool
    /// サウンド有効
    var soundEnabled: Bool
    /// 効果音ボリューム（0.0〜1.0）
    var soundVolume: Double

    /// 選択中の資格レベル。
    var selectedCertification: CertificationLevel {
        get { CertificationLevel(rawValue: selectedCertificationRaw) ?? .beginner }
        set { selectedCertificationRaw = newValue.rawValue }
    }

    /// 固定IDでシングルトンとして初期化する。
    /// 同じIDで再挿入しても @Attribute(.unique) により既存レコードが更新される。
    init() {
        self.id = "app_settings"
        self.notificationsEnabled = true
        self.adRemoved = false
        self.reminderHour = 8
        self.reminderMinute = 0
        self.hasCompletedOnboarding = false
        self.isDarkMode = nil
        self.selectedCertificationRaw = CertificationLevel.beginner.rawValue
        self.dailyGoalMinutes = 15
        self.hapticFeedbackEnabled = true
        self.soundEnabled = true
        self.soundVolume = 0.7
    }
}

// MARK: - XP記録

/// XP獲得イベント1件の記録。
@Model
final class UserXPRecord {
    @Attribute(.unique)
    var id: String
    /// 獲得XP量。
    var amount: Int
    /// 獲得理由（例: "lesson_complete", "quiz_correct", "streak_bonus"）。
    var reason: String
    /// 獲得日時。
    var earnedAt: Date
    /// 関連エンティティID（レッスンID / クイズID 等）。
    var relatedId: String?

    init(amount: Int, reason: String, relatedId: String? = nil) {
        self.id = UUID().uuidString
        self.amount = amount
        self.reason = reason
        self.earnedAt = Date()
        self.relatedId = relatedId
    }
}

// MARK: - バッジ

/// ユーザーが獲得したバッジの記録。
@Model
final class UserBadge {
    @Attribute(.unique)
    var badgeId: String
    /// バッジ名（表示用）。
    var name: String
    /// バッジの説明。
    var badgeDescription: String
    /// SF Symbols アイコン名。
    var iconName: String
    /// カラーHex。
    var colorHex: String
    /// 獲得日時。
    var earnedAt: Date

    init(badgeId: String, name: String, description: String, iconName: String, colorHex: String) {
        self.badgeId = badgeId
        self.name = name
        self.badgeDescription = description
        self.iconName = iconName
        self.colorHex = colorHex
        self.earnedAt = Date()
    }
}

// MARK: - ユーザーレベル

/// ユーザーの現在のレベルとXP。
@Model
final class UserLevel {
    @Attribute(.unique)
    var id: String
    /// 現在のレベル（1〜50）。
    var level: Int
    /// 累計XP。
    var totalXP: Int
    /// レベルアップ日時。
    var lastLevelUpAt: Date?

    init() {
        self.id = "user_level"
        self.level = 1
        self.totalXP = 0
    }
}

// MARK: - 模擬試験結果

/// 模擬試験の結果記録。
@Model
final class UserExamResult {
    @Attribute(.unique)
    var id: String
    /// 模擬試験のチャプターID（例: "ch19"）。
    var examChapterId: String
    /// スコア（正解数）。
    var score: Int
    /// 総問題数。
    var totalQuestions: Int
    /// 所要時間（秒）。
    var timeSpentSeconds: Int
    /// 合格したか（合格率は ExamService.defaultPassingRate で定義）。
    var passed: Bool
    /// 受験日時。
    var completedAt: Date
    /// 分野別正解率 JSON（例: {"データ型": 0.8, "制御文": 0.6}）。
    var topicScoresJSON: String?

    init(examChapterId: String, score: Int, totalQuestions: Int, timeSpentSeconds: Int, passingRate: Double = ExamService.defaultPassingRate) {
        self.id = UUID().uuidString
        self.examChapterId = examChapterId
        self.score = score
        self.totalQuestions = totalQuestions
        self.timeSpentSeconds = timeSpentSeconds
        self.passed = Double(score) / Double(max(totalQuestions, 1)) >= passingRate
        self.completedAt = Date()
    }
}

// MARK: - 統計DTO

struct TodayStats: Sendable {
    let completedLessons: Int
    let completedQuizzes: Int
    let streak: Int
    let earnedXP: Int
    /// 実際の学習時間（分）。
    let studyMinutes: Int
}
