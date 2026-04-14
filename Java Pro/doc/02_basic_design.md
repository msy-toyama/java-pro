# プロプロ（プログラミングのプロになる -Java入門-）— 基本設計書

| 項目 | 内容 |
|---|---|
| ドキュメントID | BD-001 |
| バージョン | 2.1.0 |
| 作成日 | 2026-04-08 |
| 最終更新日 | 2026-04-14 |
| 対応要件定義 | REQ-001 v2.1.0 |
| ステータス | リリース版 |

---

## 1. システム概要

### 1.1 アーキテクチャ概要

プロプロ（プログラミングのプロになる -Java入門-）は **MVVM ベース + Service 層**のアーキテクチャを採用する。MVVM（Model-View-ViewModel）とは、データ（Model）・画面表示（View）・画面ロジック（ViewModel）を分離する設計パターンであり、コードの保守性とテスト容易性を高める。SwiftUI がビュー層、SwiftData がデータ永続化層を担い、14 個のサービスクラスがビジネスロジックを集約する。ViewModel はビュー固有の状態管理とサービス呼び出しを担当する。

| レイヤー | 役割 | 主要コンポーネント |
|---|---|---|
| **View 層** | UI 表示・ユーザー操作受付 | 30 Views + 7 Components（計 37 ファイル） |
| **ViewModel 層** | ビュー固有の状態管理・ビジネスロジック呼び出し | 4 個の ViewModel クラス |
| **Service 層** | ビジネスロジック・データ操作 | 15 個の Service クラス |
| **Model 層** | データ定義・永続化 | 8 個の SwiftData @Model + 17 個のコンテンツ構造体 + 5 個の実践演習構造体 |
| **Theme 層** | デザイントークン管理 | AppColor / AppFont / AppLayout / AppAnimation + アニメーション + コンポーネント（計 3 ファイル） |
| **Extension 層** | ヘルパーメソッド | DateExtensions + ModelContextExtensions（計 2 ファイル） |
| **Resource 層** | 静的コンテンツ | 92 個の JSON ファイル（日英各 46）+ Assets.xcassets |

### 1.2 技術スタック

| 項目 | 技術 |
|---|---|
| 言語 | Swift 6（Strict Concurrency） |
| UI フレームワーク | SwiftUI |
| データ永続化 | SwiftData（VersionedSchema V1→V2 + MigrationPlan） |
| 課金 | StoreKit 2（サーバーレス検証） |
| 通知 | UserNotifications（ローカル通知） |
| オーディオ | AudioToolbox（システムサウンド） |
| ログ | os.Logger（AppLogger: 8 カテゴリ） |
| 診断 | MetricKit（CrashReportService: MXMetricManagerSubscriber） |
| テスト | Swift Testing フレームワーク（89 テスト / 10 スイート） |
| 最低 OS | iOS 18.0 / iPadOS 18.0 |
| ビルドツール | Xcode 16+ |

---

## 2. システム構成

### 2.1 ディレクトリ構成

