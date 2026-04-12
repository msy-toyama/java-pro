//
//  OnboardingView.swift
//  Java Pro
//
//  初回起動時のアプリ専用オンボーディング。
//  5ページ構成で、プロプロ の学習体験を実際に体感させながら
//  アプリの使い方を自然に理解させる。
//

import SwiftUI
import SwiftData

// MARK: - メインオンボーディング

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 6
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    LanguageSelectionPage()
                        .tag(0)
                    WelcomePage()
                        .tag(1)
                    LessonPreviewPage()
                        .tag(2)
                    QuizDemoPage()
                        .tag(3)
                    ReviewSystemPage()
                        .tag(4)
                    GoalSettingPage(onComplete: { dailyMinutes, enableNotifications in
                        saveGoalAndComplete(dailyMinutes: dailyMinutes, enableNotifications: enableNotifications)
                    })
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomControls
            }
        }
    }

    // MARK: - 背景

    private var backgroundGradient: some View {
        let colors: [Color] = {
            switch currentPage {
            case 0: return [AppColor.primary.opacity(0.05), AppColor.background]
            case 1: return [AppColor.primary.opacity(0.05), AppColor.background]
            case 2: return [AppColor.success.opacity(0.05), AppColor.background]
            case 3: return [AppColor.accent.opacity(0.05), AppColor.background]
            case 4: return [AppColor.levelPurple.opacity(0.05), AppColor.background]
            default: return [AppColor.primary.opacity(0.05), AppColor.background]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    // MARK: - 下部コントロール

    private var bottomControls: some View {
        VStack(spacing: AppLayout.paddingMD) {
            HStack(spacing: 6) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? AppColor.primary : AppColor.textTertiary.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }

            if currentPage < totalPages - 1 {
                HStack {
                    Button(lang.l("onboarding.skip")) {
                        completeOnboarding()
                    }
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut) {
                            currentPage += 1
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(lang.l("onboarding.next"))
                            Image(systemName: "arrow.right")
                        }
                        .font(AppFont.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppLayout.paddingLG)
                        .padding(.vertical, 12)
                        .background(AppColor.primary, in: Capsule())
                    }
                }
                .padding(.horizontal, AppLayout.paddingLG)
            }

            Spacer().frame(height: AppLayout.paddingMD)
        }
    }

    private func completeOnboarding() {
        let service = ProgressService(modelContext: modelContext)
        service.completeOnboarding()
        onComplete()
    }

    private func saveGoalAndComplete(dailyMinutes: Int, enableNotifications: Bool) {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()
        settings.dailyGoalMinutes = dailyMinutes
        settings.notificationsEnabled = enableNotifications
        if enableNotifications {
            settings.reminderHour = 20
            settings.reminderMinute = 0
        }
        service.completeOnboarding()
        onComplete()
    }
}

// MARK: - Page 0: 言語選択

private struct LanguageSelectionPage: View {
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()

            // Globe icon
            ZStack {
                Circle()
                    .fill(AppColor.primary.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "globe")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(AppColor.primary)
            }

            Text("Choose Your Language")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)

            Text("言語を選択してください")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)

            VStack(spacing: AppLayout.paddingSM) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button {
                        withAnimation(AppAnimation.quick) {
                            lang.setLanguage(language)
                        }
                    } label: {
                        HStack {
                            Text(language == .japanese ? "🇯🇵" : "🇺🇸")
                                .font(.title)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.displayName)
                                    .font(AppFont.headline)
                                    .foregroundStyle(AppColor.textPrimary)
                                Text(language.subtitle)
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                            Spacer()
                            if lang.currentLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColor.primary)
                                    .font(.title3)
                            }
                        }
                        .padding(AppLayout.paddingMD)
                        .background(
                            lang.currentLanguage == language ? AppColor.primary.opacity(0.08) : AppColor.cardBackground,
                            in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .stroke(lang.currentLanguage == language ? AppColor.primary : Color.gray.opacity(0.15), lineWidth: lang.currentLanguage == language ? 2 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal, AppLayout.paddingLG)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 1: ウェルカム

private struct WelcomePage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var lang: LanguageManager { LanguageManager.shared }
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var iconScale: CGFloat = 0.3

    var body: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.primary, AppColor.primaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: AppColor.primary.opacity(0.3), radius: 20, y: 10)
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(.white)
            }
            .scaleEffect(iconScale)
            .onAppear {
                if reduceMotion {
                    iconScale = 1.0
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        iconScale = 1.0
                    }
                }
            }

            VStack(spacing: AppLayout.paddingSM) {
                Text(lang.l("onboarding.title"))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)

                Text(lang.l("onboarding.tagline"))
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.primary)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 15)
            }

            Text(lang.l("onboarding.description", ContentService.shared.totalLessonCount))
                .font(AppFont.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, AppLayout.paddingLG)
                .opacity(showSubtitle ? 1 : 0)

            HStack(spacing: AppLayout.paddingSM) {
                FeatureChip(icon: "book.fill", text: lang.l("onboarding.feature.lessons", ContentService.shared.totalLessonCount), color: AppColor.primary)
                FeatureChip(icon: "questionmark.circle.fill", text: lang.l("onboarding.feature.quizzes", ContentService.shared.totalQuizCount), color: AppColor.success)
                FeatureChip(icon: "clock.fill", text: lang.l("onboarding.feature.time"), color: AppColor.accent)
            }
            .opacity(showSubtitle ? 1 : 0)

            Spacer()
            Spacer()
        }
        .onAppear {
            if reduceMotion {
                showTitle = true
                showSubtitle = true
            } else {
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) { showTitle = true }
                withAnimation(.easeOut(duration: 0.5).delay(0.6)) { showSubtitle = true }
            }
        }
    }
}

