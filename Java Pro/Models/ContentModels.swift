//
//  ContentModels.swift
//  Java Pro
//
//  JSON教材データを表現するイミュータブルな構造体群。
//  教材マスタデータはアプリバンドルのJSONから読み込み、実行時に変更しない。
//

import Foundation

// MARK: - 資格レベル

/// 学習対象の資格レベル。
enum CertificationLevel: String, Codable, Sendable, CaseIterable {
    case beginner = "beginner"   // 入門（資格なし）
    case silver   = "silver"     // Java Silver
    case gold     = "gold"       // Java Gold
}

// MARK: - クイズ難易度

/// クイズの難易度。
enum QuizDifficulty: String, Codable, Sendable {
    case easy   = "easy"
    case normal = "normal"
    case hard   = "hard"
}

// MARK: - コースインデックス（courses_index.json 用）

/// 章の一覧表示に使うメタデータ。レッスン本体は別JSONから遅延読み込みする。
struct CourseIndex: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let order: Int
    let iconName: String
    let colorHex: String
    let isMVP: Bool?
    let lessonCount: Int
    let fileName: String
    /// 資格レベル（Silver / Gold / beginner）
    let certificationLevel: CertificationLevel?
    /// 関連する試験トピック（例: ["演算子", "データ型"]）
    let examTopics: [String]?
    /// 学習カテゴリ（例: "basics", "oop"）
    let category: String?
}

// MARK: - 章コンテンツ（ch01_xxx.json 用）

/// 章ごとのJSONファイルのルートオブジェクト。
struct ChapterContent: Codable, Sendable {
    let courseId: String
    let lessons: [LessonData]
}

// MARK: - レッスン

/// 1レッスン分のデータ。解説セクションとクイズを含む。
struct LessonData: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let courseId: String
    let title: String
    let summary: String
    let estimatedMinutes: Int
    let order: Int
    let contents: [LessonSection]
    let quizzes: [QuizData]

    static func == (lhs: LessonData, rhs: LessonData) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - レッスン内セクション

/// レッスン内の1ブロック（概要・説明・コード例・ポイント・補足）。
struct LessonSection: Codable, Identifiable, Sendable {
    var id: String { "\(lessonId)_\(order)" }
    let lessonId: String
    let sectionType: SectionType
    let title: String
    let body: String?
    let code: String?
    let note: String?
    let order: Int

    enum SectionType: String, Codable, Sendable {
        case overview   // 概要
        case rule       // ルール・文法説明
        case code       // コード例
        case point      // ポイント・まとめ
        case tip        // コラム・補足
    }

    private enum CodingKeys: String, CodingKey {
        case lessonId, sectionType, title, body, code, note, order
    }
}

// MARK: - コード実行結果

/// プリコンパイル済みのコード実行結果。サーバーレスで即時表示する。
struct ExecutionResult: Codable, Hashable, Sendable {
    /// 標準出力テキスト（例: "Hello, World!"）。
    let output: String
    /// 終了コード（0=正常、1=エラー）。
    let exitCode: Int
    /// エラーが発生したか。
    let hasError: Bool
    /// エラーメッセージ（コンパイルエラー / 実行時例外）。
    let errorMessage: String?
    /// エラーの種類（例: "CompilationError", "NullPointerException"）。
    let errorType: String?
}

// MARK: - 穴埋め定義（codeComplete用）

/// コード補完問題の空欄定義。
struct BlankDefinition: Codable, Hashable, Sendable {
    /// 空欄ID（例: "blank_1"）。
    let id: String
    /// ラベル（例: "①"）。
    let label: String
    /// 選択肢群。
    let choices: [BlankChoice]
}

/// 空欄1つの選択肢。
struct BlankChoice: Codable, Hashable, Sendable {
    let id: String
    let text: String
    let isCorrect: Bool
}

