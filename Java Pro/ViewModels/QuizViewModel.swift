//
//  QuizViewModel.swift
//  Java Pro
//
//  クイズ画面のビジネスロジック・状態管理を担うViewModel。
//  QuizViewから@State群とロジックを抽出し、テスタビリティを向上させる。
//

import SwiftUI
import SwiftData
import os

@MainActor
@Observable
final class QuizViewModel {

    // MARK: - Input

    let quizzes: [QuizData]
    let lessonId: String?
    let isReviewMode: Bool
    let onComplete: (() -> Void)?
    let onNextLesson: ((String) -> Void)?

    // MARK: - State

    var currentIndex = 0
    var selectedChoiceId: String?
    var selectedChoiceIds: [String] = []
    var selectedOrderIds: [String] = []
    var blankSelections: [String: String] = [:]
    var isAnswered = false
    var isCorrect = false
    var correctCount = 0
    var showResult = false
    var showExecutionResult = false
    var earnedXP = 0
    var newBadges: [String] = []
    var newLevel: Int?
    var showConfetti = false
    var showLevelUpOverlay = false
    var answerShakeOffset: CGFloat = 0
    var correctBounce = false
    var showDismissConfirm = false

    /// ハプティクス・サウンド設定キャッシュ
    var hapticEnabled = true

    /// アニメーション用タスク
    var shakeTask: Task<Void, Never>?
    var bounceTask: Task<Void, Never>?
    var levelUpTask: Task<Void, Never>?

    private var quizStartTime = Date()
    private(set) var isNavigating = false

    // MARK: - Init

    init(quizzes: [QuizData], lessonId: String? = nil, isReviewMode: Bool = false,
         onComplete: (() -> Void)? = nil, onNextLesson: ((String) -> Void)? = nil) {
        self.quizzes = quizzes
        self.lessonId = lessonId
        self.isReviewMode = isReviewMode
        self.onComplete = onComplete
        self.onNextLesson = onNextLesson
    }

    // MARK: - Computed

    var currentQuizOrNil: QuizData? {
        guard !quizzes.isEmpty else { return nil }
        return quizzes[min(currentIndex, quizzes.count - 1)]
    }

    var currentQuiz: QuizData {
        guard let quiz = currentQuizOrNil else {
            assertionFailure("currentQuiz accessed while quizzes is empty")
            AppLogger.viewModel.fault("[QuizViewModel] currentQuiz accessed while quizzes is empty — fallback used")
            return QuizData(
                id: "fallback", lessonId: "", type: .fourChoice, question: "",
                code: nil, explanation: "", choices: [], correctOrder: nil,
                executionResult: nil, fixedExecutionResult: nil, codeTemplate: nil,
                blanks: nil, combinedResults: nil, requiredSelections: nil,
                certificationTopic: nil, difficulty: nil
            )
        }
        return quiz
    }

    var hasExecution: Bool {
        currentQuiz.executionResult != nil ||
        currentQuiz.fixedExecutionResult != nil ||
        (selectedChoiceId != nil && currentQuiz.choices.first(where: { $0.id == selectedChoiceId })?.executionResult != nil)
    }

    // MARK: - Actions

    func loadSettings(modelContext: ModelContext) {
        let settings = ProgressService(modelContext: modelContext).getSettings()
        hapticEnabled = settings.hapticFeedbackEnabled
    }

    func submitAnswer(modelContext: ModelContext, reduceMotion: Bool) {
        guard let selectedId = selectedChoiceId else { return }
        let correct = currentQuiz.choices.first { $0.id == selectedId }?.isCorrect ?? false
        processAnswer(correct: correct, modelContext: modelContext, reduceMotion: reduceMotion)
    }

    func submitMultiChoiceAnswer(modelContext: ModelContext, reduceMotion: Bool) {
        let correctIds = Set(currentQuiz.choices.filter(\.isCorrect).map(\.id))
        processAnswer(correct: Set(selectedChoiceIds) == correctIds, modelContext: modelContext, reduceMotion: reduceMotion)
    }

    func submitReorderAnswer(modelContext: ModelContext, reduceMotion: Bool) {
        guard let correctOrder = currentQuiz.correctOrder else {
            assertionFailure("QuizViewModel: reorder quiz missing correctOrder — quizId=\(currentQuiz.id)")
            processAnswer(correct: false, modelContext: modelContext, reduceMotion: reduceMotion)
            return
        }
        processAnswer(correct: selectedOrderIds == correctOrder, modelContext: modelContext, reduceMotion: reduceMotion)
    }

    func submitCodeCompleteAnswer(modelContext: ModelContext, reduceMotion: Bool) {
        guard let blanks = currentQuiz.blanks else { return }
        let correct = blanks.allSatisfy { blank in
            guard let selectedId = blankSelections[blank.id],
                  let choice = blank.choices.first(where: { $0.id == selectedId }) else { return false }
            return choice.isCorrect
        }
        processAnswer(correct: correct, modelContext: modelContext, reduceMotion: reduceMotion)
    }