```
Java Pro/
├── Java_StepApp.swift            # アプリエントリポイント (@main)
│
├── Models/
│   ├── ContentModels.swift         # コンテンツ用 Codable 構造体 (17 型)
│   ├── PracticeModels.swift        # 実践演習用 Codable 構造体 (5 型)
│   ├── UserModels.swift            # SwiftData @Model クラス (8 クラス)
│   └── JavaStepSchemaVersions.swift  # VersionedSchema V1/V2 + MigrationPlan
│
├── ViewModels/
│   ├── HomeViewModel.swift            # ホーム画面の状態管理
│   ├── QuizViewModel.swift            # クイズ画面のロジック
│   ├── ExamSimulatorViewModel.swift   # 模擬試験のロジック
│   └── SettingsViewModel.swift        # 設定画面の状態管理
│
├── Services/
│   ├── ContentService.swift          # コンテンツ JSON 読み込み・キャッシュ
│   ├── PracticeService.swift         # 実践演習 JSON 読み込み・キャッシュ
│   ├── ProgressService.swift         # 学習進捗管理・学習時間計測
│   ├── GamificationService.swift     # XP・レベル・バッジ
│   ├── ExamService.swift             # 模擬試験管理
│   ├── StoreService.swift            # アプリ内課金 (StoreKit 2)
│   ├── ReviewService.swift           # 間隔反復・復習キュー
│   ├── AnalyticsService.swift        # 学習分析・統計
│   ├── NotificationService.swift     # ローカル通知
│   ├── SoundService.swift            # 効果音再生
│   ├── AppearanceManager.swift       # ダーク/ライトモード管理
│   ├── SaveErrorNotifier.swift       # データ保存エラー通知
│   ├── AppLogger.swift               # os.Logger ラッパー (8 カテゴリ)
│   ├── LanguageManager.swift         # 日英言語切替管理
│   └── CrashReportService.swift      # MetricKit クラッシュ診断
│
├── Views/
│   ├── RootView.swift                # ルート分岐 (起動/オンボーディング/メイン)
│   ├── MainTabView.swift             # 4 タブナビゲーション
│   ├── HomeView.swift                # ホームダッシュボード
│   ├── CourseListView.swift          # コース一覧 + 実践演習切替
│   ├── LessonListView.swift          # レッスン一覧
│   ├── LessonDetailView.swift        # レッスン詳細
│   ├── QuizView.swift                # クイズ画面 (8 種対応)
│   ├── QuizAnswerViews.swift         # クイズ回答 UI パーツ
│   ├── QuizChoiceStyle.swift         # 選択肢スタイル
│   ├── QuizResultView.swift          # クイズ結果画面
│   ├── CodeExecutionView.swift       # コード実行結果表示
│   ├── CertificationView.swift       # 試験対策ダッシュボード
│   ├── ExamSimulatorView.swift       # 模擬試験画面
│   ├── ExamResultView.swift          # 試験結果
│   ├── ExamReviewView.swift          # 試験復習
│   ├── ExamHistoryView.swift         # 試験履歴
│   ├── WeakPointView.swift           # 弱点分析
│   ├── ReviewView.swift              # 復習画面
│   ├── PracticeListView.swift        # 実践演習一覧
│   ├── PracticeDetailView.swift      # 実践演習詳細
│   ├── EnvironmentSetupView.swift    # 環境構築ガイド目次
│   ├── EnvironmentSetupDetailView.swift  # 環境構築ガイド詳細
│   ├── GlossaryView.swift            # 用語辞典
│   ├── ProfileView.swift             # マイページ
│   ├── SettingsView.swift            # 設定
│   ├── BadgeListView.swift           # バッジ一覧
│   ├── PaywallView.swift             # 課金画面
│   ├── OnboardingView.swift          # オンボーディング
│   ├── GuideTourView.swift           # ガイドツアーオーバーレイ
│   ├── PreviewHelpers.swift          # SwiftUI Preview 用ヘルパー
│   └── Components/
│       ├── ConfettiView.swift          # 紙吹雪エフェクト
│       ├── LevelUpOverlayView.swift    # レベルアップ演出
│       ├── CodeBlockView.swift         # コードブロック表示
│       ├── JavaSyntaxHighlighter.swift # Java シンタックスハイライト
│       ├── GlossaryPopupView.swift     # 用語ポップアップ表示
│       ├── RichBodyView.swift          # リッチテキスト表示
│       └── SectionView.swift          # レッスンセクション表示
│
├── Theme/
│   ├── Theme.swift                   # デザイントークン (AppColor/AppFont/AppLayout/AppAnimation)
│   ├── ThemeAnimations.swift         # アニメーション ViewModifier 群
│   └── ThemeComponents.swift         # 共通 UI コンポーネント
│
├── Extensions/
│   ├── DateExtensions.swift          # Date ヘルパー
│   └── ModelContextExtensions.swift  # ModelContext ログ付きフェッチ
│
├── Resources/
│   ├── courses_index.json / courses_index_en.json           # コースインデックス (34 コース)
│   ├── ch01_introduction.json ... (34 ファイル)  # チャプターコンテンツ（日本語）
│   ├── ch01_introduction_en.json ... (34 ファイル)  # チャプターコンテンツ（英語）
│   ├── exam_questions_*.json (8 ファイル)   # 模擬試験問題（日本語・計 640 問）
│   ├── exam_questions_*_en.json (8 ファイル) # 模擬試験問題（英語）
│   ├── glossary.json / glossary_en.json                    # 用語集 (202 語)
│   ├── practice_exercises.json / practice_exercises_en.json # 実践演習 (39ch・108問 + 環境構築ガイド)
│   └── strings_ja.json / strings_en.json                   # UI 文字列辞書
│
└── Tests/
    ├── Java_ProTests.swift              # ユニットテスト (89 テスト / 10 スイート)
    ├── Java_ProUITests.swift            # UI テスト (テンプレート)
    └── Java_ProUITestsLaunchTests.swift # 起動テスト (テンプレート)
```

### 2.2 サービス設計方針

