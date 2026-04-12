//
//  ExamService.swift
//  Java Pro
//
//  模擬試験データの読み込み・結果保存・分析を担当するサービス。
//  ExamSimulatorView と ExamResultView から利用される。
//

import Foundation
import SwiftData
import os

/// 模擬試験を管理するサービス。
@MainActor
@Observable
final class ExamService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - 試験定義

    /// Javaバージョン。
    enum JavaVersion: String, CaseIterable, Sendable {
        case se11 = "se11"
        case se17 = "se17"

        var displayName: String {
            switch self {
            case .se11: return "Java SE 11"
            case .se17: return "Java SE 17"
            }
        }
    }

    /// 模擬試験のメタデータ。titleKey/subtitleKey にローカライズキーを格納し、表示時に解決する。
    struct ExamDefinition {
        let id: String
        let titleKey: String
        let subtitleKey: String       // 試験番号情報
        let certLevel: CertificationLevel
        let javaVersion: JavaVersion
        let totalQuestions: Int        // 出題数（プールからランダム抽出）
        let timeLimitMinutes: Int
        let passingRate: Double        // 0.63
    }

    nonisolated static let examDefinitions: [ExamDefinition] = [
        // SE 11 Silver — 1Z0-815 出題範囲対応
        ExamDefinition(id: "se11_silver_1", titleKey: "exam_def.se11_silver_1.title", subtitleKey: "exam_def.se11_silver_1.subtitle",
                       certLevel: .silver, javaVersion: .se11, totalQuestions: 80, timeLimitMinutes: 180, passingRate: 0.63),
        ExamDefinition(id: "se11_silver_2", titleKey: "exam_def.se11_silver_2.title", subtitleKey: "exam_def.se11_silver_1.subtitle",
                       certLevel: .silver, javaVersion: .se11, totalQuestions: 80, timeLimitMinutes: 180, passingRate: 0.63),
        // SE 11 Gold — 1Z0-816 出題範囲対応
        ExamDefinition(id: "se11_gold_1",   titleKey: "exam_def.se11_gold_1.title",   subtitleKey: "exam_def.se11_gold.subtitle",
                       certLevel: .gold,   javaVersion: .se11, totalQuestions: 80, timeLimitMinutes: 180, passingRate: 0.63),
        ExamDefinition(id: "se11_gold_2",   titleKey: "exam_def.se11_gold_2.title",   subtitleKey: "exam_def.se11_gold.subtitle",
                       certLevel: .gold,   javaVersion: .se11, totalQuestions: 80, timeLimitMinutes: 180, passingRate: 0.63),
        // SE 17 Silver — 1Z0-825 出題範囲対応（60問 / 90分）
        ExamDefinition(id: "se17_silver_1", titleKey: "exam_def.se17_silver_1.title", subtitleKey: "exam_def.se17_silver_1.subtitle",
                       certLevel: .silver, javaVersion: .se17, totalQuestions: 60, timeLimitMinutes: 90, passingRate: 0.63),
        ExamDefinition(id: "se17_silver_2", titleKey: "exam_def.se17_silver_2.title", subtitleKey: "exam_def.se17_silver_1.subtitle",
                       certLevel: .silver, javaVersion: .se17, totalQuestions: 60, timeLimitMinutes: 90, passingRate: 0.63),
        // SE 17 Gold — 1Z0-826 出題範囲対応（60問 / 90分）
        ExamDefinition(id: "se17_gold_1",   titleKey: "exam_def.se17_gold_1.title",   subtitleKey: "exam_def.se17_gold.subtitle",
                       certLevel: .gold,   javaVersion: .se17, totalQuestions: 60, timeLimitMinutes: 90, passingRate: 0.63),
        ExamDefinition(id: "se17_gold_2",   titleKey: "exam_def.se17_gold_2.title",   subtitleKey: "exam_def.se17_gold.subtitle",
                       certLevel: .gold,   javaVersion: .se17, totalQuestions: 60, timeLimitMinutes: 90, passingRate: 0.63),
    ]

    /// 全模擬試験の合計問題数（表示用）。
    nonisolated static var totalExamQuestionCount: Int {
        examDefinitions.reduce(0) { $0 + $1.totalQuestions }
    }

    /// 標準合格率（全試験共通のデフォルト値）。
    nonisolated static let defaultPassingRate: Double = 0.63

    /// 合格ラインの表示用パーセント文字列。
    nonisolated static var passingRatePercent: Int {
        Int(defaultPassingRate * 100)
    }

    /// 指定条件の試験定義を取得する。
    static func exams(certLevel: CertificationLevel, javaVersion: JavaVersion) -> [ExamDefinition] {
        examDefinitions.filter { $0.certLevel == certLevel && $0.javaVersion == javaVersion }
    }

    // MARK: - 試験問題ロード

    /// 模擬試験の全問題を読み込む。
    func loadExamQuizzes(examId: String) -> [QuizData] {
        let fileName = "exam_questions_\(examId)"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            AppLogger.content.error("ExamService: \(fileName).json が見つかりません")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([QuizData].self, from: data)
        } catch {
            AppLogger.content.error("ExamService: \(fileName).json のデコードに失敗: \(error)")
            return []
        }
    }

    // MARK: - 結果保存

    /// 模擬試験結果を保存する。
    func saveResult(
        examId: String,
        score: Int,
        totalQuestions: Int,
        timeSpentSeconds: Int,
        topicScores: [String: Double]? = nil
    ) -> UserExamResult {
        // 試験定義から合格率を取得（未定義の場合はデフォルト値を使用）
        let passingRate = Self.examDefinitions.first(where: { $0.id == examId })?.passingRate
            ?? Self.defaultPassingRate
        let result = UserExamResult(
            examChapterId: examId,
            score: score,
            totalQuestions: totalQuestions,
            timeSpentSeconds: timeSpentSeconds,
            passingRate: passingRate
        )

        // トピック別スコアをJSON文字列として保存
        if let topicScores, let jsonData = try? JSONEncoder().encode(topicScores) {
            result.topicScoresJSON = String(data: jsonData, encoding: .utf8)
        }

        modelContext.insert(result)
        saveContext()
        return result
    }

    // MARK: - 履歴参照

    /// 模擬試験の履歴を取得する。certLevel でフィルタ可能。
    func examHistory(certLevel: CertificationLevel? = nil) -> [UserExamResult] {
        var descriptor = FetchDescriptor<UserExamResult>(
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        if let certLevel {
            switch certLevel {
            case .silver:
                descriptor.predicate = #Predicate { result in
                    result.examChapterId.contains("silver")
                }
            case .gold:
                descriptor.predicate = #Predicate { result in
                    result.examChapterId.contains("gold")
                }
            case .beginner:
                // beginner 用の模擬試験は存在しないため空配列を返す
                return []
            }
        }
        return modelContext.fetchLogged(descriptor)
    }

    /// 最新の合格結果を取得する。
    func latestPassedResult(certLevel: CertificationLevel) -> UserExamResult? {
        guard certLevel == .silver || certLevel == .gold else { return nil }
        let suffix = certLevel == .silver ? "silver" : "gold"
        let descriptor = FetchDescriptor<UserExamResult>(
            predicate: #Predicate { result in
                result.passed && result.examChapterId.contains(suffix)
            },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        return modelContext.fetchFirstLogged(descriptor)
    }

    /// 指定試験の受験回数。
    func attemptCount(examId: String) -> Int {
        let descriptor = FetchDescriptor<UserExamResult>(
            predicate: #Predicate { $0.examChapterId == examId }
        )
        return modelContext.fetchCountLogged(descriptor)
    }

    /// トピック別スコアをデコードする。
    func decodeTopicScores(_ result: UserExamResult) -> [String: Double] {
        guard let jsonString = result.topicScoresJSON,
              let jsonData = jsonString.data(using: .utf8),
              let scores = try? JSONDecoder().decode([String: Double].self, from: jsonData) else {
            return [:]
        }
        return scores
    }

    /// 推定合格率を算出する（直近3回の平均正答率ベース）。
    func estimatedPassRate(certLevel: CertificationLevel) -> Double? {
        let history = examHistory(certLevel: certLevel)
        let recentResults = Array(history.prefix(3))
        guard !recentResults.isEmpty else { return nil }

        let avgRate = recentResults.reduce(0.0) { sum, result in
            sum + Double(result.score) / Double(max(result.totalQuestions, 1))
        } / Double(recentResults.count)

        return avgRate
    }

    // MARK: - Private

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            AppLogger.swiftData.error("ExamService 保存エラー: \(error.localizedDescription)")
            SaveErrorNotifier.shared.report(error)
        }
    }

    // MARK: - Topic Display Name

    /// certificationTopic キーをローカライズ済み表示名に変換する。
    static func topicDisplayName(_ key: String) -> String {
        LanguageManager.shared.l("topic.\(key)")
    }
}
