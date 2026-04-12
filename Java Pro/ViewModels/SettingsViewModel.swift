//
//  SettingsViewModel.swift
//  Java Pro
//
//  設定画面のビジネスロジック・状態管理を担うViewModel。
//  18個の@Stateとデータ操作ロジックを集約し、View層を薄く保つ。
//

import SwiftUI
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - State
    // ⚠️ 以下の初期値は AppSettings.init() と同期すること（UserModels.swift 参照）。
    // loadSettings(modelContext:) で実際の保存値に上書きされるが、呼び出し前に
    // 表示される可能性があるため、同じデフォルトを維持する必要がある。

    var notificationsEnabled = true
    var reminderHour = 8
    var reminderMinute = 0
    var showResetConfirm = false
    var showResetComplete = false
    var showResetError = false
    var showPermissionDenied = false
    var showPaywall = false
    var isDarkMode: Bool? = nil
    var selectedCertification: CertificationLevel = .beginner
    var dailyGoalMinutes = 15
    var hapticFeedbackEnabled = true
    var soundEnabled = true
    var soundVolume: Double = 0.7
    var volumeSaveTask: Task<Void, Never>?

    // MARK: - Computed

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var reminderTimeBinding: Binding<Date> {
        Binding<Date>(
            get: { [self] in
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { [self] newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 20
                reminderMinute = components.minute ?? 0
            }
        )
    }

    // MARK: - Settings IO

    func loadSettings(modelContext: ModelContext) {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()
        notificationsEnabled = settings.notificationsEnabled
        reminderHour = settings.reminderHour
        reminderMinute = settings.reminderMinute
        isDarkMode = settings.isDarkMode
        selectedCertification = settings.selectedCertification
        dailyGoalMinutes = settings.dailyGoalMinutes
        hapticFeedbackEnabled = settings.hapticFeedbackEnabled
        soundEnabled = settings.soundEnabled
        soundVolume = settings.soundVolume
        SoundService.shared.isEnabled = settings.soundEnabled
        SoundService.shared.volume = Float(settings.soundVolume)
    }

    func updateAppearance(modelContext: ModelContext) {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()
        settings.isDarkMode = isDarkMode
        do {
            try modelContext.save()
        } catch {
            SaveErrorNotifier.shared.report(error)
        }
        AppearanceManager.shared.setDarkMode(isDarkMode)
    }

    func updateSettings(modelContext: ModelContext) {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()
        settings.selectedCertification = selectedCertification
        settings.dailyGoalMinutes = dailyGoalMinutes
        settings.hapticFeedbackEnabled = hapticFeedbackEnabled
        settings.soundEnabled = soundEnabled
        settings.soundVolume = soundVolume
        SoundService.shared.isEnabled = soundEnabled
        SoundService.shared.volume = Float(soundVolume)
        do {
            try modelContext.save()
        } catch {
            SaveErrorNotifier.shared.report(error)
        }
    }

    func updateNotification(enabled: Bool, modelContext: ModelContext) {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()

        if enabled {
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    settings.notificationsEnabled = true
                    let strings = LanguageManager.shared.notificationStrings()
                    NotificationService.shared.scheduleDailyReminder(hour: self.reminderHour, minute: self.reminderMinute, title: strings.title, bodies: strings.bodies)
                } else {
                    notificationsEnabled = false
                    settings.notificationsEnabled = false
                    showPermissionDenied = true
                }
                do {
                    try modelContext.save()
                } catch {
                    SaveErrorNotifier.shared.report(error)
                }
            }
        } else {
            settings.notificationsEnabled = false
            NotificationService.shared.cancelDailyReminder()
            do {
                try modelContext.save()
            } catch {
                SaveErrorNotifier.shared.report(error)
            }
        }
    }

    func updateReminderTime(modelContext: ModelContext) {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()
        settings.reminderHour = reminderHour
        settings.reminderMinute = reminderMinute
        do {
            try modelContext.save()
        } catch {
            SaveErrorNotifier.shared.report(error)
        }

        if notificationsEnabled {
            Task {
                let strings = LanguageManager.shared.notificationStrings()
                NotificationService.shared.scheduleDailyReminder(hour: self.reminderHour, minute: self.reminderMinute, title: strings.title, bodies: strings.bodies)
            }
        }
    }

    func resetAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: UserLessonProgress.self)
            try modelContext.delete(model: UserQuizHistory.self)
            try modelContext.delete(model: UserDailyRecord.self)
            try modelContext.delete(model: UserXPRecord.self)
            try modelContext.delete(model: UserBadge.self)
            try modelContext.delete(model: UserLevel.self)
            try modelContext.delete(model: UserExamResult.self)
            try modelContext.delete(model: AppSettings.self)
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try modelContext.save()
            loadSettings(modelContext: modelContext)
            AppearanceManager.shared.sync(from: newSettings.isDarkMode)
            NotificationService.shared.cancelDailyReminder()
            UserDefaults.standard.hasSeenHomeTour = false
            UserDefaults.standard.hasSeenLearnTour = false
            UserDefaults.standard.hasSeenExamTour = false
            UserDefaults.standard.hasSeenPracticeTour = false
            UserDefaults.standard.removeObject(forKey: "dataRecoveryMode")
            showResetComplete = true
        } catch {
            SaveErrorNotifier.shared.report(error)
            showResetError = true
        }
    }

    func cancelVolumeSaveTask() {
        volumeSaveTask?.cancel()
    }

    /// 音量変更のデバウンス保存
    func debounceSaveVolume(modelContext: ModelContext) {
        SoundService.shared.volume = Float(soundVolume)
        volumeSaveTask?.cancel()
        volumeSaveTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            updateSettings(modelContext: modelContext)
        }
    }
}