| 方針 | 説明 |
|---|---|
| **シングルトンパターン** | 状態を持たない・グローバル参照が必要なサービスに使用（ContentService, PracticeService, StoreService, SoundService, AppearanceManager, SaveErrorNotifier, NotificationService, AppLogger, CrashReportService, LanguageManager） |
| **DI パターン** | ModelContext 依存サービスは `init(modelContext:)` で注入（ProgressService, GamificationService, ExamService, ReviewService, AnalyticsService） |
| **@Observable** | SwiftUI の状態監視に `@Observable` マクロを採用（Combine 不使用）。※ NotificationService (`Sendable`) と SoundService (`@MainActor` のみ) は `@Observable` 非適用 |
| **@MainActor** | UI 関連サービスは全て `@MainActor` で実行（NotificationService は `Sendable`、CrashReportService は `@unchecked Sendable`） |
| **エラー通知** | `SaveErrorNotifier.shared` を介した集約エラー報告 |
| **構造化ログ** | `AppLogger` の 8 カテゴリで `os.Logger` を統一使用（print 文不使用） |

---

## 3. 画面設計

### 3.1 画面遷移図

```
アプリ起動
    │
    ▼
┌──────────────┐
│  LaunchScreen │ (600ms ロードアニメーション + パーティクル)
└──────┬───────┘
       │
       ├── 初回起動 ──────────────────────┐
       │                                  ▼
       │                         ┌─────────────────┐
       │                         │ OnboardingView   │ (5 ページ)
       │                         │ ① Welcome        │
       │                         │ ② レッスンデモ    │
       │                         │ ③ クイズデモ      │
       │                         │ ④ 復習説明        │
       │                         │ ⑤ 目標設定        │
       │                         └────────┬────────┘
       │                                  │
       ▼                                  ▼
┌──────────────────────────────────────────────────┐
│                  MainTabView (4 タブ)             │
├──────────┬───────────┬──────────────┬─────────────┤
│  ホーム   │   学習     │  試験対策    │  マイページ  │
│ house.fill│ book.fill │graduationcap│person.crop  │
│           │           │    .fill    │.circle.fill │
└──────────┴───────────┴──────────────┴─────────────┘
       │
       └── 各タブ初回表示時 → GuideTourView (オーバーレイ)
```

### 3.2 タブ別画面構成

#### タブ 1: ホーム (HomeView)

```
HomeView (+ HomeViewModel)
├── GuideTourView (初回のみ: 5 ステップ)
├── レベルカード (レベル / XP / 称号 / 進捗バー / 今日のXP)
├── ストリークカード (連続学習日数 / メッセージ)
├── 今日の統計カード (レッスン / クイズ / XP)
├── 目標達成度プログレスバー
├── おすすめレッスンカード
│   └── tap → LessonDetailView
├── 最近のバッジ (最新 4 件)
│   └── 「すべて見る」tap → switchToTab(.mypage)
├── 復習リマインダーバー
│   └── tap → switchToTab(.exam)
└── 進捗サマリーカード (全体の完了率バー)
```

#### タブ 2: 学習 (CourseListView)

```
CourseListView
├── GuideTourView (初回のみ: 4 ステップ)
├── セグメント切替: 教材学習 / 実践演習
│
├── [教材学習モード]
│   ├── セクション: 無料コンテンツ (ch01-ch08)
│   │   └── コースカード × 8
│   ├── セクション: Silver 対策
│   │   └── コースカード × 9 [🔒 ロック表示]
│   ├── セクション: Gold 対策
│   │   └── コースカード × 17 [🔒 ロック表示]
│   ├── 各コースカード tap →
│   │   └── LessonListView
│   │       └── 各レッスン tap →
│   │           └── LessonDetailView
│   │               ├── セクション表示 (SectionView × 5 種)
│   │               │   └── RichBodyView + CodeBlockView
│   │               ├── 「クイズに挑戦」ボタン →
│   │               │   └── QuizView (sheet) → QuizResultView
│   │               │       └── CodeExecutionView (クイズ結果内)
│   │               └── 「次のレッスンへ」→ LessonDetailView
│   └── NavigationLink →
│       └── GlossaryView
│           └── 検索 + 50 音グループ → GlossaryDetailSheet
│
└── [実践演習モード]
    ├── GuideTourView (初回のみ: 4 ステップ)
    ├── 環境構築ガイドカード →
    │   └── EnvironmentSetupView (5 セクション目次)
    │       └── EnvironmentSetupDetailView (ステップ表示)
    └── カテゴリ別コラプシブルセクション (9 カテゴリ)
        └── 各チャプター tap →
            └── PracticeDetailView
                ├── 演習カード (アコーディオン)
                │   ├── 問題文 (RichBodyView)
                │   ├── 期待出力 (CodeBlockView)
                │   ├── ヒント (DisclosureGroup)
                │   └── 解答セクション
                │       ├── 解答コード (JavaSyntaxHighlighter)
                │       ├── 解答解説
                │       └── .java ファイル ShareLink
                └── PaywallView (有料コンテンツ時)
```

#### タブ 3: 試験対策 (CertificationView)

