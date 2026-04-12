//
//  SettingsView.swift
//  Java Pro
//
//  設定画面。外観・通知・資格目標・広告非表示・データ管理を提供する。
//  データ操作・状態管理はSettingsViewModelに委譲し、View層を薄く保つ。
//

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = SettingsViewModel()
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            List {
                // 外観セクション
                Section(lang.l("settings.section.appearance")) {
                    Picker(lang.l("settings.theme"), selection: Binding(
                        get: { vm.isDarkMode.map { $0 ? 1 : 0 } ?? 2 },
                        set: { value in
                            switch value {
                            case 0: vm.isDarkMode = false
                            case 1: vm.isDarkMode = true
                            default: vm.isDarkMode = nil
                            }
                            vm.updateAppearance(modelContext: modelContext)
                        }
                    )) {
                        Text(lang.l("settings.theme.light")).tag(0)
                        Text(lang.l("settings.theme.dark")).tag(1)
                        Text(lang.l("settings.theme.system")).tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                .sectionAppear(index: 0)

                // 言語セクション
                Section(lang.l("settings.section.language")) {
                    Picker(lang.l("settings.language"), selection: Binding(
                        get: { lang.currentLanguage },
                        set: { lang.setLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }
                .sectionAppear(index: 1)

                // 学習目標
                Section(lang.l("settings.section.goals")) {
                    Picker(lang.l("settings.cert_goal"), selection: $vm.selectedCertification) {
                        Text(lang.l("settings.cert.beginner")).tag(CertificationLevel.beginner)
                        Text("Java Silver").tag(CertificationLevel.silver)
                        Text("Java Gold").tag(CertificationLevel.gold)
                    }
                    .onChange(of: vm.selectedCertification) { _, _ in vm.updateSettings(modelContext: modelContext) }

                    Stepper(lang.l("settings.daily_goal", vm.dailyGoalMinutes), value: $vm.dailyGoalMinutes, in: 5...60, step: 5)
                        .onChange(of: vm.dailyGoalMinutes) { _, _ in vm.updateSettings(modelContext: modelContext) }
                }
                .sectionAppear(index: 2)

                // フィードバック
                Section(lang.l("settings.section.feedback")) {
                    Toggle(isOn: $vm.hapticFeedbackEnabled) {
                        Label(lang.l("settings.haptic"), systemImage: "hand.tap.fill")
                    }
                    .tint(AppColor.primary)
                    .onChange(of: vm.hapticFeedbackEnabled) { _, _ in vm.updateSettings(modelContext: modelContext) }

                    if vm.hapticFeedbackEnabled {
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } label: {
                            Label(lang.l("settings.haptic_test"), systemImage: "iphone.radiowaves.left.and.right")
                                .font(AppFont.callout)
                        }
                    }

                    Toggle(isOn: $vm.soundEnabled) {
                        Label(lang.l("settings.sound"), systemImage: vm.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    }
                    .tint(AppColor.primary)
                    .onChange(of: vm.soundEnabled) { _, _ in vm.updateSettings(modelContext: modelContext) }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.soundEnabled)

                    if vm.soundEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(lang.l("settings.volume")) \(Int(vm.soundVolume * 100))%")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                                .contentTransition(.numericText())
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.fill")
                                    .font(.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                                Slider(value: $vm.soundVolume, in: 0.05...1.0, step: 0.05)
                                    .tint(AppColor.primary)
                                    .onChange(of: vm.soundVolume) { _, _ in
                                        vm.debounceSaveVolume(modelContext: modelContext)
                                    }
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                        }

                        HStack(spacing: AppLayout.paddingSM) {
                            Button(lang.l("settings.sound.correct")) { SoundService.shared.play(.correct) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.success)
                            Button(lang.l("settings.sound.incorrect")) { SoundService.shared.play(.incorrect) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.error)
                            Button(lang.l("settings.sound.complete")) { SoundService.shared.play(.lessonComplete) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.primary)
                            Button(lang.l("settings.sound.level_up")) { SoundService.shared.play(.levelUp) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.xpGold)
                        }
                        .font(AppFont.caption)
                    }
                }
                .sectionAppear(index: 3)

                // 通知セクション
                Section(lang.l("settings.section.reminder")) {
                    Toggle(isOn: $vm.notificationsEnabled) {
                        Label(lang.l("settings.notification"), systemImage: vm.notificationsEnabled ? "bell.fill" : "bell.slash")
                    }
                    .tint(AppColor.primary)
                    .onChange(of: vm.notificationsEnabled) { _, newValue in
                        vm.updateNotification(enabled: newValue, modelContext: modelContext)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.notificationsEnabled)

                    if vm.notificationsEnabled {
                        DatePicker(
                            lang.l("settings.notification_time"),
                            selection: vm.reminderTimeBinding,
                            displayedComponents: .hourAndMinute
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .onChange(of: vm.reminderHour) { _, _ in vm.updateReminderTime(modelContext: modelContext) }
                        .onChange(of: vm.reminderMinute) { _, _ in vm.updateReminderTime(modelContext: modelContext) }
                    }
                }
                .sectionAppear(index: 4)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.notificationsEnabled)

                // プランセクション
                Section(lang.l("settings.section.plan")) {
                    if StoreService.shared.fullAccessUnlocked || StoreService.shared.debugUnlockAll {
                        HStack {
                            Label(lang.l("settings.full_access"), systemImage: "checkmark.seal.fill")
                                .foregroundStyle(AppColor.success)
                                .symbolEffect(.bounce, options: .nonRepeating)
                            Spacer()
                            #if DEBUG
                            if !StoreService.shared.fullAccessUnlocked {
                                Text(lang.l("settings.debug"))
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                            } else {
                                Text(lang.l("settings.purchased"))
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                            #else
                            Text(lang.l("settings.purchased"))
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textTertiary)
                            #endif
                        }
                    } else {
                        Button {
                            vm.showPaywall = true
                        } label: {
                            HStack {
                                Label(lang.l("settings.purchase_full"), systemImage: "crown.fill")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                        }

                        Button(lang.l("settings.restore")) {
                            Task {
                                await StoreService.shared.restorePurchases()
                            }
                        }
                        .font(AppFont.callout)
                        .disabled(StoreService.shared.isPurchasing)
                    }
                }
                .sectionAppear(index: 5)

                // データセクション
                Section(lang.l("settings.section.data")) {
                    Button(role: .destructive) {
                        vm.showResetConfirm = true
                    } label: {
                        Label(lang.l("settings.reset_data"), systemImage: "trash")
                    }
                }
                .sectionAppear(index: 6)

                // アプリ情報
                Section(lang.l("settings.section.app_info")) {
                    HStack {
                        Text(lang.l("settings.version"))
                        Spacer()
                        Text(vm.appVersion)
                            .foregroundStyle(AppColor.textTertiary)
                    }
                    HStack {
                        Text(lang.l("settings.build"))
                        Spacer()
                        Text(vm.buildNumber)
                            .foregroundStyle(AppColor.textTertiary)
                    }
                    if let termsURL = URL(string: "https://msy-toyama.github.io/java-pro/terms.html") {
                    Link(destination: termsURL) {
                        HStack {
                            Label(lang.l("settings.terms"), systemImage: "doc.text")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(AppColor.textTertiary)
                        }
                    }
                    }
                    if let privacyURL = URL(string: "https://msy-toyama.github.io/java-pro/privacy.html") {
                    Link(destination: privacyURL) {
                        HStack {
                            Label(lang.l("settings.privacy"), systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(AppColor.textTertiary)
                        }
                    }
                    }
                    // Oracle 商標免責事項
                    Text(lang.l("settings.oracle_disclaimer"))
                        .font(.system(size: 11))
                        .foregroundStyle(AppColor.textTertiary)
                }
                .sectionAppear(index: 7)
            }
            .navigationTitle(lang.l("settings.title"))
            .onAppear { vm.loadSettings(modelContext: modelContext) }
            .onDisappear { vm.cancelVolumeSaveTask() }
            .alert(lang.l("settings.reset_confirm_title"), isPresented: $vm.showResetConfirm) {
                Button(lang.l("settings.reset_button"), role: .destructive) {
                    vm.resetAllData(modelContext: modelContext)
                }
                Button(lang.l("settings.cancel"), role: .cancel) {}
            } message: {
                Text(lang.l("settings.reset_confirm_message"))
            }
            .alert(lang.l("settings.notification_denied_title"), isPresented: $vm.showPermissionDenied) {
                Button(lang.l("settings.open_settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(lang.l("settings.close"), role: .cancel) {}
            } message: {
                Text(lang.l("settings.notification_denied_message"))
            }
            .sheet(isPresented: $vm.showPaywall) {
                PaywallView()
            }
            .alert(lang.l("settings.reset_complete_title"), isPresented: $vm.showResetComplete) {
                Button(lang.l("settings.ok")) {}
            } message: {
                Text(lang.l("settings.reset_complete_message"))
            }
            .alert(lang.l("settings.reset_error_title"), isPresented: $vm.showResetError) {
                Button(lang.l("settings.ok"), role: .cancel) {}
            } message: {
                Text(lang.l("settings.reset_error_message"))
            }
        }
    }}