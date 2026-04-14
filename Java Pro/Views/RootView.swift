//
//  RootView.swift
//  Java Pro
//
//  アプリの最上位View。オンボーディング未完了ならオンボーディングを表示し、
//  完了済みならメインタブを表示する。ダークモード設定を反映する。
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasCompletedOnboarding = false
    @State private var isLoading = true
    @State private var showSaveError = false
    @State private var showContentLoadError = false
    @AppStorage("dataRecoveryMode") private var dataRecoveryMode = false
    /// フォアグラウンドに入った時刻（学習時間計測用）
    @State private var foregroundStartDate: Date?
    /// 60秒周期で学習時間を中間保存するタスク
    @State private var studyTimerTask: Task<Void, Never>?
    private var appearance = AppearanceManager.shared
    private var saveErrorNotifier = SaveErrorNotifier.shared
    private var lang = LanguageManager.shared

    var body: some View {
        Group {
            if isLoading {
                LaunchScreen()
            } else if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(onComplete: {
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                })
            }
        }
        .preferredColorScheme(appearance.colorSchemeOverride)
        .alert(lang.l("root.save_error_title"), isPresented: $showSaveError) {
            Button("OK") { saveErrorNotifier.clear() }
        } message: {
            Text(saveErrorNotifier.lastError ?? lang.l("root.save_error_message"))
        }
        .onChange(of: saveErrorNotifier.lastError) { _, newValue in
            showSaveError = newValue != nil
        }
        .alert(lang.l("root.load_error_title"), isPresented: $dataRecoveryMode) {
            Button("OK") { dataRecoveryMode = false }
        } message: {
            Text(lang.l("root.load_error_message"))
        }
        .alert(lang.l("root.content_error_title"), isPresented: $showContentLoadError) {
            Button("OK") { showContentLoadError = false }
        } message: {
            Text(ContentService.shared.loadError ?? lang.l("root.content_error_message"))
        }
        .task {
            let service = ProgressService(modelContext: modelContext)
            let settings = service.getSettings()
            hasCompletedOnboarding = settings.hasCompletedOnboarding

            // ダークモード設定を反映
            appearance.sync(from: settings.isDarkMode)

            // 効果音設定を反映
            SoundService.shared.isEnabled = settings.soundEnabled
            SoundService.shared.volume = Float(settings.soundVolume)

            // フォアグラウンド時刻を初期化
            foregroundStartDate = Date()

            // コンテンツ読み込み完了を待つ（非同期版で統一、二重ロード防止）
            if !ContentService.shared.isLoaded {
                await ContentService.shared.loadAllContentAsync()
            }

            // 実践演習データも早期ロード（HomeView経由でも演習リンクを表示するため）
            PracticeService.shared.loadPracticeData()

            // コンテンツ読み込みエラーがあればアラート表示
            if ContentService.shared.loadError != nil {
                showContentLoadError = true
            }

            // 初回起動時にリマインダーをスケジュール（デフォルトON）
            scheduleInitialReminderIfNeeded(settings: settings)

            try? await Task.sleep(for: .milliseconds(600))
            withAnimation {
                isLoading = false
            }

            // 初回起動時にも学習タイマーを開始する
            // （onChange(of: scenePhase) は初期値 .active からの変化がない場合トリガーされないため）
            startStudyTimer()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // フォアグラウンドに復帰 → 計測開始
                foregroundStartDate = Date()
                startStudyTimer()
                // 通知を再スケジュール（先7日分補充）
                refreshDailyReminderIfNeeded()
            case .background:
                // バックグラウンドへ → 残りの経過秒数を加算して保存
                stopStudyTimer()
                flushStudySeconds()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: LanguageManager.languageDidChangeNotification)) { _ in
            // 言語変更時に通知文面を新しい言語で再スケジュール
            refreshDailyReminderIfNeeded()
        }
    }

    // MARK: - 学習タイマー

    /// 60秒周期で学習秒数を UserDailyRecord に中間保存する。
    /// これによりフォアグラウンド中もホーム画面の「今日の目標」がリアルタイムに進む。
    /// ProgressService は軽量だがタイマー周期中は同一インスタンスを再利用する。
    private func startStudyTimer() {
        stopStudyTimer()
        let context = modelContext
        studyTimerTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard !Task.isCancelled else { break }
                let service = ProgressService(modelContext: context)
                flushStudySeconds(service: service)
            }
        }
    }

    /// タイマータスクをキャンセルする。
    private func stopStudyTimer() {
        studyTimerTask?.cancel()
        studyTimerTask = nil
    }

    /// foregroundStartDate からの経過秒数を加算し、起点時刻を現在にリセットする。
    private func flushStudySeconds(service: ProgressService? = nil) {
        guard let start = foregroundStartDate else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        if elapsed > 0 {
            let svc = service ?? ProgressService(modelContext: modelContext)
            svc.addStudySeconds(elapsed)
        }
        foregroundStartDate = Date()
    }

    /// 通知が有効なら先7日分のリマインドを再スケジュールする。
    private func refreshDailyReminderIfNeeded() {
        let service = ProgressService(modelContext: modelContext)
        let settings = service.getSettings()
        guard settings.notificationsEnabled else { return }
        let strings = LanguageManager.shared.notificationStrings()
        NotificationService.shared.scheduleDailyReminder(
            hour: settings.reminderHour,
            minute: settings.reminderMinute,
            title: strings.title,
            bodies: strings.bodies
        )
    }

    /// 初回起動時に通知権限をリクエストし、リマインダーをスケジュールする。
    /// View は @MainActor なので Task {} も MainActor を継承する。
    /// ※ オンボーディング未完了時はスキップ（GoalSettingPage で許可を取得するため）
    private func scheduleInitialReminderIfNeeded(settings: AppSettings) {
        guard settings.hasCompletedOnboarding else { return }
        guard settings.notificationsEnabled else { return }
        let key = "hasScheduledInitialReminder"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            if granted {
                let strings = LanguageManager.shared.notificationStrings()
                NotificationService.shared.scheduleDailyReminder(
                    hour: settings.reminderHour,
                    minute: settings.reminderMinute,
                    title: strings.title,
                    bodies: strings.bodies
                )
            } else {
                // 権限拒否されたらOFFにする
                settings.notificationsEnabled = false
                try? modelContext.save()
            }
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}