```
CertificationView
├── GuideTourView (初回のみ: 5 ステップ)
├── 資格切替セグメント (SE11 Silver / SE11 Gold / SE17 Silver / SE17 Gold)
├── 進捗概要カード (レッスン完了率 / クイズ正答率 / 推定合格率)
├── 模擬試験セクション
│   └── 試験カード × 2 (各資格) →
│       └── ExamSimulatorView (fullScreenCover) + ExamSimulatorViewModel
│           ├── 問題表示 (4 択 + フラグ + スライドトランジション)
│           ├── QuestionListSheet (sheet — 一覧パネル)
│           ├── カウントダウンタイマー
│           └── 提出 →
│               └── ExamResultView
│                   ├── スコア表示 (合格/不合格)
│                   ├── トピック別正答率グラフ
│                   ├── ConfettiView (合格時)
│                   └── ExamReviewView (fullScreenCover — 全問復習)
├── NavigationLink →
│   └── ExamHistoryView (スコア推移チャート)
├── NavigationLink →
│   └── WeakPointView (弱点トピック一覧)
└── NavigationLink →
    └── ReviewView (間隔反復) →
        └── QuizView (sheet — 復習モード)
```

#### タブ 4: マイページ (ProfileView)

```
ProfileView
├── プロフィールカード (レベル / XP / 称号 / 進捗バー)
├── LevelUpOverlayView (レベルアップ時 fullScreenCover)
├── スタッツカード (総レッスン / 正答数 / 学習時間 / ストリーク)
├── 週間学習グラフ (直近 7 日)
├── 獲得バッジ (全件グリッド表示)
│   └── 「すべて見る」tap → BadgeListView (32 種バッジ一覧)
├── 未獲得バッジ (ロックアイコン表示)
└── NavigationLink →
    └── SettingsView (+ SettingsViewModel)
        ├── プランセクション (フルアクセス購入 / リストア)
        ├── 外観 (ダークモード切替)
        ├── 学習目標 (1 日の分数設定)
        ├── 通知 (リマインダー ON/OFF + 時間設定)
        ├── フィードバック (触覚 / 効果音 / 音量スライダー)
        ├── データ管理 (全データリセット)
        ├── アプリ情報 (バージョン / ライセンス)
        └── PaywallView (sheet)
```

---

## 4. データ設計

### 4.1 データモデル概要

本アプリは SwiftData を永続化層として使用し、VersionedSchema / MigrationPlan で将来のスキーマ変更に対応する。

#### スキーマ定義

| 項目 | V1 | V2 (現行) |
|---|---|---|
| バージョン | `Schema.Version(1, 0, 0)` | `Schema.Version(1, 1, 0)` |
| ストア名 | `"JavaProStore"` | `"JavaProStore"` |
| ストレージ | SQLite / フォールバック: インメモリ | 同左 |
| マイグレーション | — | **lightweight**（新規フィールドにデフォルト値） |

**V2 で追加されたフィールド:**
- `UserDailyRecord.studySeconds: Int` (デフォルト `0`) — 学習秒数追跡
- `AppSettings.soundVolume: Double` (デフォルト `0.7`) — 効果音音量

#### モデルクラス一覧

| モデル | ユニーク制約 | 役割 |
|---|---|---|
| `UserLessonProgress` | `lessonId` | レッスンごとの進捗状態 |
| `UserQuizHistory` | `id` (UUID) | クイズ回答履歴（間隔反復ステージ含む） |
| `UserDailyRecord` | `dateString` | 日ごとの学習統計 |
| `AppSettings` | `id` (固定値) | アプリ設定（シングルトン行） |
| `UserXPRecord` | `id` (UUID) | XP 獲得トランザクション |
| `UserBadge` | `badgeId` | 獲得済みバッジ |
| `UserLevel` | `id` (固定値) | ユーザーレベル（シングルトン行） |
| `UserExamResult` | `id` (UUID) | 模擬試験結果 |

### 4.2 ER 図（論理）

```
UserLessonProgress        UserQuizHistory           UserDailyRecord
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ lessonId (PK)    │     │ id (PK, UUID)    │     │ dateString (PK)  │
│ statusRaw        │     │ quizId           │     │ completedLessons │
│ startedAt        │     │ answeredAt       │     │ completedQuizzes │
│ completedAt      │     │ isCorrect        │     │ earnedXP         │
└──────────────────┘     │ streakCount      │     │ studySeconds ★V2 │
                         │ intervalStage    │     └──────────────────┘
                         └──────────────────┘

AppSettings (1行)         UserXPRecord              UserLevel (1行)
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ id (PK, 固定)    │     │ id (PK, UUID)    │     │ id (PK, 固定)    │
│ notifications... │     │ amount           │     │ level            │
│ adRemoved        │     │ reason           │     │ totalXP          │
│ reminderHour/Min │     │ earnedAt         │     │ lastLevelUpAt    │
│ hasCompleted...  │     │ relatedId        │     └──────────────────┘
│ isDarkMode       │     └──────────────────┘
│ selectedCert...  │
│ dailyGoalMinutes │     UserBadge                 UserExamResult
│ hapticFeedback.. │     ┌──────────────────┐     ┌──────────────────┐
│ soundEnabled     │     │ badgeId (PK)     │     │ id (PK, UUID)    │
│ soundVolume ★V2  │     │ name             │     │ examChapterId    │
└──────────────────┘     │ badgeDescription │     │ score            │
                         │ iconName         │     │ totalQuestions   │
                         │ colorHex         │     │ timeSpentSeconds │
                         │ earnedAt         │     │ passed           │
                         └──────────────────┘     │ completedAt      │
                                                  │ topicScoresJSON  │
                                                  └──────────────────┘
```