// MARK: - Page 2: レッスンプレビュー

private struct LessonPreviewPage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var lang: LanguageManager { LanguageManager.shared }
    @State private var showCards = false
    @State private var highlightedCard: Int?

    var body: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()

            VStack(spacing: AppLayout.paddingSM) {
                Text(lang.l("onboarding.lesson_title"))
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("onboarding.lesson_desc"))
                    .font(AppFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineSpacing(4)
            }

            VStack(spacing: AppLayout.paddingSM) {
                MockSectionCard(
                    icon: "doc.text",
                    iconColor: AppColor.info,
                    title: lang.l("onboarding.section.overview"),
                    bodyText: lang.l("onboarding.lesson_body.overview"),
                    isHighlighted: highlightedCard == 0
                )
                .offset(y: showCards ? 0 : 40)
                .opacity(showCards ? 1 : 0)

                MockSectionCard(
                    icon: "chevron.left.forwardslash.chevron.right",
                    iconColor: AppColor.success,
                    title: lang.l("onboarding.section.code"),
                    codeExample: "public class Hello {\n  public static void main(String[] args) {\n    System.out.println(\"Hello!\");\n  }\n}",
                    isHighlighted: highlightedCard == 1
                )
                .offset(y: showCards ? 0 : 60)
                .opacity(showCards ? 1 : 0)

                MockSectionCard(
                    icon: "star.fill",
                    iconColor: AppColor.accent,
                    title: lang.l("onboarding.section.point"),
                    bodyText: lang.l("onboarding.lesson_body.point"),
                    isHighlighted: highlightedCard == 2
                )
                .offset(y: showCards ? 0 : 80)
                .opacity(showCards ? 1 : 0)
            }
            .padding(.horizontal, AppLayout.paddingLG)

            Spacer()
            Spacer()
        }
        .onAppear {
            if reduceMotion {
                showCards = true
            } else {
                withAnimation(.easeOut(duration: 0.6)) { showCards = true }
            }
        }
        .task {
            guard !reduceMotion else { return }
            await cycleHighlightsAsync()
        }
    }

    private func cycleHighlightsAsync() async {
        for i in 0..<3 {
            try? await Task.sleep(for: .milliseconds(Int(Double(i) * 1200 + 800)))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) { highlightedCard = i }
        }
        try? await Task.sleep(for: .milliseconds(4400))
        guard !Task.isCancelled else { return }
        withAnimation(.easeInOut(duration: 0.3)) { highlightedCard = nil }
    }
}

// MARK: - Page 3: クイズデモ