// MARK: - 起動画面

private struct LaunchScreen: View {
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.6
    @State private var ringOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var subtitleOpacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var lang = LanguageManager.shared

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    AppColor.primaryDark,
                    AppColor.primary,
                    Color(hex: "2563EB")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // フローティングパーティクル（軽量化: 15個 + 低フレームレート）
            FloatingParticlesView(count: 15, color: .white.opacity(0.6))
                .ignoresSafeArea()

            VStack(spacing: AppLayout.paddingMD) {
                // パルスリング + アイコン
                ZStack {
                    // 外側パルスリング
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.white.opacity(0.0), .white.opacity(0.4), .white.opacity(0.0)],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .rotationEffect(.degrees(ringRotation))

                    // 内側グロー
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 100, height: 100)
                        .scaleEffect(iconScale)
                        .blur(radius: 2)

                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                }

                Text(lang.l("root.launch_title"))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(textOpacity)

                Text(lang.l("root.launch_subtitle"))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            guard !reduceMotion else {
                iconScale = 1.0; iconOpacity = 1; textOpacity = 1
                subtitleOpacity = 1; ringScale = 1.0; ringOpacity = 1
                return
            }
            // ステージ1: アイコン登場
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            // ステージ2: リング展開 + 回転
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.2)) {
                ringRotation = 360
            }
            // ステージ3: テキスト登場
            withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
                textOpacity = 1.0
            }
            // ステージ4: サブタイトル
            withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
                subtitleOpacity = 1.0
            }
        }
    }
}