> **注記**: SwiftData の `@Relationship` は使用していない。モデル間は `lessonId` / `quizId` / `examChapterId` 等の文字列 ID で論理的に紐づけている。

### 4.3 コンテンツデータ構造

コンテンツは全てバンドル内 JSON で管理され、`ContentService` と `PracticeService` が起動時にメモリ上のインデックスへ展開する。

```
courses_index.json
    ├── CourseIndex (34 件)
    │   └── fileName → <fileName>.json (e.g. ch01_introduction.json)
    │
<fileName>.json (34 ファイル)
    ├── ChapterContent
    │   └── lessons: [LessonData] (合計 169 件)
    │       ├── contents: [LessonSection]
    │       └── quizzes: [QuizData] (合計 575 問)
    │
exam_questions_{examId}.json (8 ファイル)
    └── [QuizData] (各 80 問 = 合計 640 問)

glossary.json
    └── [GlossaryEntry] (202 語)

practice_exercises.json / practice_exercises_en.json
    └── PracticeData
        ├── setupGuide: [SetupGuideSection] (5 セクション)
        │   └── steps: [SetupStep]
        └── chapters: [PracticeChapter] (39 チャプター)
            └── exercises: [PracticeExercise] (合計 108 問)

strings_ja.json / strings_en.json
    └── { "key": "翻訳テキスト" } (UI 文字列辞書)
```

> **多言語設計**: 全コンテンツ JSON は日本語版（`*.json`）と英語版（`*_en.json`）のペアで管理される。`LanguageManager.shared.currentLanguage` に応じて `ContentService` / `PracticeService` がロードするファイル名にサフィックス `_en` を付与する。

---

## 5. サービス層設計

### 5.1 サービス依存関係

```
                    ┌────────────────────┐     ┌────────────────────┐
                    │   ContentService   │     │  PracticeService   │
                    │  (Singleton)       │     │  (Singleton)       │
                    │  JSON → メモリ Cache│     │  JSON → メモリ Cache│
                    └───────┬────────────┘     └────────────────────┘
                            │ 参照
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
│ProgressService│  │ReviewService │  │AnalyticsService  │
│ (DI: Context) │  │ (DI: Context)│  │ (DI: Context)    │
└──────┬───────┘  └──────────────┘  └──────────────────┘
       │ 参照
       ▼
┌──────────────┐
│Gamification  │
│Service       │
│ (DI: Context)│
└──────────────┘

┌──────────────┐     ┌──────────────────────┐
│ ExamService  │     │   SaveErrorNotifier   │ (Singleton)
│ (DI: Context)│     │ ← Progress/Gamification/Exam が報告 │
└──────────────┘     └──────────────────────┘

┌──────────────┐  ┌───────────────┐  ┌───────────────┐
│ StoreService │  │AppearanceManager│ │SoundService   │
│ (Singleton)  │  │ (Singleton)    │  │ (Singleton)   │
│  StoreKit 2  │  │ ColorScheme    │  │ AudioToolbox  │
└──────────────┘  └────────────────┘  └───────────────┘

┌────────────────────┐  ┌───────────────┐  ┌──────────────────┐
│NotificationService │  │   AppLogger   │  │CrashReportService│
│ (Singleton,Sendable)│  │  (os.Logger)  │  │ (MetricKit)      │
└────────────────────┘  └───────────────┘  └──────────────────┘

┌────────────────────┐
│ LanguageManager    │
│ (Singleton)        │
│ 日英言語切替          │
└────────────────────┘
```

### 5.2 サービス初期化フロー