private struct QuizDemoPage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var lang: LanguageManager { LanguageManager.shared }
    @State private var selectedChoice: Int?
    @State private var isAnswered = false
    @State private var showEncouragement = false

    private let demoChoices: [(text: String, isCorrect: Bool)] = [
        ("println()", false),
        ("System.out.println()", true),
        ("echo()", false),
        ("print()", false),
    ]

    var body: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()

            VStack(spacing: AppLayout.paddingSM) {
                Text(lang.l("onboarding.quiz_title"))
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("onboarding.quiz_desc"))
                    .font(AppFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
                Text(lang.l("onboarding.quiz_type"))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.primary)
                    .padding(.horizontal, AppLayout.paddingSM)
                    .padding(.vertical, AppLayout.paddingXS)
                    .background(AppColor.primary.opacity(0.12), in: Capsule())

                Text(lang.l("onboarding.quiz_question"))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineSpacing(4)

                ForEach(0..<demoChoices.count, id: \.self) { index in
                    Button {
                        guard !isAnswered else { return }
                        selectedChoice = index
                        isAnswered = true
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(demoChoices[index].isCorrect ? .success : .error)
                        if demoChoices[index].isCorrect {
                            if reduceMotion {
                                showEncouragement = true
                            } else {
                                withAnimation(.spring(response: 0.4)) { showEncouragement = true }
                            }
                        }
                    } label: {
                        HStack {
                            Text(demoChoices[index].text)
                                .font(AppFont.body)
                                .foregroundStyle(demoChoiceColor(index))
                            Spacer()
                            if isAnswered {
                                if demoChoices[index].isCorrect {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppColor.success)
                                } else if selectedChoice == index {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppColor.error)
                                }
                            }
                        }
                        .padding(AppLayout.paddingSM + 2)
                        .background(demoChoiceBG(index), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                                .stroke(demoChoiceBorder(index), lineWidth: 1.5)
                        )
                    }
                }

                if showEncouragement {
                    HStack(spacing: AppLayout.paddingSM) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColor.success)
                        Text(lang.l("onboarding.quiz_correct"))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.success)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if isAnswered, let selected = selectedChoice, !demoChoices[selected].isCorrect {
                    Button(lang.l("onboarding.quiz_retry")) {
                        withAnimation {
                            selectedChoice = nil
                            isAnswered = false
                            showEncouragement = false
                        }
                    }
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.primary)
                }
            }
            .padding(AppLayout.paddingMD)
            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, AppLayout.paddingLG)

            Spacer()
            Spacer()
        }
    }

    private func demoChoiceColor(_ index: Int) -> Color {
        guard isAnswered else { return AppColor.textPrimary }
        if demoChoices[index].isCorrect { return AppColor.success }
        if selectedChoice == index { return AppColor.error }
        return AppColor.textSecondary
    }

    private func demoChoiceBG(_ index: Int) -> Color {
        guard isAnswered else { return AppColor.cardBackground }
        if demoChoices[index].isCorrect { return AppColor.success.opacity(0.08) }
        if selectedChoice == index { return AppColor.error.opacity(0.08) }
        return AppColor.cardBackground
    }

    private func demoChoiceBorder(_ index: Int) -> Color {
        guard isAnswered else { return Color.gray.opacity(0.2) }
        if demoChoices[index].isCorrect { return AppColor.success }
        if selectedChoice == index { return AppColor.error }
        return Color.gray.opacity(0.1)
    }
}

// MARK: - Page 4: 復習システム

private struct ReviewSystemPage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var lang: LanguageManager { LanguageManager.shared }
    @State private var currentStage = -1

    private var stages: [(emoji: String, label: String, interval: String, color: Color)] {
        [
            ("🔴", lang.l("onboarding.review_stage.wrong"), lang.l("onboarding.review_interval.immediate"), AppColor.error),
            ("🟠", lang.l("onboarding.review_stage.1"), lang.l("onboarding.review_interval.24h"), Color(hex: "F97316")),
            ("🟡", lang.l("onboarding.review_stage.2"), lang.l("onboarding.review_interval.3d"), AppColor.accent),
            ("🟢", lang.l("onboarding.review_stage.3"), lang.l("onboarding.review_interval.7d"), AppColor.success),
            ("✅", lang.l("onboarding.review_stage.4"), lang.l("onboarding.review_interval.done"), AppColor.primary),
        ]
    }

    var body: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()

            VStack(spacing: AppLayout.paddingSM) {
                Text(lang.l("onboarding.review_title"))
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("onboarding.review_desc"))
                    .font(AppFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineSpacing(4)
            }

            VStack(spacing: 0) {
                ForEach(0..<stages.count, id: \.self) { index in
                    HStack(spacing: AppLayout.paddingMD) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(index <= currentStage ? stages[index].color : AppColor.textTertiary.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Text(stages[index].emoji)
                                        .font(.system(size: 14))
                                }
                                .scaleEffect(index == currentStage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4), value: currentStage)

                            if index < stages.count - 1 {
                                Rectangle()
                                    .fill(index < currentStage ? stages[index].color.opacity(0.5) : AppColor.textTertiary.opacity(0.15))
                                    .frame(width: 2, height: 28)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(stages[index].label)
                                .font(AppFont.headline)
                                .foregroundStyle(index <= currentStage ? AppColor.textPrimary : AppColor.textTertiary)
                            Text(stages[index].interval)
                                .font(AppFont.caption)
                                .foregroundStyle(index <= currentStage ? stages[index].color : AppColor.textTertiary)
                        }
                        .opacity(index <= currentStage ? 1.0 : 0.5)

                        Spacer()
                    }
                }
            }
            .padding(AppLayout.paddingLG)
            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            .padding(.horizontal, AppLayout.paddingLG)

            Text(lang.l("onboarding.review_bottom"))
                .font(AppFont.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textTertiary)

            Spacer()
            Spacer()
        }
        .task {
            guard !reduceMotion else {
                currentStage = stages.count - 1
                return
            }
            for i in 0..<stages.count {
                try? await Task.sleep(for: .milliseconds(Int(Double(i) * 500 + 300)))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.4)) { currentStage = i }
            }
        }
    }
}

