//
//  ExamSimulatorViewModel.swift
//  Java Pro
//
//  模擬試験画面のビジネスロジック・状態管理を担うViewModel。
//  ExamSimulatorViewから20個の@Stateとロジックを抽出し、View層を薄く保つ。
//

import SwiftUI
import SwiftData

@MainActor
@Observable
final class ExamSimulatorViewModel {

    // MARK: - Input

    let examId: String

    // MARK: - State

    var quizzes: [QuizData] = []
    var isExamLoaded = false
    var currentIndex = 0
    var answers: [String: String] = [:]          // quizId -> choiceId
    var multiAnswers: [String: [String]] = [:]   // quizId -> [choiceId]
    var flaggedQuestions: Set<Int> = []
    var remainingSeconds: Int = 180 * 60
    var timerActive = true
    var showQuestionList = false
    var showConfirmEnd = false
    var examFinished = false
    var isFinishing = false
    var examResult: UserExamResult?
    var topicScores: [String: Double] = [:]
    var backgroundDate: Date?
    var loadError = false
    var backgroundRemainingSeconds: Int?
    var slideDirection: Edge = .trailing
    var flagBounce = false

    // MARK: - Computed

    var exam: ExamService.ExamDefinition? {
        ExamService.examDefinitions.first { $0.id == examId }
    }

    var currentQuiz: QuizData? {
        quizzes.indices.contains(currentIndex) ? quizzes[currentIndex] : nil
    }

    var answeredCount: Int {
        answers.count + multiAnswers.count
    }

    var timeString: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Init

    init(examId: String) {
        self.examId = examId
    }

    // MARK: - Actions

    func toggleChoice(quiz: QuizData, choiceId: String) {
        let isMulti = quiz.type == .multiChoice
        if isMulti {
            var current = multiAnswers[quiz.id] ?? []
            if let idx = current.firstIndex(of: choiceId) {
                current.remove(at: idx)
                if current.isEmpty {
                    multiAnswers.removeValue(forKey: quiz.id)
                } else {
                    multiAnswers[quiz.id] = current
                }
            } else {
                let maxSelections = quiz.requiredSelections ?? 2
                if current.count >= maxSelections {
                    current.removeFirst()
                }
                current.append(choiceId)
                multiAnswers[quiz.id] = current
            }
        } else {
            answers[quiz.id] = choiceId
        }
    }

    func toggleFlag() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            flaggedQuestions.formSymmetricDifference([currentIndex])
            flagBounce = true
        }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            flagBounce = false
        }
    }

    func goToPrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideDirection = .leading
            currentIndex -= 1
        }
    }

    func goToNext() {
        if currentIndex < quizzes.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                slideDirection = .trailing
                currentIndex += 1
            }
        } else {
            showConfirmEnd = true
        }
    }

    func jumpToQuestion(_ index: Int) {
        slideDirection = index > currentIndex ? .trailing : .leading
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            currentIndex = index
        }
        showQuestionList = false
    }

    // MARK: - Background handling

    func handleResignActive() {
        backgroundDate = Date()
        backgroundRemainingSeconds = remainingSeconds
    }

    func handleBecomeActive() {
        guard let bg = backgroundDate,
              let bgRemaining = backgroundRemainingSeconds,
              timerActive, !examFinished else {
            backgroundDate = nil
            backgroundRemainingSeconds = nil
            return
        }
        let elapsed = Int(Date().timeIntervalSince(bg))
        let safeElapsed = max(0, elapsed)
        remainingSeconds = min(bgRemaining, max(0, bgRemaining - safeElapsed))
        backgroundDate = nil
        backgroundRemainingSeconds = nil
        if remainingSeconds <= 0 {
            // finishExam will be triggered by the timer
        }
    }

    // MARK: - Loading

    func loadExam(modelContext: ModelContext) {
        guard !isExamLoaded else { return }
        isExamLoaded = true

        let service = ExamService(modelContext: modelContext)
        var loaded = service.loadExamQuizzes(examId: examId)
        if loaded.isEmpty {
            loadError = true
            return
        }
        loaded.shuffle()
        if let exam {
            quizzes = Array(loaded.prefix(exam.totalQuestions))
            remainingSeconds = exam.timeLimitMinutes * 60
        } else {
            quizzes = loaded
        }
    }

    // MARK: - Timer tick

    func timerTick(modelContext: ModelContext) {
        guard timerActive, !examFinished, !isFinishing else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            finishExam(modelContext: modelContext)
        }
    }

    // MARK: - Finish

    func finishExam(modelContext: ModelContext) {
        guard !examFinished, !isFinishing else { return }
        isFinishing = true
        timerActive = false

        var correctCount = 0
        var topicCorrect: [String: Int] = [:]
        var topicTotal: [String: Int] = [:]

        for quiz in quizzes {
            let topic = quiz.certificationTopic ?? "general"
            topicTotal[topic, default: 0] += 1

            let isCorrect: Bool
            if quiz.type == .multiChoice {
                let correctIds = Set(quiz.choices.filter(\.isCorrect).map(\.id))
                isCorrect = Set(multiAnswers[quiz.id] ?? []) == correctIds
            } else {
                let correctId = quiz.choices.first(where: \.isCorrect)?.id
                isCorrect = answers[quiz.id] == correctId
            }

            if isCorrect {
                correctCount += 1
                topicCorrect[topic, default: 0] += 1
            }
        }

        for (topic, total) in topicTotal {
            topicScores[topic] = Double(topicCorrect[topic, default: 0]) / Double(total)
        }

        let timeSpent = (exam?.timeLimitMinutes ?? 180) * 60 - remainingSeconds

        let service = ExamService(modelContext: modelContext)
        let result = service.saveResult(
            examId: examId,
            score: correctCount,
            totalQuestions: quizzes.count,
            timeSpentSeconds: timeSpent,
            topicScores: topicScores
        )

        let gamification = GamificationService(modelContext: modelContext)
        if result.passed {
            let previousPassCount = service.examHistory(certLevel: nil)
                .filter { $0.examChapterId == examId && $0.passed && $0.id != result.id }
                .count
            if previousPassCount == 0 {
                _ = gamification.awardXP(amount: 500, reason: "exam_pass", relatedId: examId)
            }
        }

        let progressService = ProgressService(modelContext: modelContext)
        let level = gamification.getUserLevel()
        _ = gamification.checkAndAwardBadges(
            completedLessons: progressService.totalCompletedLessonCount(),
            correctQuizzes: progressService.totalCorrectQuizCount(),
            streak: progressService.currentStreak(),
            perfectCount: progressService.totalPerfectCount(),
            totalXP: level.totalXP
        )

        examResult = result
        examFinished = true
        SoundService.shared.play(.lessonComplete)
    }
}