/// 複数空欄の組み合わせ結果。codeComplete で全空欄を埋めた場合の実行結果。
struct CombinedResult: Codable, Hashable, Sendable {
    /// 空欄ID → 選択肢ID のマッピング（例: {"blank_1": "b1_c2", "blank_2": "b2_c1"}）。
    let combination: [String: String]
    /// この組み合わせの実行結果。
    let executionResult: ExecutionResult
}

// MARK: - クイズ

/// クイズ1問分。8種類の出題形式を type で区別する。
struct QuizData: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let lessonId: String
    let type: QuizType
    let question: String
    let code: String?
    let explanation: String
    let choices: [QuizChoice]
    /// 並び替え問題における正解順序（choices の id を正順で並べた配列）。
    let correctOrder: [String]?

    // MARK: 実行結果演出フィールド

    /// クイズ全体の実行結果（outputPredict 等で使用）。
    let executionResult: ExecutionResult?
    /// 修正後の正しい実行結果（errorFind で使用）。
    let fixedExecutionResult: ExecutionResult?

    // MARK: codeComplete フィールド

    /// コードテンプレート（空欄プレースホルダー "__BLANK_1__" 等を含む）。
    let codeTemplate: String?
    /// 空欄定義リスト。
    let blanks: [BlankDefinition]?
    /// 空欄の組み合わせ実行結果一覧。
    let combinedResults: [CombinedResult]?

    // MARK: multiChoice フィールド

    /// 選択すべき正解数（multiChoice の場合）。
    let requiredSelections: Int?

    // MARK: 資格試験メタ

    /// 資格試験の出題トピック（例: "データ型と変数"）。
    let certificationTopic: String?
    /// 難易度。
    let difficulty: QuizDifficulty?

    static func == (lhs: QuizData, rhs: QuizData) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// クイズ出題形式（8種類）。
    enum QuizType: String, Codable, Sendable {
        case fourChoice     // 4択（単一選択）
        case multiChoice    // 複数選択（🆕）
        case fillBlank      // 穴埋め（選択式）
        case reorder        // 並び替え
        case outputPredict  // 出力予想
        case errorFind      // エラー発見（旧 errorCause 互換）
        case codeComplete   // コード補完（🆕、複数空欄）
        case examSimulator  // 試験シミュレーター（🆕）

        /// 旧 errorCause との互換性。
        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            if raw == "errorCause" {
                self = .errorFind
            } else if let valid = QuizType(rawValue: raw) {
                self = valid
            } else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "Unknown QuizType: \(raw)")
                )
            }
        }
    }
}

// MARK: - QuizType 表示ヘルパー

import SwiftUI

extension QuizData.QuizType {
    /// UIに表示するラベルとカラーの統一定義。全Viewから参照すること。
    var displayLabel: String {
        switch self {
        case .fourChoice:     "4択問題"
        case .multiChoice:    "複数選択"
        case .fillBlank:      "穴埋め問題"
        case .reorder:        "並び替え問題"
        case .outputPredict:  "出力予想"
        case .errorFind:      "エラー発見"
        case .codeComplete:   "コード補完"
        case .examSimulator:  "試験形式"
        }
    }

    /// UIに表示するカラーの統一定義。
    var displayColor: Color {
        switch self {
        case .fourChoice:     AppColor.primary
        case .multiChoice:    AppColor.levelPurple
        case .fillBlank:      AppColor.success
        case .reorder:        AppColor.accent
        case .outputPredict:  AppColor.info
        case .errorFind:      AppColor.error
        case .codeComplete:   AppColor.quizCyan
        case .examSimulator:  AppColor.quizMagenta
        }
    }
}

/// クイズの選択肢1つ分。
struct QuizChoice: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let text: String
    let isCorrect: Bool
    let order: Int
    /// この選択肢を選んだ場合の実行結果（fillBlank / fourChoice 等）。
    let executionResult: ExecutionResult?
}

// MARK: - 用語辞典

/// 用語辞典の1エントリ。
struct GlossaryEntry: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let term: String
    /// 検索用カタカナ・ひらがな読み。
    let reading: String
    let definition: String
    let relatedLessonIds: [String]
}