```
Java_ProApp.init()
    │
    ├── 1. ModelContainer 生成 (JavaProSchemaV2 + JavaProMigrationPlan)
    │      ├── テスト環境: 空 Schema のインメモリコンテナ (XCTest 検出時)
    │      ├── 正常: SQLite ストア使用
    │      ├── DEBUG 失敗1: ストア削除 → リトライ
    │      ├── DEBUG 失敗2: インメモリモード
    │      ├── DEBUG 失敗3: 空スキーマモード
    │      ├── RELEASE 失敗1: インメモリモード (dataRecoveryMode フラグ設定)
    │      └── RELEASE 失敗2: 空スキーマモード
    │
    ├── 2. 起動時バックグラウンドタスク
    │      ├── CrashReportService.shared.start()  ← MetricKit 登録
    │      └── ContentService.shared.loadAllContentAsync()  ← JSON 先行ロード
    │
    └── 3. RootView 表示
           └── .task {
               ├── ProgressService.init(modelContext:)
               ├── AppSettings ロード / 作成
               ├── AppearanceManager.sync(from: settings.isDarkMode)
               ├── SoundService.shared — 効果音設定・音量反映
               ├── LanguageManager.shared — 言語設定反映
               ├── ContentService.shared.loadAllContentAsync()  ← await 完了待ち
               ├── PracticeService.shared.loadPracticeData()  ← 実践演習ロード
               ├── エラーチェック → アラート表示
               ├── NotificationService — 初回リマインダースケジュール
               └── 600ms sleep → isLoading = false → メイン画面表示
           }
           └── scenePhase 監視
               ├── .active: 学習タイマー開始 (Task + Task.sleep) + 通知再スケジュール
               └── .background: タイマー停止 (Task.cancel) + 学習秒数 flush
```

### 5.3 コンテンツ読み込み設計

`ContentService` はバンドル JSON を非同期でパースし、2 フェーズのインデックスを構築する。

```
loadAllContentAsync()
    │
    ├── Phase 1: コースインデックス先行ロード
    │   └── courses_index.json → [CourseIndex] → @MainActor 反映
    │       └── isCourseIndexLoaded = true (UI は即座にコース一覧表示可能)
    │
    └── Phase 2: チャプター・用語集バックグラウンドロード
        └── Task.detached (バックグラウンドスレッド)
            ├── 各 CourseIndex.fileName → <fileName>.json → ChapterContent
            ├── ファイル I/O はバックグラウンド、デコードはメインスレッド
            └── glossary.json → [GlossaryEntry]
        └── @MainActor (メインスレッド)
            ├── chapters = [courseId: ChapterContent]
            ├── lessonsIndex = [lessonId: LessonData]  ← フラットインデックス
            ├── quizzesIndex = [quizId: QuizData]       ← フラットインデックス
            ├── glossary = [GlossaryEntry]
            └── isLoaded = true
```

### 5.4 課金システム設計

```
StoreService (StoreKit 2)
    │
    ├── 商品: com.javapro.fullaccess (Non-Consumable / 買い切り ¥480)
    │
    ├── purchase(_:)
    │   ├── Product.purchase() 呼び出し
    │   ├── VerificationResult で署名検証
    │   ├── .verified → fullAccessUnlocked = true
    │   └── Transaction.finish() で完了通知
    │
    ├── Transaction.updates 監視 (listenForTransactions)
    │   └── バックグラウンドで購入状態の変更を検知
    │
    ├── refreshPurchaseStatus()
    │   └── Transaction.currentEntitlements で保有確認
    │
    ├── canAccess(courseId:, certLevel:)
    │   ├── beginner / none → true (無料)
    │   └── silver / gold → isPremium
    │
    ├── canAccessExam(examId:)
    │   ├── "se11_silver_1" → true (無料)
    │   └── その他 → isPremium
    │
    └── debugUnlockAll (#if DEBUG → true)
        └── DEBUG ビルド時に全機能解放
```

---

## 6. ゲーミフィケーション設計

### 6.1 XP システム

| アクション | XP | 条件 | 備考 |
|---|---|---|---|
| クイズ正解 | 10 | 毎回 | — |
| 復習正解 | 15 | 毎回 | — |
| レッスン完了 | 20 | 初回のみ | — |
| 全問正解ボーナス | 20 | 初回のみ | — |
| 初回正解ボーナス | 5 | 各クイズ初回のみ | 定義済みだが現在未使用 |
| ストリークボーナス | 5 × 日数 | 1 日 1 回 | — |
| 模擬試験合格 | 500 | 初回のみ | ExamSimulatorViewModel で付与 |

### 6.2 レベル計算式

$$XP_{required}(Lv) = \lfloor Lv^2 \times 12.24 \rfloor$$

| レベル | 必要 XP | レベル | 必要 XP |
|---|---|---|---|
| Lv 5 | 306 | Lv 30 | 11,016 |
| Lv 10 | 1,224 | Lv 40 | 19,584 |
| Lv 20 | 4,896 | Lv 50 | 30,600 |

### 6.3 レベル称号一覧 (21 段階)