    func processAnswer(correct: Bool, modelContext: ModelContext, reduceMotion: Bool) {
        isCorrect = correct
        if correct { correctCount += 1 }
        isAnswered = true

        // 回答アニメーション
        if !reduceMotion {
            if correct {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    correctBounce = true
                }
                bounceTask?.cancel()
                bounceTask = Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    guard !Task.isCancelled else { return }
                    withAnimation { correctBounce = false }
                }
            } else {
                shakeTask?.cancel()
                shakeTask = Task {
                    for offset: CGFloat in [12, -10, 8, -6, 4, -2, 0] {
                        guard !Task.isCancelled else { break }
                        answerShakeOffset = offset
                        try? await Task.sleep(for: .milliseconds(50))
                    }
                }
            }
        }

        // ハプティクス
        if hapticEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(correct ? .success : .error)
        }
        SoundService.shared.play(correct ? .correct : .incorrect)

        let gamification = GamificationService(modelContext: modelContext)
        if correct {
            if isReviewMode {
                if let lvl = gamification.awardReviewCorrectXP(quizId: currentQuiz.id) { newLevel = lvl }
                earnedXP += GamificationService.XPAmount.reviewCorrect
            } else {
                if let lvl = gamification.awardQuizCorrectXP(quizId: currentQuiz.id) { newLevel = lvl }
                earnedXP += GamificationService.XPAmount.quizCorrect
            }
        }

        let progressService = ProgressService(modelContext: modelContext)
        progressService.recordQuizAnswer(quizId: currentQuiz.id, isCorrect: correct)

        if hasExecution {
            withAnimation(AppAnimation.spring.delay(0.3)) { showExecutionResult = true }
        }
    }

    func completeQuizSession(modelContext: ModelContext) {
        showResult = true
        let gamification = GamificationService(modelContext: modelContext)

        if let lessonId {
            let service = ProgressService(modelContext: modelContext)
            let isFirstCompletion = service.getLessonProgress(lessonId: lessonId)?.status != .completed

            if correctCount == quizzes.count, isFirstCompletion {
                if let lvl = gamification.awardPerfectBonusXP(lessonId: lessonId) { newLevel = lvl }
                earnedXP += GamificationService.XPAmount.quizPerfect
            }

            service.completeLesson(lessonId: lessonId)

            if isFirstCompletion {
                if let lvl = gamification.awardLessonCompleteXP(lessonId: lessonId) { newLevel = lvl }
                earnedXP += GamificationService.XPAmount.lessonComplete
            }
        }

        onComplete?()

        let progressService = ProgressService(modelContext: modelContext)
        let level = gamification.getUserLevel()
        let streak = progressService.currentStreak()

        newBadges = gamification.checkAndAwardBadges(
            completedLessons: progressService.totalCompletedLessonCount(),
            correctQuizzes: progressService.totalCorrectQuizCount(),
            streak: streak,
            perfectCount: progressService.totalPerfectCount(),
            totalXP: level.totalXP
        )

        let elapsedSeconds = Date().timeIntervalSince(quizStartTime)
        if let speedBadge = gamification.checkAndAwardSpeedDemon(
            elapsedSeconds: elapsedSeconds,
            isPerfect: correctCount == quizzes.count
        ) {
            newBadges.append(speedBadge)
        }

        if let streakXP = gamification.awardStreakBonusIfNeeded(streakDays: streak) {
            earnedXP += streakXP
        }

        // 効果音
        if newLevel != nil {
            SoundService.shared.play(.levelUp)
            showConfetti = true
            levelUpTask?.cancel()
            levelUpTask = Task {
                try? await Task.sleep(for: .milliseconds(600))
                guard !Task.isCancelled else { return }
                showLevelUpOverlay = true
            }
        } else if !newBadges.isEmpty {
            SoundService.shared.play(.badgeEarned)
            showConfetti = true
        } else if Double(correctCount) / Double(max(quizzes.count, 1)) >= 0.8 {
            SoundService.shared.play(.lessonComplete)
            showConfetti = true
        } else {
            SoundService.shared.play(.lessonComplete)
        }
    }

    func moveToNext() {
        guard !isNavigating else { return }
        isNavigating = true
        shakeTask?.cancel()
        bounceTask?.cancel()
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            currentIndex += 1
            selectedChoiceId = nil
            selectedChoiceIds = []
            selectedOrderIds = []
            blankSelections = [:]
            isAnswered = false
            isCorrect = false
            showExecutionResult = false
            answerShakeOffset = 0
            correctBounce = false
            isNavigating = false
        }
    }

    func retryQuiz() {
        shakeTask?.cancel()
        bounceTask?.cancel()
        levelUpTask?.cancel()
        currentIndex = 0
        selectedChoiceId = nil
        selectedChoiceIds = []
        selectedOrderIds = []
        blankSelections = [:]
        isAnswered = false
        isCorrect = false
        correctCount = 0
        showResult = false
        showExecutionResult = false
        earnedXP = 0
        newBadges = []
        newLevel = nil
        showConfetti = false
        showLevelUpOverlay = false
        answerShakeOffset = 0
        correctBounce = false
        isNavigating = false
        quizStartTime = Date()
    }
}