// MARK: - Page 5: 目標設定と開始

private struct GoalSettingPage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var lang: LanguageManager { LanguageManager.shared }
    let onComplete: (_ dailyMinutes: Int, _ enableNotifications: Bool) -> Void

    @State private var selectedGoal: DailyGoal = .normal
    @State private var notificationsEnabled = true
    @State private var showStart = false

    var body: some View {
        VStack(spacing: AppLayout.paddingLG) {
            Spacer()

            VStack(spacing: AppLayout.paddingSM) {
                Text(lang.l("onboarding.pace_title"))
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("onboarding.pace_desc"))
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
            }

            VStack(spacing: AppLayout.paddingSM) {
                ForEach(DailyGoal.allCases, id: \.self) { goal in
                    Button {
                        withAnimation(AppAnimation.quick) { selectedGoal = goal }
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    } label: {
                        HStack {
                            Text(goal.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(goal.title)
                                    .font(AppFont.headline)
                                    .foregroundStyle(AppColor.textPrimary)
                                Text(goal.description)
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                            Spacer()
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColor.primary)
                                    .font(.title3)
                            }
                        }
                        .padding(AppLayout.paddingMD)
                        .background(
                            selectedGoal == goal ? AppColor.primary.opacity(0.08) : AppColor.cardBackground,
                            in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .stroke(selectedGoal == goal ? AppColor.primary : Color.gray.opacity(0.15), lineWidth: selectedGoal == goal ? 2 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal, AppLayout.paddingLG)

            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(AppColor.accent)
                Toggle(lang.l("onboarding.reminder"), isOn: $notificationsEnabled)
                    .font(AppFont.callout)
                    .tint(AppColor.primary)
            }
            .padding(.horizontal, AppLayout.paddingLG)

            Spacer()

            Button {
                Task {
                    var actuallyEnabled = notificationsEnabled
                    if notificationsEnabled {
                        let granted = await NotificationService.shared.requestAuthorization()
                        if granted {
                            let strings = LanguageManager.shared.notificationStrings()
                            NotificationService.shared.scheduleDailyReminder(hour: 20, minute: 0, title: strings.title, bodies: strings.bodies)
                        } else {
                            actuallyEnabled = false
                        }
                    }
                    onComplete(selectedGoal.minutes, actuallyEnabled)
                }
            } label: {
                HStack(spacing: AppLayout.paddingSM) {
                    Text(lang.l("onboarding.start"))
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppColor.primary, AppColor.primaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                )
                .shadow(color: AppColor.primary.opacity(0.3), radius: 12, y: 6)
            }
            .padding(.horizontal, AppLayout.paddingLG)
            .scaleEffect(showStart ? 1.0 : 0.9)
            .opacity(showStart ? 1.0 : 0)
            .onAppear {
                if reduceMotion {
                    showStart = true
                } else {
                    withAnimation(.spring(response: 0.5).delay(0.3)) { showStart = true }
                }
            }

            Spacer().frame(height: AppLayout.paddingXL + 60)
        }
    }
}

// MARK: - 日次目標

private enum DailyGoal: CaseIterable {
    case light, normal, intensive

    var emoji: String {
        switch self {
        case .light: return "🌱"
        case .normal: return "📚"
        case .intensive: return "🔥"
        }
    }

    var title: String {
        let lang = LanguageManager.shared
        switch self {
        case .light: return lang.l("onboarding.goal.light.title")
        case .normal: return lang.l("onboarding.goal.medium.title")
        case .intensive: return lang.l("onboarding.goal.heavy.title")
        }
    }

    var description: String {
        let lang = LanguageManager.shared
        switch self {
        case .light: return lang.l("onboarding.goal.light.desc")
        case .normal: return lang.l("onboarding.goal.medium.desc")
        case .intensive: return lang.l("onboarding.goal.heavy.desc")
        }
    }

    /// AppSettings.dailyGoalMinutes に保存する値。
    var minutes: Int {
        switch self {
        case .light: return 5
        case .normal: return 10
        case .intensive: return 20
        }
    }
}

// MARK: - 共通コンポーネント

private struct MockSectionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    var bodyText: String? = nil
    var codeExample: String? = nil
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.subheadline)
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
            }

            if let text = bodyText {
                Text(text)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineSpacing(2)
            }

            if let code = codeExample {
                Text(JavaSyntaxHighlighter.highlight(code))
                    .font(AppFont.codeSmall)
                    .padding(AppLayout.paddingSM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.codeBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
            }
        }
        .padding(AppLayout.paddingSM + 2)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                .stroke(isHighlighted ? iconColor.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isHighlighted ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}