| Lv | 称号 | Lv | 称号 |
|---|---|---|---|
| 1 | Java 見習い | 28 | API 探求者 |
| 3 | Hello Worlder | 30 | ラムダ使い |
| 5 | コード初心者 | 33 | Stream マスター |
| 8 | 配列探検家 | 35 | 並行処理者 |
| 10 | 変数マスター | 38 | Gold 挑戦者 |
| 13 | メソッド使い | 40 | モジュール設計士 |
| 15 | ループ使い | 43 | アーキテクト |
| 18 | クラス設計士 | 45 | Java 賢者 |
| 20 | オブジェクト職人 | 48 | 伝説のコーダー |
| 23 | 例外ハンドラー | 50 | Java マスター |
| 25 | Silver 挑戦者 | | |

### 6.4 バッジ設計 (32 種)

| カテゴリ | バッジ数 | 主要バッジ |
|---|---|---|
| 学習系 | 8 | first_lesson, lesson_10, lesson_25, lesson_50, lesson_100, all_ch01, oop_master, all_lessons |
| クイズ系 | 9 | quiz_10, quiz_50, quiz_100, quiz_200, quiz_500, perfect_3, perfect_10, speed_demon, error_finder |
| ストリーク系 | 7 | streak_3, streak_7, streak_14, streak_30, streak_50, streak_100, streak_365 |
| 資格系 | 4 | silver_ready, silver_pass, gold_ready, gold_pass |
| XP 系 | 4 | xp_1000, xp_5000, xp_10000, xp_30000 |

### 6.5 間隔反復アルゴリズム

```
                    正解
    Stage 0 ──────────→ Stage 1 ──────────→ Stage 2 ──────────→ Stage 3 ──────────→ Stage 4
   (即時復習)   +24h    (24h後)    +3日     (3日後)    +7日     (7日後)              (完了)
       ▲                  │                  │                  │
       │         誤答     │         誤答     │        誤答      │
       └──────────────────┴──────────────────┴──────────────────┘
                    Stage 0 にリセット
```

---

## 7. セキュリティ設計

### 7.1 課金セキュリティ

| 対策 | 実装 |
|---|---|
| トランザクション署名検証 | StoreKit 2 の `VerificationResult.verified` で Apple 署名を確認 |
| 購入状態復元 | `Transaction.currentEntitlements` でデバイス変更後も購入状態を復元 |
| バックグラウンド監視 | `Transaction.updates` で未完了トランザクションを自動処理 |
| デバッグ分離 | `#if DEBUG` コンパイルフラグでテスト用全解放を制御 |

### 7.2 データ保護

| 対策 | 実装 |
|---|---|
| ローカルストレージ | SwiftData (SQLite) で iOS データ保護を継承 |
| サーバー通信なし | 全データがオフラインで完結。ネットワーク通信は StoreKit のみ |
| 個人情報不保持 | ユーザー名・メールアドレス等の個人情報を一切収集しない |

---

## 8. エラーハンドリング設計

### 8.1 ModelContainer 初期化

```
テスト環境判定 (XCTestConfigurationFilePath):
    → 空 Schema のインメモリコンテナで起動

DEBUG:
    試行 1: 通常初期化 (SQLite)
        ├── 成功 → 正常起動
        └── 失敗 → 試行 2: ストアファイル削除 → 再初期化
            ├── 成功 → データリセットで起動
            └── 失敗 → 試行 3: インメモリモード
                ├── 成功 → データ非永続で起動
                └── 失敗 → 試行 4: 空スキーマモード

RELEASE:
    試行 1: 通常初期化 (SQLite)
        ├── 成功 → 正常起動
        └── 失敗 → 試行 2: インメモリモード (dataRecoveryMode = true)
            ├── 成功 → データ復旧モードアラート表示
            └── 失敗 → 試行 3: 空スキーマモード
```

### 8.2 SaveErrorNotifier パターン

```
ProgressService / GamificationService / ExamService
    │
    ├── modelContext.save() 呼び出し
    ├── catch → SaveErrorNotifier.shared.report(error)
    │
    └── RootView
        └── .alert(isPresented: $notifier.lastError != nil)
            └── "データの保存に失敗しました" 表示
```

### 8.3 構造化ログ (AppLogger)

| カテゴリ | 用途 |
|---|---|
| `swiftData` | ModelContext フェッチ・保存エラー |
| `store` | StoreKit 2 購入・復元 |
| `content` | JSON パース・ロード |
| `notification` | 通知許可・スケジュール |
| `gamification` | XP・バッジ・レベル |
| `sound` | 効果音再生 |
| `viewModel` | ViewModel ロジック |
| `app` | アプリライフサイクル |

---

## 9. パフォーマンス設計

