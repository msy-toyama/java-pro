//
//  JavaProSchemaVersions.swift
//  Java Pro
//
//  SwiftData のバージョン付きスキーマとマイグレーション計画。
//  モデル変更時もユーザーデータを安全に保持する。
//
//  【将来のモデル変更手順】
//  1. 新しい VersionedSchema（例: JavaProSchemaV2）を追加し、
//     変更後のモデルクラスを models に列挙する。
//  2. JavaProMigrationPlan.schemas に V2 を追加する。
//  3. JavaProMigrationPlan.stages に V1→V2 のマイグレーションステージを追加する。
//     - プロパティ追加/削除のみなら .lightweight で十分。
//     - データ変換が必要なら .custom を使用。
//  4. Java_ProApp.swift の Schema 生成を最新バージョンに変更する。
//

import Foundation
import SwiftData

// MARK: - Schema V1（初回リリース版）

/// v1.0.0: 初回リリースのスキーマ定義。
enum JavaProSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        UserLessonProgress.self,
        UserQuizHistory.self,
        UserDailyRecord.self,
        AppSettings.self,
        UserXPRecord.self,
        UserBadge.self,
        UserLevel.self,
        UserExamResult.self,
    ]
}

// MARK: - Schema V2（学習時間追跡・音量設定）

/// v1.1.0: UserDailyRecord に studySeconds、AppSettings に soundVolume を追加。
enum JavaProSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)

    static var models: [any PersistentModel.Type] = [
        UserLessonProgress.self,
        UserQuizHistory.self,
        UserDailyRecord.self,
        AppSettings.self,
        UserXPRecord.self,
        UserBadge.self,
        UserLevel.self,
        UserExamResult.self,
    ]
}

// MARK: - マイグレーション計画

/// スキーマ変更時のデータマイグレーション戦略。
enum JavaProMigrationPlan: SchemaMigrationPlan {
    /// 全バージョンを古い順に列挙する。
    static var schemas: [any VersionedSchema.Type] = [
        JavaProSchemaV1.self,
        JavaProSchemaV2.self,
    ]

    /// バージョン間のマイグレーションステージ。
    static var stages: [MigrationStage] = [
        // V1→V2: 新規プロパティにデフォルト値があるため lightweight で十分
        .lightweight(fromVersion: JavaProSchemaV1.self, toVersion: JavaProSchemaV2.self),
    ]
}
