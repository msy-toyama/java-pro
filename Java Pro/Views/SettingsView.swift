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

    var body: some View {
        NavigationStack {
            List {
                // 外観セクション
                Section("外観") {
                    Picker("テーマ", selection: Binding(
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
                        Text("ライト").tag(0)
                        Text("ダーク").tag(1)
                        Text("システム").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                .sectionAppear(index: 0)

                // 学習目標
                Section("学習目標") {
                    Picker("目標資格", selection: $vm.selectedCertification) {
                        Text("入門（資格なし）").tag(CertificationLevel.beginner)
                        Text("Java Silver").tag(CertificationLevel.silver)
                        Text("Java Gold").tag(CertificationLevel.gold)
                    }
                    .onChange(of: vm.selectedCertification) { _, _ in vm.updateSettings(modelContext: modelContext) }

                    Stepper("1日の目標: \(vm.dailyGoalMinutes)分", value: $vm.dailyGoalMinutes, in: 5...60, step: 5)
                        .onChange(of: vm.dailyGoalMinutes) { _, _ in vm.updateSettings(modelContext: modelContext) }
                }
                .sectionAppear(index: 1)

                // フィードバック
                Section("フィードバック") {
                    Toggle(isOn: $vm.hapticFeedbackEnabled) {
                        Label("触覚フィードバック", systemImage: "hand.tap.fill")
                    }
                    .tint(AppColor.primary)
                    .onChange(of: vm.hapticFeedbackEnabled) { _, _ in vm.updateSettings(modelContext: modelContext) }

                    if vm.hapticFeedbackEnabled {
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } label: {
                            Label("振動をテスト", systemImage: "iphone.radiowaves.left.and.right")
                                .font(AppFont.callout)
                        }
                    }

                    Toggle(isOn: $vm.soundEnabled) {
                        Label("効果音", systemImage: vm.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    }
                    .tint(AppColor.primary)
                    .onChange(of: vm.soundEnabled) { _, _ in vm.updateSettings(modelContext: modelContext) }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.soundEnabled)

                    if vm.soundEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("音量: \(Int(vm.soundVolume * 100))%")
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
                            Button("正解") { SoundService.shared.play(.correct) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.success)
                            Button("不正解") { SoundService.shared.play(.incorrect) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.error)
                            Button("完了") { SoundService.shared.play(.lessonComplete) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.primary)
                            Button("レベルUP") { SoundService.shared.play(.levelUp) }
                                .buttonStyle(.bordered)
                                .tint(AppColor.xpGold)
                        }
                        .font(AppFont.caption)
                    }
                }
                .sectionAppear(index: 2)

                // 通知セクション
                Section("学習リマインダー") {
                    Toggle(isOn: $vm.notificationsEnabled) {
                        Label("毎日の通知", systemImage: vm.notificationsEnabled ? "bell.fill" : "bell.slash")
                    }
                    .tint(AppColor.primary)
                    .onChange(of: vm.notificationsEnabled) { _, newValue in
                        vm.updateNotification(enabled: newValue, modelContext: modelContext)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.notificationsEnabled)

                    if vm.notificationsEnabled {
                        DatePicker(
                            "通知時間",
                            selection: vm.reminderTimeBinding,
                            displayedComponents: .hourAndMinute
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .onChange(of: vm.reminderHour) { _, _ in vm.updateReminderTime(modelContext: modelContext) }
                        .onChange(of: vm.reminderMinute) { _, _ in vm.updateReminderTime(modelContext: modelContext) }
                    }
                }
                .sectionAppear(index: 3)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.notificationsEnabled)

                // プランセクション
                Section("プラン") {
                    if StoreService.shared.fullAccessUnlocked || StoreService.shared.debugUnlockAll {
                        HStack {
                            Label("フルアクセス", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(AppColor.success)
                                .symbolEffect(.bounce, options: .nonRepeating)
                            Spacer()
                            #if DEBUG
                            if !StoreService.shared.fullAccessUnlocked {
                                Text("デバッグ")
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                            } else {
                                Text("購入済み")
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                            #else
                            Text("購入済み")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textTertiary)
                            #endif
                        }
                    } else {
                        Button {
                            vm.showPaywall = true
                        } label: {
                            HStack {
                                Label("フルアクセスを購入", systemImage: "crown.fill")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                        }

                        Button("購入を復元") {
                            Task {
                                await StoreService.shared.restorePurchases()
                            }
                        }
                        .font(AppFont.callout)
                        .disabled(StoreService.shared.isPurchasing)
                    }
                }
                .sectionAppear(index: 4)

                // データセクション
                Section("データ管理") {
                    Button(role: .destructive) {
                        vm.showResetConfirm = true
                    } label: {
                        Label("学習データをリセット", systemImage: "trash")
                    }
                }
                .sectionAppear(index: 5)

                // アプリ情報
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(vm.appVersion)
                            .foregroundStyle(AppColor.textTertiary)
                    }
                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text(vm.buildNumber)
                            .foregroundStyle(AppColor.textTertiary)
                    }
                    if let termsURL = URL(string: "https://msy-toyama.github.io/java-pro/terms.html") {
                    Link(destination: termsURL) {
                        HStack {
                            Label("利用規約", systemImage: "doc.text")
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
                            Label("プライバシーポリシー", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(AppColor.textTertiary)
                        }
                    }
                    }
                    // Oracle 商標免責事項
                    Text("「Java」および「Oracle」は Oracle Corporation の登録商標です。本アプリは Oracle Corporation とは無関係であり、認定・推奨を受けたものではありません。模擬試験はすべて独自作成の非公式問題です。")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColor.textTertiary)
                }
                .sectionAppear(index: 6)
            }
            .navigationTitle("設定")
            .onAppear { vm.loadSettings(modelContext: modelContext) }
            .onDisappear { vm.cancelVolumeSaveTask() }
            .alert("本当にリセットしますか？", isPresented: $vm.showResetConfirm) {
                Button("リセット", role: .destructive) {
                    vm.resetAllData(modelContext: modelContext)
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべての学習進捗・XP・バッジが削除されます。この操作は取り消せません。")
            }
            .alert("通知が許可されていません", isPresented: $vm.showPermissionDenied) {
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("閉じる", role: .cancel) {}
            } message: {
                Text("「設定」アプリから プロプロ の通知を許可してください。")
            }
            .sheet(isPresented: $vm.showPaywall) {
                PaywallView()
            }
            .alert("リセット完了", isPresented: $vm.showResetComplete) {
                Button("OK") {}
            } message: {
                Text("すべての学習データがリセットされました。")
            }
            .alert("リセットに失敗しました", isPresented: $vm.showResetError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("データの削除中にエラーが発生しました。アプリを再起動して再度お試しください。")
            }
        }
    }}