| 対策 | 説明 |
|---|---|
| 2 フェーズ非同期ロード | Phase 1 でコースインデックスを先行表示、Phase 2 でチャプター詳細をバックグラウンドロード |
| フラットインデックス | `lessonsIndex` / `quizzesIndex` による O(1) 辞書アクセス |
| 遅延初期化 | Service は View が `.task` で初期化。起動時の即時ロード負荷を軽減 |
| N+1 回避 | `weeklyStudyData()` で日次レコードを一括取得。個別クエリを排除 |
| 起動画面 | `LaunchScreen` (600ms) で Content ロード完了を待機し、白画面を防止 |
| ViewModel デバウンス | `HomeViewModel.refreshIfNeeded()` は 3 秒デバウンスで過剰更新を抑制 |
| ログ付きフェッチ | `ModelContextExtensions` で fetch 失敗を `AppLogger` に記録し、空配列を返却 |

---

## 10. アクセシビリティ設計

| 対策 | 実装 |
|---|---|
| ダークモード | `AppearanceManager` による 3 モード切替（ライト / ダーク / システム） |
| Reduce Motion | `@Environment(\.accessibilityReduceMotion)` で全アニメーション制御 |
| VoiceOver | `accessibilityLabel` / `accessibilityHidden` の適切な設定 |
| 触覚フィードバック | `hapticFeedbackEnabled` 設定で ON/OFF 切替可能 |
| 効果音 | `soundEnabled` + `soundVolume` で ON/OFF + 音量調整 |
| コントラスト | `AppColor` のセマンティックカラーで WCAG AA 準拠を目指す |

---

## 11. 通知設計

### 11.1 ローカル通知

| 項目 | 仕様 |
|---|---|
| 種別 | ローカル通知（プッシュ通知サーバー不要） |
| 識別子 | `"daily_reminder"` |
| トリガー | `UNCalendarNotificationTrigger` (毎日リピート) |
| デフォルト時刻 | 20:00 |
| タイトル | `"今日もJavaを学ぼう 📚"` |
| 本文 | 6 パターンからランダム選択 |

---

## 12. テスト設計

### 12.1 テストフレームワーク

| 項目 | 仕様 |
|---|---|
| フレームワーク | Swift Testing (`@Test`, `@Suite`, `#expect`) |
| テスト総数 | 89 テスト |
| テストスイート | 10 スイート |
| テストデータ | `TestDatabase` enum による共有インメモリコンテナ（プロセス内単一） |

### 12.2 テストスイート一覧

| Suite | テスト数 | テスト対象 |
|---|---|---|
| ContentModels | 7 | CertificationLevel / QuizType / CourseIndex / QuizChoice JSON デコード |
| DateExtensions | 8 | dateString / isToday / isYesterday / daysAgo / daysLater / daysDifference |
| UserModels | 9 | LessonProgress / QuizHistory / DailyRecord / AppSettings / UserLevel / ExamResult / SwiftData CRUD |
| GamificationService | 13 | levelThresholds / calculateLevel / XPAmount / badgeDefinitions / awardXP / awardBadge / progressToNextLevel |
| ProgressService | 8 | getSettings / startLesson / completeLesson / recordQuizAnswer / addStudySeconds / todayStats |
| ExamService | 7 | definitions / filtering / defaultPassingRate / saveResult / topicDisplayName |
| ReviewService | 5 | shouldReview / reviewCount / latestHistoryPublic |
| JSONResources | 7 | courses_index / glossary / 全チャプター JSON / 全試験 JSON（正解検証付き）/ quizId 一意性 |
| ContentService | 11 | loadAllContentAsync / getAllCourses / getCourse / getLessons / getQuizzes / searchGlossary / getNextLessonId |
| SchemaVersions | 4 | V1/V2 schema model count / migration stages / in-memory container |

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|---|---|---|
| 1.0.0 | 2026-04-08 | 初版作成。v1.00 リリースに対応した設計をコードベースから逆算して策定 |
| 2.0.0 | 2026-04-12 | 全面改訂。ViewModel 層追加（4 VM）。Service 11→14（AppLogger / CrashReportService / PracticeService 追加）。View 23→36（実践演習・環境構築・ガイドツアー・クイズ結果・レッスン一覧等追加）。Theme 1→3 ファイル。Extension 1→2 ファイル。Schema V2 追加。コンテンツ統計全更新（34 コース / 169 レッスン / 575 クイズ / 202 用語 / 108 演習 / 640 試験問題）。テスト設計セクション追加。構造化ログセクション追加 |
| 2.0.1 | 2026-04-12 | View 層ファイル数修正 (30 Views + 6 Components = 36)。MVVM 用語補足追加 |
| 2.1.0 | 2026-04-14 | Service 層 14→15 (LanguageManager 追加)。Component 6→7 (GlossaryPopupView 追加)。JSON リソース数 46→92 (英語版追加反映)。学習タイマーを Timer から Task パターンに修正。サービス初期化フローに LanguageManager 追加 |
