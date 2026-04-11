//
//  PracticeModels.swift
//  Java Pro
//
//  実践演習のデータモデル。
//  環境構築ガイドとコーディング演習を定義する。
//

import Foundation

// MARK: - 環境構築ガイド

/// 環境構築ガイドのセクション
struct SetupGuideSection: Codable, Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let iconName: String
    let steps: [SetupStep]

    static func == (lhs: SetupGuideSection, rhs: SetupGuideSection) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// 環境構築の個別ステップ
struct SetupStep: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
    let code: String?
    let tip: String?
}

// MARK: - 実践演習

/// 実践演習のインデックス（チャプター単位）
struct PracticeChapter: Codable, Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let certificationLevel: CertificationLevel
    /// 教材学習と同じカテゴリキー（例: "basics", "oop"）
    let category: String
    let exercises: [PracticeExercise]

    // NavigationLink(value:) 用: id ベースの等値比較
    static func == (lhs: PracticeChapter, rhs: PracticeChapter) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// 個別の演習問題
struct PracticeExercise: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let difficulty: Int
    let relatedLessonId: String
    let description: String
    let expectedOutput: String
    let hint: String?
    let solutionCode: String
    let solutionFileName: String
    /// 解答コードの詳細解説（API・メソッド・構文の説明）
    let solutionExplanation: String?
}

// MARK: - トップレベルJSON構造

/// practice_exercises.json のルート
struct PracticeData: Codable, Sendable {
    let setupGuide: [SetupGuideSection]
    let chapters: [PracticeChapter]
}
