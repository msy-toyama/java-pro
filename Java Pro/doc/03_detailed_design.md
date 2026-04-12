# プロプロ（プログラミングのプロになる -Java入門-）— 詳細設計書

| 項目 | 内容 |
|---|---|
| ドキュメントID | DD-001 |
| バージョン | 2.0.0 |
| 作成日 | 2026-04-08 |
| 最終更新日 | 2026-04-12 |
| 対応基本設計 | BD-001 v2.0.0 |
| ステータス | リリース版 |

---

## 目次

1. [データモデル詳細](#1-データモデル詳細)
2. [コンテンツモデル詳細](#2-コンテンツモデル詳細)
3. [実践演習モデル詳細](#3-実践演習モデル詳細)
4. [スキーマバージョニング詳細](#4-スキーマバージョニング詳細)
5. [サービス層詳細](#5-サービス層詳細)
6. [ViewModel 層詳細](#6-viewmodel-層詳細)
7. [ビュー層詳細](#7-ビュー層詳細)
8. [コンポーネント詳細](#8-コンポーネント詳細)
9. [テーマシステム詳細](#9-テーマシステム詳細)
10. [拡張メソッド詳細](#10-拡張メソッド詳細)
11. [アプリエントリポイント詳細](#11-アプリエントリポイント詳細)
12. [リソースファイル詳細](#12-リソースファイル詳細)
13. [テストスイート詳細](#13-テストスイート詳細)

---

## 1. データモデル詳細

**ファイル**: `Models/UserModels.swift`

SwiftData の `@Model` マクロで定義された 8 クラスがアプリの永続化データを管理する。全モデルは `Sendable` に準拠する。

### 1.1 列挙型

#### `enum LessonStatus: String, Codable, Sendable`

| ケース | Raw 値 | 説明 |
|---|---|---|
| `.notStarted` | `"notStarted"` | 未開始 |
| `.inProgress` | `"inProgress"` | 学習中 |
| `.completed` | `"completed"` | 完了 |

### 1.2 UserLessonProgress

レッスンごとの進捗状態を管理する。

| プロパティ | 型 | 制約 | デフォルト | 説明 |
|---|---|---|---|---|
| `lessonId` | `String` | `@Attribute(.unique)` | — | レッスン ID (e.g. `"ch01_lesson1"`) |
| `statusRaw` | `String` | — | `"notStarted"` | `LessonStatus` の Raw 値 |
| `startedAt` | `Date?` | — | `nil` | 開始日時 |
| `completedAt` | `Date?` | — | `nil` | 完了日時 |

**Computed Property:**
- `status: LessonStatus` — `statusRaw` を `LessonStatus` へ変換。不正値は `.notStarted` にフォールバック

**Initializer:** `init(lessonId: String, status: LessonStatus = .notStarted)`

### 1.3 UserQuizHistory

クイズ回答履歴。間隔反復のステージ管理に使用。

| プロパティ | 型 | 制約 | デフォルト | 説明 |
|---|---|---|---|---|
| `id` | `String` | `@Attribute(.unique)` | UUID 文字列 | トランザクション ID |
| `quizId` | `String` | — | — | クイズ ID |
| `answeredAt` | `Date` | — | `Date()` | 回答日時 |
| `isCorrect` | `Bool` | — | — | 正誤 |
| `streakCount` | `Int` | — | `0` | 連続正解数（誤答でリセット） |
| `intervalStage` | `Int` | — | `0` | 復習間隔ステージ (0–4) |

**Initializer:** `init(quizId:, isCorrect:, streakCount: 0, intervalStage: 0)`

### 1.4 UserDailyRecord

日ごとの学習統計を集計する。

| プロパティ | 型 | 制約 | デフォルト | 説明 |
|---|---|---|---|---|
| `dateString` | `String` | `@Attribute(.unique)` | — | 日付文字列 `"yyyy-MM-dd"` |
| `completedLessons` | `Int` | — | `0` | 完了レッスン数 |
| `completedQuizzes` | `Int` | — | `0` | 完了クイズ数 |
| `earnedXP` | `Int` | — | `0` | 獲得 XP |
| `studySeconds` | `Int` | — | `0` | 学習秒数 (**V2 追加**) |

### 1.5 AppSettings

アプリ設定をシングルトン行として管理する（`id` = `"app_settings"` 固定）。

| プロパティ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `id` | `String` | `"app_settings"` | `@Attribute(.unique)` |
| `notificationsEnabled` | `Bool` | `true` | リマインダー通知 |
| `adRemoved` | `Bool` | `false` | 後方互換フラグ |
| `reminderHour` | `Int` | `8` | 通知時（※オンボーディング完了時に 20 へ上書き） |
| `reminderMinute` | `Int` | `0` | 通知分 |
| `hasCompletedOnboarding` | `Bool` | `false` | オンボーディング完了済み |
| `isDarkMode` | `Bool?` | `nil` | `nil`=システム, `true`=ダーク, `false`=ライト |
| `selectedCertificationRaw` | `String` | `"beginner"` | 選択中の資格レベル |
| `dailyGoalMinutes` | `Int` | `15` | 1 日の学習目標（分） |
| `hapticFeedbackEnabled` | `Bool` | `true` | 触覚フィードバック |
| `soundEnabled` | `Bool` | `true` | 効果音 ON/OFF |
| `soundVolume` | `Double` | `0.7` | 効果音音量 (**V2 追加**) |

**Computed Property:**
- `selectedCertification: CertificationLevel` — `selectedCertificationRaw` を `CertificationLevel` へ変換

### 1.6 UserXPRecord

XP 獲得トランザクションログ。

| プロパティ | 型 | 制約 | デフォルト | 説明 |
|---|---|---|---|---|
| `id` | `String` | `@Attribute(.unique)` | UUID 文字列 | トランザクション ID |
| `amount` | `Int` | — | — | XP 量 |
| `reason` | `String` | — | — | 獲得理由 (e.g. `"lesson_complete"`) |
| `earnedAt` | `Date` | — | `Date()` | 獲得日時 |
| `relatedId` | `String?` | — | `nil` | 関連 ID (レッスン/クイズ ID) |

**XP Reason 文字列一覧:**
- `"lesson_complete"` / `"quiz_correct"` / `"quiz_perfect"` / `"streak_bonus"` / `"review_correct"` / `"first_try_correct"` / `"exam_pass_bonus"`

### 1.7 UserBadge

獲得済みバッジ。

| プロパティ | 型 | 制約 | 説明 |
|---|---|---|---|
| `badgeId` | `String` | `@Attribute(.unique)` | バッジ ID (e.g. `"first_lesson"`) |
| `name` | `String` | — | 表示名 |
| `badgeDescription` | `String` | — | 説明文 |
| `iconName` | `String` | — | SF Symbols 名 |
| `colorHex` | `String` | — | アイコン色 (HEX) |
| `earnedAt` | `Date` | — | 獲得日時 |

### 1.8 UserLevel

ユーザーレベル。シングルトン行（`id` = `"user_level"` 固定）。

| プロパティ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `id` | `String` | `"user_level"` | `@Attribute(.unique)` |
| `level` | `Int` | `1` | 現在レベル |
| `totalXP` | `Int` | `0` | 累計 XP |
| `lastLevelUpAt` | `Date?` | `nil` | 最後のレベルアップ日時 |

### 1.9 UserExamResult

模擬試験結果。

| プロパティ | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | `String` | `@Attribute(.unique)` | UUID 文字列 |
| `examChapterId` | `String` | — | 試験 ID (e.g. `"se11_silver_1"`) |
| `score` | `Int` | — | 正解数 |
| `totalQuestions` | `Int` | — | 問題数 |
| `timeSpentSeconds` | `Int` | — | 所要秒数 |
| `passed` | `Bool` | — | 合否（保存時に自動計算） |
| `completedAt` | `Date` | — | 完了日時 |
| `topicScoresJSON` | `String?` | — | トピック別スコア (JSON 文字列) |

### 1.10 TodayStats

DTO 構造体（非永続化）。

```swift
struct TodayStats: Sendable {
    var completedLessons: Int
    var completedQuizzes: Int
    var streak: Int
    var earnedXP: Int
    var studyMinutes: Int
}
```

---

## 2. コンテンツモデル詳細

**ファイル**: `Models/ContentModels.swift`

バンドル JSON から読み込まれるコンテンツデータの構造体群。全て `Codable`, `Sendable` に準拠。

### 2.1 列挙型

#### `enum CertificationLevel: String, Codable, Sendable, CaseIterable`

| ケース | 対応コース数 | レッスン数 | 無料/有料 |
|---|---|---|---|
| `.beginner` | 8 コース | 46 | 無料 |
| `.silver` | 9 コース | 43 | 有料 |
| `.gold` | 17 コース | 80 | 有料 |

#### `enum QuizDifficulty: String, Codable, Sendable`
- `.easy` / `.normal` / `.hard`

#### `enum QuizType: String, Codable, Sendable` (8 種)

| ケース | Raw 値 | 表示ラベル | 表示色 |
|---|---|---|---|
| `.fourChoice` | `"fourChoice"` | 4 択問題 | `AppColor.primary` |
| `.multiChoice` | `"multiChoice"` | 複数選択 | `.purple` |
| `.fillBlank` | `"fillBlank"` | 穴埋め問題 | `.orange` |
| `.reorder` | `"reorder"` | 並び替え問題 | `AppColor.info` |
| `.outputPredict` | `"outputPredict"` | 出力予想 | `.teal` |
| `.errorFind` | `"errorFind"` | エラー発見 | `AppColor.error` |
| `.codeComplete` | `"codeComplete"` | コード補完 | `AppColor.success` |
| `.examSimulator` | `"examSimulator"` | 試験形式 | `.indigo` |

> **後方互換**: `init(from:)` で旧 `"errorCause"` → `.errorFind` に自動マッピング。

### 2.2 CourseIndex

コースインデックス。`courses_index.json` の各エントリに対応。

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | コース ID (e.g. `"ch01_introduction"`) |
| `title` | `String` | コース名 |
| `subtitle` | `String` | サブタイトル |
| `order` | `Int` | 表示順序 |
| `iconName` | `String` | SF Symbols 名 |
| `colorHex` | `String` | カラー HEX |
| `isMVP` | `Bool?` | MVP（無料範囲）フラグ |
| `lessonCount` | `Int` | レッスン数 |
| `fileName` | `String` | JSON ファイル名 |
| `certificationLevel` | `CertificationLevel?` | 資格レベル |
| `examTopics` | `[String]?` | 関連試験トピック |
| `category` | `String?` | カテゴリ分類 |

**カテゴリ一覧 (10 種):**
`basics` / `oop` / `error_handling` / `standard_library` / `data_collections` / `functional_stream` / `database_web` / `concurrency_io` / `modules_i18n` / `exam_practice`

### 2.3 ChapterContent

1 チャプターのコンテンツ。

```swift
struct ChapterContent: Codable, Sendable {
    let courseId: String
    let lessons: [LessonData]
}
```

### 2.4 LessonData

レッスン本体データ。

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | レッスン ID (e.g. `"ch01_lesson1"`) |
| `courseId` | `String` | 所属コース ID |
| `title` | `String` | レッスンタイトル |
| `summary` | `String` | 要約 |
| `estimatedMinutes` | `Int` | 推定学習分数 |
| `order` | `Int` | 表示順序 |
| `contents` | `[LessonSection]` | セクション一覧 |
| `quizzes` | `[QuizData]` | 付属クイズ一覧 |

### 2.5 LessonSection

レッスン内のセクション。

| プロパティ | 型 | 説明 |
|---|---|---|
| `lessonId` | `String` | 所属レッスン ID |
| `sectionType` | `SectionType` | セクション種別 |
| `title` | `String` | セクションタイトル |
| `body` | `String?` | 本文 |
| `code` | `String?` | コードスニペット |
| `note` | `String?` | 補足ノート |
| `order` | `Int` | 表示順序 |

**Computed `id`**: `"\(lessonId)_\(order)"`

#### `enum SectionType: String, Codable, Sendable`

| ケース | 表示 | アイコン |
|---|---|---|
| `.overview` | 概要 | `book.fill` |
| `.rule` | ルール | `checklist` |
| `.code` | コード例 | `chevron.left.forwardslash.chevron.right` |
| `.point` | ポイント | `star.fill` |
| `.tip` | 補足 | `lightbulb.fill` |

### 2.6 QuizData

クイズ問題データ。8 種のクイズタイプに対応する汎用構造体。

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | クイズ ID |
| `lessonId` | `String` | 所属レッスン ID |
| `type` | `QuizType` | クイズ種別 |
| `question` | `String` | 問題文 |
| `code` | `String?` | 問題コード |
| `explanation` | `String` | 解説 |
| `choices` | `[QuizChoice]` | 選択肢一覧 |
| `correctOrder` | `[String]?` | 並び替え正解順序 |
| `executionResult` | `ExecutionResult?` | 実行結果 |
| `fixedExecutionResult` | `ExecutionResult?` | 修正後の実行結果 |
| `codeTemplate` | `String?` | コード補完用テンプレート |
| `blanks` | `[BlankDefinition]?` | 穴埋め定義 |
| `combinedResults` | `[CombinedResult]?` | 穴埋め組合せ結果 |
| `requiredSelections` | `Int?` | 複数選択の必要選択数 |
| `certificationTopic` | `String?` | 試験トピック分類 |
| `difficulty` | `QuizDifficulty?` | 難易度 |

### 2.7 QuizChoice

```swift
struct QuizChoice: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let text: String
    let isCorrect: Bool
    let order: Int
    var executionResult: ExecutionResult?
}
```

### 2.8 補助構造体

```swift
struct ExecutionResult: Codable, Hashable, Sendable {
    let output: String; let exitCode: Int; let hasError: Bool
    let errorMessage: String?; let errorType: String?
}

struct BlankDefinition: Codable, Hashable, Sendable {
    let id: String; let label: String; let choices: [BlankChoice]
}

struct BlankChoice: Codable, Hashable, Sendable {
    let id: String; let text: String; let isCorrect: Bool
}

struct CombinedResult: Codable, Hashable, Sendable {
    let combination: [String: String]; let executionResult: ExecutionResult
}

struct GlossaryEntry: Codable, Identifiable, Hashable, Sendable {
    let id: String; let term: String; let reading: String
    let definition: String; let relatedLessonIds: [String]
}
```

---

## 3. 実践演習モデル詳細

**ファイル**: `Models/PracticeModels.swift`

`practice_exercises.json` からデコードされる実践演習データ。

### 3.1 PracticeData (ルート)

```swift
struct PracticeData: Codable, Sendable {
    let setupGuide: [SetupGuideSection]  // 環境構築ガイド (5 セクション)
    let chapters: [PracticeChapter]       // 演習チャプター (39 件)
}
```

### 3.2 SetupGuideSection

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | セクション ID |
| `title` | `String` | セクションタイトル |
| `iconName` | `String` | SF Symbols 名 |
| `steps` | `[SetupStep]` | 手順一覧 |

### 3.3 SetupStep

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | ステップ ID |
| `title` | `String` | ステップタイトル |
| `body` | `String` | 本文 |
| `code` | `String?` | コマンド/コード |
| `tip` | `String?` | 補足 |

### 3.4 PracticeChapter

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | チャプター ID (e.g. `"practice_ch01"`) |
| `title` | `String` | タイトル |
| `subtitle` | `String` | サブタイトル |
| `certificationLevel` | `CertificationLevel` | 対象資格レベル |
| `category` | `String` | カテゴリ |
| `exercises` | `[PracticeExercise]` | 演習一覧 |

### 3.5 PracticeExercise

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `String` | 演習 ID |
| `title` | `String` | タイトル |
| `difficulty` | `Int` | 難易度 (1–3) |
| `relatedLessonId` | `String` | 関連レッスン ID |
| `description` | `String` | 問題文 |
| `expectedOutput` | `String` | 期待出力 |
| `hint` | `String?` | ヒント |
| `solutionCode` | `String` | 解答コード |
| `solutionFileName` | `String` | `.java` ファイル名 |
| `solutionExplanation` | `String?` | 解答解説 |

---

## 4. スキーマバージョニング詳細

**ファイル**: `Models/JavaStepSchemaVersions.swift`

### 4.1 JavaProSchemaV1

```swift
enum JavaProSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] = [
        UserLessonProgress.self, UserQuizHistory.self,
        UserDailyRecord.self, AppSettings.self,
        UserXPRecord.self, UserBadge.self,
        UserLevel.self, UserExamResult.self
    ]
}
```

### 4.2 JavaProSchemaV2 (現行)

```swift
enum JavaProSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)
    static var models: [any PersistentModel.Type] = [
        // V1 と同じ 8 モデル
        // V2 フィールド追加:
        //   - UserDailyRecord.studySeconds (デフォルト 0)
        //   - AppSettings.soundVolume (デフォルト 0.7)
    ]
}
```

### 4.3 JavaProMigrationPlan

```swift
enum JavaProMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [
        JavaProSchemaV1.self,
        JavaProSchemaV2.self
    ]
    static var stages: [MigrationStage] = [
        .lightweight(fromVersion: JavaProSchemaV1.self,
                     toVersion: JavaProSchemaV2.self)
    ]
}
```

**設計ポイント:**
- V1→V2 は **lightweight migration**（新規フィールドにデフォルト値があるため SwiftData が自動で追加）
- 将来のスキーマ変更は V3 を `schemas` に追加し、`stages` にマイグレーションステージを追記

### 4.4 ModelContainer 初期化戦略

```swift
// Java_StepApp.swift 内
init() {
    // テスト検出: XCTestConfigurationFilePath が存在する場合
    //   → 空 Schema のインメモリコンテナ (テスト用 TestDatabase の干渉を防ぐ)
    
    // 正常フロー:
    //   ModelConfiguration(schema: JavaProSchemaV2, url: .../JavaProStore.sqlite)
    //   ModelContainer(for: JavaProSchemaV2.models, migrationPlan: JavaProMigrationPlan)
    
    // フォールバック (DEBUG):
    //   1. storeURL 削除 → リトライ
    //   2. インメモリモード
    //   3. 空スキーマモード (Schema())
    
    // フォールバック (RELEASE):
    //   1. インメモリモード + dataRecoveryMode = true
    //   2. 空スキーマモード
    
    CrashReportService.shared.start()
    Task { await ContentService.shared.loadAllContentAsync() }
}
```

---

## 5. サービス層詳細

### 5.1 ContentService

**ファイル**: `Services/ContentService.swift`  
**パターン**: `@MainActor @Observable final class` / Singleton (`shared`)

#### 公開プロパティ

| プロパティ | 型 | 初期値 | 説明 |
|---|---|---|---|
| `courseIndexes` | `[CourseIndex]` | `[]` | コースインデックス一覧 |
| `glossary` | `[GlossaryEntry]` | `[]` | 用語辞典 |
| `isLoaded` | `Bool` | `false` | 全コンテンツロード完了 |
| `isCourseIndexLoaded` | `Bool` | `false` | Phase 1 完了 (コースインデックスのみ) |
| `loadError` | `String?` | `nil` | ロードエラーメッセージ |

#### 内部キャッシュ

| キャッシュ | 型 | 説明 |
|---|---|---|
| `chapters` | `[String: ChapterContent]` | courseId → チャプターマップ |
| `lessonsIndex` | `[String: LessonData]` | lessonId → レッスンフラットインデックス |
| `quizzesIndex` | `[String: QuizData]` | quizId → クイズフラットインデックス |
| `sortedLessonsCache` | `[String: [LessonData]]` | courseId → ソート済みレッスン配列 |
| `quizIdsByTypeCache` | `[String: Set<String>]` | QuizType.rawValue → クイズ ID セット |

#### 2 フェーズ非同期ロード

```
loadAllContentAsync()
│
├─ Phase 1 (即座): courses_index.json → [CourseIndex]
│   └─ @MainActor: courseIndexes 設定, isCourseIndexLoaded = true
│   └─ → UI はコース一覧を即座に表示可能
│
└─ Phase 2 (Task.detached バックグラウンド):
    ├─ 各コースの JSON ファイルを FileManager で読み込み (nonisolated)
    ├─ JSONDecoder でデコード (nonisolated)
    ├─ @MainActor で chapters/lessonsIndex/quizzesIndex に登録
    ├─ glossary.json → [GlossaryEntry]
    └─ isLoaded = true
```

#### 公開メソッド一覧

| メソッド | 戻り値 | 説明 |
|---|---|---|
| `loadAllContentAsync()` | `async` | 2 フェーズ非同期ロード |
| `ensureChapterLoaded(courseId:)` | `Void` | オンデマンド遅延ロード |
| `getAllCourses()` | `[CourseIndex]` | 全コースインデックス (order 順) |
| `getCourse(id:)` | `CourseIndex?` | 指定 ID のコース |
| `getLessons(courseId:)` | `[LessonData]` | 指定コースのレッスン (キャッシュ済み) |
| `getLesson(id:)` | `LessonData?` | 指定 ID のレッスン (O(1)) |
| `getQuizzes(lessonId:)` | `[QuizData]` | 指定レッスンのクイズ |
| `getQuiz(id:)` | `QuizData?` | 指定 ID のクイズ (O(1)) |
| `getNextLessonId(after:)` | `String?` | 次レッスン ID (コース内) |
| `getNextCourseFirstLessonId(after:)` | `String?` | 次コースの最初のレッスン ID |
| `getNextCourseTitle(after:)` | `String?` | 次コースのタイトル |
| `getAllQuizIds()` | `[String]` | 全クイズ ID |
| `getQuizIds(byType:)` | `Set<String>` | タイプ別クイズ ID (キャッシュ) |
| `getAllGlossary()` | `[GlossaryEntry]` | 全用語 |
| `searchGlossary(query:)` | `[GlossaryEntry]` | 用語検索 (term/reading/definition 部分一致) |
| `totalLessonCount` | `Int` (computed) | 総レッスン数 |
| `totalQuizCount` | `Int` (computed) | 総クイズ数 |

---

### 5.2 PracticeService

**ファイル**: `Services/PracticeService.swift`  
**パターン**: `@MainActor @Observable final class` / Singleton (`shared`)

#### 公開プロパティ

| プロパティ | 型 | 初期値 | 説明 |
|---|---|---|---|
| `setupGuide` | `[SetupGuideSection]` | `[]` | 環境構築ガイド (5 セクション) |
| `practiceChapters` | `[PracticeChapter]` | `[]` | 演習チャプター (39 件) |
| `isLoaded` | `Bool` | `false` | ロード完了 |
| `loadError` | `String?` | `nil` | ロードエラー |

#### 内部キャッシュ

| キャッシュ | 型 | 説明 |
|---|---|---|
| `exerciseIndex` | `[String: PracticeExercise]` | exerciseId → 演習フラットインデックス |

#### 公開メソッド一覧

| メソッド | 戻り値 | 説明 |
|---|---|---|
| `loadPracticeData()` | `Void` | `practice_exercises.json` をデコード |
| `getAllChapters()` | `[PracticeChapter]` | 全チャプター |
| `getChapters(for:)` | `[PracticeChapter]` | 指定レベルのチャプター |
| `getExercise(id:)` | `PracticeExercise?` | 指定 ID の演習 (O(1)) |
| `getExercises(forChapter:)` | `[PracticeExercise]` | チャプター内演習 |
| `getExercises(forRelatedLesson:)` | `[PracticeExercise]` | 関連レッスンの演習 |
| `getChapter(containingExercise:)` | `PracticeChapter?` | 演習が属するチャプター |
| `getChapters(forCourseId:)` | `[PracticeChapter]` | コース ID でフィルタ |
| `generateJavaFileURL(for:)` | `URL?` | 一時 `.java` ファイル生成 (ShareLink 用) |

---

### 5.3 ProgressService

**ファイル**: `Services/ProgressService.swift`  
**パターン**: `@MainActor @Observable final class` / DI (`init(modelContext:)`)

#### 公開メソッド一覧

| カテゴリ | メソッド | 戻り値 | 説明 |
|---|---|---|---|
| **設定** | `getSettings()` | `AppSettings` | シングルトン行取得/作成 |
| | `completeOnboarding()` | `Void` | `hasCompletedOnboarding = true` |
| **レッスン** | `getLessonProgress(lessonId:)` | `UserLessonProgress?` | 進捗取得 |
| | `startLesson(lessonId:)` | `Void` | `.notStarted` → `.inProgress` |
| | `completeLesson(lessonId:)` | `Void` | → `.completed` + 日次カウント▲ |
| | `completedLessonCount(courseId:)` | `Int` | コース別完了数 |
| | `allLessonProgressMap()` | `[String: LessonStatus]` | 全進捗一括取得 |
| | `allCompletedLessonIds()` | `Set<String>` | 全完了レッスン ID |
| | `totalCompletedLessonCount()` | `Int` | 全完了レッスン数 |
| | `lastInProgressLessonId()` | `String?` | 最後に学習中のレッスン |
| | `recommendedNextLessonId()` | `String?` | 推奨レッスン ID |
| **クイズ** | `recordQuizAnswer(quizId:, isCorrect:)` | `Void` | 回答記録 + streak/stage 更新 |
| | `latestQuizHistory(quizId:)` | `UserQuizHistory?` | 最新履歴 |
| | `totalCorrectQuizCount()` | `Int` | 全正解数 |
| | `totalPerfectCount()` | `Int` | 全問正解ボーナス数 |
| **日次** | `addStudySeconds(_ seconds:)` | `Void` | 学習秒数加算 |
| | `currentStreak()` | `Int` | 連続学習日数 (キャッシュ付き) |
| | `invalidateStreakCache()` | `Void` | キャッシュ無効化 |
| | `todayStats()` | `TodayStats` | 今日の統計 DTO |

---

### 5.4 GamificationService

**ファイル**: `Services/GamificationService.swift`  
**パターン**: `@MainActor @Observable final class` / DI (`init(modelContext:)`)

#### XP 定数 (`enum XPAmount`)

| ケース | 値 | 説明 |
|---|---|---|
| `lessonComplete` | 20 | レッスン完了 |
| `quizCorrect` | 10 | クイズ正解 |
| `quizPerfect` | 20 | 全問正解ボーナス |
| `reviewCorrect` | 15 | 復習正解 |
| `streakBonusPerDay` | 5 | ストリークボーナス (日数倍) |
| `firstTryCorrect` | 5 | 初回正解ボーナス |

#### レベルシステム

- `levelThresholds: [Int]` — Lv1(0) 〜 Lv50(30,600) の累計 XP 閾値配列
- 計算式: $XP_{required}(Lv) = \lfloor Lv^2 \times 12.24 \rfloor$
- `levelTitles: [Int: String]` — 21 段階の称号マッピング

#### XP 付与メソッド

| メソッド | 引数 | 戻り値 | 備考 |
|---|---|---|---|
| `awardXP(amount:, reason:, relatedId:)` | 量, 理由, 関連ID | `Int?` (新レベル or nil) | 基底メソッド |
| `awardLessonCompleteXP(lessonId:)` | lessonId | `Int?` | 重複チェック済み |
| `awardQuizCorrectXP(quizId:)` | quizId | `Int?` | 毎回付与 |
| `awardPerfectBonusXP(lessonId:)` | lessonId | `Int?` | 重複チェック済み |
| `awardStreakBonusXP(streakDays:)` | 日数 | `Int?` | `5 × streakDays` |
| `awardStreakBonusIfNeeded(streakDays:)` | 日数 | `Int?` | 1 日 1 回制限 |
| `awardReviewCorrectXP(quizId:)` | quizId | `Int?` | 毎回付与 |
| `awardFirstTryCorrectXP(quizId:)` | quizId | `Int?` | — |

#### バッジシステム (32 種)

**チェックメソッド:**
- `checkAndAwardBadges(completedLessons:, correctQuizzes:, streak:, perfectCount:, totalXP:) -> [String]`
  - パラメータに基づき条件を満たすバッジを一括チェック・付与
- `checkAndAwardSpeedDemon(elapsedSeconds:, isPerfect:) -> String?`
  - 30 秒以内に全問正解で `"speed_demon"` バッジ付与

**バッジ定義テーブル (抜粋):**

| ID | 名前 | 条件 | アイコン |
|---|---|---|---|
| `first_lesson` | はじめの一歩 | completedLessons ≥ 1 | `book.fill` |
| `lesson_100` | レッスンマスター | completedLessons ≥ 100 | `books.vertical.fill` |
| `quiz_500` | クイズレジェンド | correctQuizzes ≥ 500 | `brain.head.profile` |
| `perfect_10` | パーフェクト職人 | perfectCount ≥ 10 | `crown.fill` |
| `streak_365` | 伝説の継続者 | streak ≥ 365 | `calendar.badge.clock` |
| `silver_pass` | Silver 合格者 | — (試験合格時) | `checkmark.seal.fill` |
| `gold_pass` | Gold 合格者 | — (試験合格時) | `medal.fill` |
| `xp_30000` | XP マスター | totalXP ≥ 30000 | `sparkles` |

---

### 5.5 ExamService

**ファイル**: `Services/ExamService.swift`  
**パターン**: `@MainActor @Observable final class` / DI (`init(modelContext:)`)

#### 試験定義

```swift
struct ExamDefinition {
    let id: String           // e.g. "se11_silver_1"
    let title: String        // e.g. "Java SE 11 Silver 模擬試験 1"
    let subtitle: String
    let certLevel: CertificationLevel
    let javaVersion: JavaVersion
    let totalQuestions: Int  // 60 or 80
    let timeLimitMinutes: Int // 90 or 180
    let passingRate: Double  // 0.63
}
```

**8 試験テーブル:**

| ID | 資格 | バージョン | 問題数 | 制限時間 | 合格率 |
|---|---|---|---|---|---|
| `se11_silver_1` | Silver | SE 11 | 80 | 180 分 | 63% |
| `se11_silver_2` | Silver | SE 11 | 80 | 180 分 | 63% |
| `se11_gold_1` | Gold | SE 11 | 80 | 180 分 | 63% |
| `se11_gold_2` | Gold | SE 11 | 80 | 180 分 | 63% |
| `se17_silver_1` | Silver | SE 17 | 60 | 90 分 | 63% |
| `se17_silver_2` | Silver | SE 17 | 60 | 90 分 | 63% |
| `se17_gold_1` | Gold | SE 17 | 60 | 90 分 | 63% |
| `se17_gold_2` | Gold | SE 17 | 60 | 90 分 | 63% |

#### 公開メソッド

| メソッド | 戻り値 | 説明 |
|---|---|---|
| `loadExamQuizzes(examId:)` | `[QuizData]` | 試験問題 JSON ロード |
| `saveResult(examId:, score:, totalQuestions:, timeSpentSeconds:, topicScores:)` | `UserExamResult` | 結果保存 |
| `examHistory(certLevel:)` | `[UserExamResult]` | 試験履歴 (日付降順) |
| `latestPassedResult(certLevel:)` | `UserExamResult?` | 最新合格結果 |
| `attemptCount(examId:)` | `Int` | 受験回数 |
| `decodeTopicScores(_:)` | `[String: Double]` | JSON → トピック別スコア |
| `estimatedPassRate(certLevel:)` | `Double?` | 推定合格率 (直近 3 回平均) |

#### トピック表示名マッピング (31 トピック)

`topicDisplayName(_ key:)` で JSON キーを日本語表示に変換。
例: `"java_basics"` → `"Java の基本"` / `"oop"` → `"オブジェクト指向"` / `"lambda"` → `"ラムダ式"` etc.

---

### 5.6 ReviewService

**ファイル**: `Services/ReviewService.swift`  
**パターン**: `@MainActor @Observable final class` / DI (`init(modelContext:)`)

#### 間隔反復ロジック

```
復習間隔定数: [0秒, 24時間, 3日, 7日]   (Stage 0–3)
Stage 4 = 完了 (キューから除外)

shouldReview(quizId:, at: Date) -> Bool:
  1. 最新の UserQuizHistory を取得
  2. isCorrect == false → true (即時復習)
  3. intervalStage >= 4 → false (完了)
  4. answeredAt + intervals[stage] <= now → true

recordQuizAnswer での更新:
  正解: streakCount + 1, intervalStage + 1
  誤答: streakCount = 0, intervalStage = 0
```

#### 公開メソッド

| メソッド | 戻り値 | 説明 |
|---|---|---|
| `getReviewQueue(using:)` | `[QuizData]` | 復習対象クイズ一覧 |
| `reviewCount()` | `Int` | 復習対象数 |
| `shouldReview(quizId:, at:)` | `Bool` | 復習判定 |
| `weakCourseIds(limit:, using:)` | `[String]` | 正答率最低コース ID |
| `latestHistoryPublic(quizId:)` | `UserQuizHistory?` | 公開 API |
| `allLatestHistories()` | `[String: UserQuizHistory]` | 全履歴マップ |

---

### 5.7 AnalyticsService

**ファイル**: `Services/AnalyticsService.swift`  
**パターン**: `@MainActor @Observable final class` / DI (`init(modelContext:)`)

#### DTO

```swift
struct WeakTopic: Identifiable {
    let id: String; let title: String
    let correctRate: Double; let totalAttempts: Int; let incorrectCount: Int
}

struct DayStudyData: Identifiable {
    let id: String; let date: Date
    let lessonsCompleted: Int; let quizzesCompleted: Int
    let xpEarned: Int; let minutesStudied: Int
}

struct CertProgress {
    let certLevel: CertificationLevel
    let totalLessons: Int; let completedLessons: Int
    let totalQuizzes: Int; let correctQuizzes: Int
    let topicProgress: [String: (correct: Int, total: Int)]
    let examPassed: Bool; let bestExamScore: Int?
}
```

#### 公開メソッド

| メソッド | 戻り値 | 説明 |
|---|---|---|
| `weakTopics(certLevel:, limit:)` | `[WeakTopic]` | 正答率 80% 未満トピック |
| `weeklyStudyData()` | `[DayStudyData]` | 直近 7 日間統計 |
| `certificationProgress(level:)` | `CertProgress` | 資格レベル別進捗 |
| `totalStudyMinutes()` | `Int` | 総学習分数 |

**CertProgress のスコープ:** Silver = beginner + silver コース, Gold = beginner + silver + gold コース

---

### 5.8 StoreService

**ファイル**: `Services/StoreService.swift`  
**パターン**: `@MainActor @Observable final class` / Singleton (`shared`)

#### 商品定義

```swift
enum StoreProductID: String {
    case fullAccess = "com.javapro.fullaccess"  // Non-Consumable ¥480
}
```

#### 公開プロパティ

| プロパティ | 型 | 説明 |
|---|---|---|
| `products` | `[Product]` | StoreKit 2 商品リスト |
| `fullAccessUnlocked` | `Bool` | フルアクセス解放状態 |
| `isPurchasing` | `Bool` | 購入処理中 |
| `errorMessage` | `String?` | エラーメッセージ |
| `debugUnlockAll` | `Bool` | DEBUG 全解放 (#if DEBUG) |
| `isPremium` | `Bool` (computed) | `fullAccessUnlocked \|\| debugUnlockAll` |

#### アクセス制御ロジック

```swift
func canAccess(courseId: String, certLevel: CertificationLevel?) -> Bool {
    switch certLevel {
    case .beginner, nil, .none: return true  // 無料
    case .silver, .gold: return isPremium     // 有料
    }
}

func canAccessExam(examId: String) -> Bool {
    if examId == "se11_silver_1" { return true }  // 無料
    return isPremium
}
```

#### 購入フロー

```
purchase(product:)
├── Product.purchase() 呼び出し
├── VerificationResult.verified → fullAccessUnlocked = true
├── Transaction.finish()
└── エラー → errorMessage 設定

listenForTransactions (Task.detached)
└── Transaction.updates を監視 → 自動更新

refreshPurchaseStatus()
└── Transaction.currentEntitlements → 保有確認
```

---

### 5.9 SoundService

**ファイル**: `Services/SoundService.swift`  
**パターン**: `@MainActor final class` / Singleton (`shared`)  
> ※ `@Observable` 非適用

#### 効果音定義

```swift
enum Sound {
    case correct      // 正解音
    case incorrect    // 不正解音
    case levelUp      // レベルアップ
    case badgeEarned  // バッジ獲得
    case lessonComplete  // レッスン完了
    case tap          // タップ音
}
```

#### 音声合成

- 各 `Sound` に対応するシンセ音を **正弦波 WAV としてメモリ内で動的生成**
- `generateWAV(notes:, sampleRate:) -> Data?` — 16-bit mono WAV フォーマット
- AVAudioSession: `.ambient` カテゴリ、`.mixWithOthers` で他アプリと共存
- キャッシュ: 一度生成した WAV は辞書に保持

#### プロパティ

| プロパティ | 型 | 説明 |
|---|---|---|
| `isEnabled` | `Bool` | 効果音 ON/OFF |
| `volume` | `Float` | 音量 (0.0–1.0) |

---

### 5.10 NotificationService

**ファイル**: `Services/NotificationService.swift`  
**パターン**: `final class: Sendable` / Singleton (`shared`)  
> ※ `@Observable` 非適用、`@MainActor` 非適用

#### 公開メソッド

| メソッド | 説明 |
|---|---|
| `requestAuthorization() async -> Bool` | 通知許可リクエスト |
| `authorizationStatus() async -> UNAuthorizationStatus` | 現在の許可状態 |
| `scheduleDailyReminder(hour:, minute:)` | 先 7 日分リマインダー登録 |
| `cancelDailyReminder()` | リマインダー解除 |

#### リマインダー仕様

- 識別子フォーマット: `"daily_reminder_0"` 〜 `"daily_reminder_6"`
- タイトル: `"今日もJavaを学ぼう 📚"`
- 本文: 6 パターンからランダム選択
- トリガー: `UNCalendarNotificationTrigger` (繰り返しなし、7 日分個別)

---

### 5.11 AppearanceManager

**ファイル**: `Services/AppearanceManager.swift`  
**パターン**: `@MainActor @Observable final class` / Singleton (`shared`)

| プロパティ | 型 | 説明 |
|---|---|---|
| `colorSchemeOverride` | `ColorScheme?` | `nil`=システム, `.dark`, `.light` |

| メソッド | 説明 |
|---|---|
| `sync(from isDarkMode: Bool?)` | 設定値から外観を同期 |
| `setDarkMode(_ isDarkMode: Bool?)` | 外観を変更 |

---

### 5.12 SaveErrorNotifier

**ファイル**: `Services/SaveErrorNotifier.swift`  
**パターン**: `@MainActor @Observable final class` / Singleton (`shared`)

```swift
var lastError: String?
func report(_ error: Error)  // lastError にメッセージ設定
func clear()                 // lastError = nil
```

RootView で `.alert` にバインドし、データ保存エラーをユーザーに通知。

---

### 5.13 AppLogger

**ファイル**: `Services/AppLogger.swift`  
**パターン**: `enum` (インスタンス化不可、名前空間として使用)

```swift
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.masaya.JavaPro"
    
    static let swiftData     = Logger(subsystem: subsystem, category: "SwiftData")
    static let store         = Logger(subsystem: subsystem, category: "StoreKit")
    static let content       = Logger(subsystem: subsystem, category: "Content")
    static let notification  = Logger(subsystem: subsystem, category: "Notification")
    static let gamification  = Logger(subsystem: subsystem, category: "Gamification")
    static let sound         = Logger(subsystem: subsystem, category: "Sound")
    static let viewModel     = Logger(subsystem: subsystem, category: "ViewModel")
    static let app           = Logger(subsystem: subsystem, category: "App")
}
```

**利用ガイドライン:**
- `print()` 文は一切使用しない — 全出力は `AppLogger` 経由
- エラー: `.error()` / 警告: `.warning()` / 情報: `.info()` / デバッグ: `.debug()`
- プライバシー: `\(error, privacy: .public)` でエラーメッセージのみ公開

---

### 5.14 CrashReportService

**ファイル**: `Services/CrashReportService.swift`  
**パターン**: `final class: NSObject, @unchecked Sendable` / Singleton (`shared`)

MetricKit の `MXMetricManagerSubscriber` を実装し、クラッシュ・パフォーマンス診断を収集する。

#### メソッド

| メソッド | 説明 |
|---|---|
| `start()` | `MXMetricManager.shared.add(self)` |
| `stop()` | `MXMetricManager.shared.remove(self)` |
| `didReceive(_: [MXMetricPayload])` | メモリピーク値をログ出力 |
| `didReceive(_: [MXDiagnosticPayload])` | クラッシュ/ハング/ディスク/CPU 超過を検出 |

#### プロパティ

| プロパティ | 型 | 説明 |
|---|---|---|
| `lastDiagnosticSummary` | `String?` (UserDefaults) | 直近の診断サマリー |

**検出対象:**
- `crashDiagnostics` — クラッシュ数を記録
- `hangDiagnostics` — ハング検出数を記録
- `diskWriteExceptionDiagnostics` — ディスク書込超過
- `cpuExceptionDiagnostics` — CPU 使用超過

---

## 6. ViewModel 層詳細

### 6.1 HomeViewModel

**ファイル**: `ViewModels/HomeViewModel.swift`  
**パターン**: `@MainActor @Observable final class`

#### プロパティ

| プロパティ | 型 | 初期値 | 説明 |
|---|---|---|---|
| `todayStats` | `TodayStats` | ゼロ初期化 | 今日の統計 |
| `reviewCount` | `Int` | `0` | 復習対象数 |
| `recommendedLesson` | `LessonData?` | `nil` | おすすめレッスン |
| `totalCompleted` | `Int` | `0` | 全完了レッスン数 |
| `totalLessons` | `Int` | `0` | 全レッスン数 |
| `userLevel` | `Int` | `1` | 現在レベル |
| `levelTitle` | `String` | `""` | レベル称号 |
| `levelProgress` | `Double` | `0` | 次レベルまでの進捗率 |
| `totalXP` | `Int` | `0` | 累計 XP |
| `recentBadges` | `[UserBadge]` | `[]` | 最新獲得バッジ (最大 4 件) |
| `isLoading` | `Bool` | `false` | ロード中 |
| `dailyGoalMinutes` | `Int` | `10` | 学習目標（loadData() で AppSettings.dailyGoalMinutes=15 に上書き） |
| `showGuideTour` | `Bool` | `false` | ガイドツアー表示 |
| `lastLoadTime` | `Date?` | `nil` | 最終ロード時刻 |

#### Computed Properties

| プロパティ | 型 | 説明 |
|---|---|---|
| `streakMessage` | `String` | ストリーク数に応じた励ましメッセージ |
| `overallProgress` | `Double` | 全体完了率 (0.0–1.0) |
| `dailyGoalProgress` | `Double` | 日次目標達成率 |

#### メソッド

| メソッド | 説明 |
|---|---|
| `refreshIfNeeded(modelContext:)` | 前回から 3 秒以上経過時のみ `loadData` 呼び出し |
| `checkGuideTour()` | `UserDefaults.hasSeenHomeTour` == false なら表示 |
| `dismissGuideTour()` | ツアー完了フラグ設定 |
| `loadData(modelContext:)` | 全サービスからデータ読み込み・統合 |

---

### 6.2 QuizViewModel

**ファイル**: `ViewModels/QuizViewModel.swift`  
**パターン**: `@MainActor @Observable final class`

#### 初期化パラメータ

```swift
init(quizzes: [QuizData], lessonId: String? = nil,
     isReviewMode: Bool = false,
     onComplete: (() -> Void)? = nil,
     onNextLesson: (() -> Void)? = nil)
```

#### 状態プロパティ (20 個)

| プロパティ | 型 | 説明 |
|---|---|---|
| `currentIndex` | `Int` | 現在の問題インデックス |
| `selectedChoiceId` | `String?` | 単一選択の選択 ID |
| `selectedChoiceIds` | `Set<String>` | 複数選択の選択 ID |
| `selectedOrderIds` | `[String]` | 並び替えの選択順序 |
| `blankSelections` | `[String: String]` | 穴埋めの選択 |
| `isAnswered` | `Bool` | 回答済み |
| `isCorrect` | `Bool` | 正誤 |
| `correctCount` | `Int` | 正解数 |
| `showResult` | `Bool` | 結果画面表示 |
| `showExecutionResult` | `Bool` | 実行結果表示 |
| `earnedXP` | `Int` | 今回獲得 XP |
| `newBadges` | `[String]` | 新規獲得バッジ |
| `newLevel` | `Int?` | 新レベル |
| `showConfetti` | `Bool` | 紙吹雪表示 |
| `showLevelUpOverlay` | `Bool` | レベルアップ表示 |
| `answerShakeOffset` | `CGFloat` | 不正解シェイクオフセット |
| `correctBounce` | `Bool` | 正解バウンス |
| `showDismissConfirm` | `Bool` | 中断確認ダイアログ |
| `hapticEnabled` | `Bool` | 触覚フィードバック |

#### メソッド

| メソッド | 説明 |
|---|---|
| `loadSettings(modelContext:)` | 触覚フィードバック設定取得 |
| `submitAnswer(modelContext:, reduceMotion:)` | 4 択 / 出力予想 / エラー発見の回答処理 |
| `submitMultiChoiceAnswer(...)` | 複数選択の回答処理 |
| `submitReorderAnswer(...)` | 並び替えの回答処理 |
| `submitCodeCompleteAnswer(...)` | コード補完の回答処理 |
| `processAnswer(correct:, modelContext:, reduceMotion:)` | 共通採点処理 (XP/バッジ/アニメーション) |
| `completeQuizSession(modelContext:)` | セッション終了 (全問正解ボーナス判定) |
| `moveToNext()` | 次の問題へ |
| `retryQuiz()` | 再挑戦（状態リセット） |

---

### 6.3 ExamSimulatorViewModel

**ファイル**: `ViewModels/ExamSimulatorViewModel.swift`  
**パターン**: `@MainActor @Observable final class`

#### 初期化

```swift
init(examDefinition: ExamService.ExamDefinition)
```

#### 状態プロパティ (19 個)

| プロパティ | 型 | 説明 |
|---|---|---|
| `quizzes` | `[QuizData]` | 試験問題一覧 |
| `isExamLoaded` | `Bool` | ロード完了 |
| `currentIndex` | `Int` | 現在の問題番号 |
| `answers` | `[String: String]` | 4 択回答マップ |
| `multiAnswers` | `[String: [String]]` | 複数選択回答マップ |
| `flaggedQuestions` | `Set<Int>` | フラグ付き問題 |
| `remainingSeconds` | `Int` | 残り秒数 |
| `timerActive` | `Bool` | タイマー有効 |
| `showQuestionList` | `Bool` | 問題一覧表示 |
| `showConfirmEnd` | `Bool` | 終了確認ダイアログ |
| `examFinished` | `Bool` | 試験終了 |
| `isFinishing` | `Bool` | 採点処理中 |
| `examResult` | `UserExamResult?` | 結果 |
| `topicScores` | `[String: Double]` | トピック別スコア |
| `backgroundDate` | `Date?` | バックグラウンド移行時刻 |
| `backgroundRemainingSeconds` | `Int?` | バックグラウンド時の残り秒数 |
| `loadError` | `Bool` | ロードエラー |
| `slideDirection` | `Edge` | スライド方向 |
| `flagBounce` | `Bool` | フラグアニメーション |

#### メソッド

| メソッド | 説明 |
|---|---|
| `loadExam(modelContext:)` | 試験問題ロード + シャッフル + タイマー設定 |
| `toggleChoice(quiz:, choiceId:)` | 回答選択切替 |
| `toggleFlag()` | 現在問題のフラグ切替 |
| `goToPrevious()` / `goToNext()` | 問題移動 |
| `jumpToQuestion(_ index:)` | 指定問題へジャンプ |
| `handleResignActive()` | アプリ非活性時のタイマー処理 |
| `handleBecomeActive()` | アプリ復帰時のタイマー補正 |
| `timerTick(modelContext:)` | 1 秒ごとのタイマー更新 (0 → 自動提出) |
| `finishExam(modelContext:)` | 採点 + 結果保存 + XP 付与 + バッジチェック |

**採点ロジック:**
1. 各問題の回答を正解と照合
2. multiChoice: 完全一致のみ正解
3. topicScores: トピック別正答率を計算
4. 合格判定: score / totalQuestions ≥ passingRate (0.63)
5. 初回合格: 500 XP + `silver_pass` or `gold_pass` バッジ

---

### 6.4 SettingsViewModel

**ファイル**: `ViewModels/SettingsViewModel.swift`  
**パターン**: `@MainActor @Observable final class`

#### プロパティ (15 個)

| プロパティ | 型 | 説明 |
|---|---|---|
| `notificationsEnabled` | `Bool` | 通知 ON/OFF |
| `reminderHour` | `Int` | 通知時 |
| `reminderMinute` | `Int` | 通知分 |
| `showResetConfirm` / `showResetComplete` / `showResetError` | `Bool` | リセット関連ダイアログ |
| `showPermissionDenied` | `Bool` | 通知権限拒否ダイアログ |
| `showPaywall` | `Bool` | 課金画面 |
| `isDarkMode` | `Bool?` | ダークモード |
| `selectedCertification` | `CertificationLevel` | 資格レベル |
| `dailyGoalMinutes` | `Int` | 目標分数 |
| `hapticFeedbackEnabled` | `Bool` | 触覚 |
| `soundEnabled` | `Bool` | 効果音 |
| `soundVolume` | `Double` | 音量 |
| `volumeSaveTask` | `Task<Void, Never>?` | 音量デバウンス用 |

#### メソッド

| メソッド | 説明 |
|---|---|
| `loadSettings(modelContext:)` | 設定をモデルから VM へ同期 |
| `updateAppearance(modelContext:)` | 外観変更 → AppearanceManager + モデル保存 |
| `updateSettings(modelContext:)` | 各種設定をモデルに保存 |
| `updateNotification(enabled:, modelContext:)` | 通知切替 + 許可リクエスト |
| `updateReminderTime(modelContext:)` | リマインダー時刻変更 |
| `resetAllData(modelContext:)` | **全データ削除** (8 モデル全行削除 + 設定再初期化 + ガイドツアーリセット) |
| `debounceSaveVolume(modelContext:)` | 音量変更を 300ms デバウンス保存 |

---

## 7. ビュー層詳細

### 7.1 RootView

**ファイル**: `Views/RootView.swift`

アプリのルートコンテナ。起動画面 → オンボーディング / メインタブの分岐を担当。

#### 主要責務

1. **サービス初期化**: `.task` で ProgressService / ContentService / PracticeService / SoundService / AppearanceManager を順次起動
2. **学習タイマー管理**: scenePhase 監視で 60 秒周期タイマーを開始/停止
3. **エラーアラート**: SaveErrorNotifier / dataRecoveryMode / ContentService.loadError の 3 種

#### 学習タイマーフロー

```
startStudyTimer():
  foregroundStartDate = Date()
  Timer.scheduledTimer(60秒周期):
    ProgressService.addStudySeconds(60)

stopStudyTimer():
  Timer.invalidate()
  studyTimer = nil

flushStudySeconds():
  経過秒数 = Date() - foregroundStartDate
  ProgressService.addStudySeconds(経過秒数)
  foregroundStartDate = nil
```

#### LaunchScreen アニメーション

4 段階のシーケンシャルアニメーション:
1. **0.3s**: アイコンフェードイン + バウンス
2. **0.6s**: リング展開 + 回転
3. **0.9s**: アプリ名テキスト出現
4. **1.2s**: サブタイトル出現

背景: プライマリカラーグラデーション + `FloatingParticlesView(count: 15)`

### 7.2 MainTabView

**ファイル**: `Views/MainTabView.swift`

4 タブのメインナビゲーション。

| タブ | View | アイコン | ラベル |
|---|---|---|---|
| home | `HomeView` | `house.fill` | ホーム |
| learn | `CourseListView` | `book.fill` | 学習 |
| exam | `CertificationView` | `graduationcap.fill` | 試験対策 |
| mypage | `ProfileView` | `person.crop.circle.fill` | マイページ |

### 7.3 HomeView

**ファイル**: `Views/HomeView.swift`  
**ViewModel**: `HomeViewModel`

**UI 構成:**
- ガイドツアーオーバーレイ (初回のみ, 5 ステップ)
- レベルカード (レベル/XP/称号/AnimatedProgressBar/今日の XP)
- ストリークカード (日数 + メッセージ)
- 今日の統計カード (レッスン/クイズ/XP)
- 目標達成度プログレスバー (`dailyGoalProgress`)
- おすすめレッスンカード (tap → LessonDetailView)
- 最近のバッジ (最大 4 件, 「すべて見る」→ マイページ切替)
- 復習リマインダー (reviewCount > 0 時, tap → 試験対策切替)
- 進捗サマリーカード (全体完了率)

### 7.4 CourseListView

**ファイル**: `Views/CourseListView.swift`

**セグメント切替**: `enum LearnMode { case course, practice }`

- `.course` モード: コース一覧 (Beginner/Silver/Gold セクション) + 用語辞典リンク
- `.practice` モード: `PracticeListView` を表示

**ロック表示**: `StoreService.canAccess(courseId:, certLevel:)` が `false` → 🔒 オーバーレイ + PaywallView

### 7.5 LessonDetailView

**ファイル**: `Views/LessonDetailView.swift`

各 `LessonSection` を `SectionView` で表示。セクション内の本文は `RichBodyView`、コードは `CodeBlockView` でレンダリング。

**フッター**: 「クイズに挑戦」ボタン → `QuizView` (sheet) | 「次のレッスンへ」→ 次のレッスンへ遷移

### 7.6 QuizView

**ファイル**: `Views/QuizView.swift`  
**ViewModel**: `QuizViewModel`

8 種のクイズタイプに対応する汎用ビュー。`QuizAnswerViews.swift` / `QuizChoiceStyle.swift` で分離されたサブビューを使用。

**結果表示**: `QuizResultView` (sheet) — 正答数 / 獲得 XP / バッジ / レベルアップ

### 7.7 ExamSimulatorView

**ファイル**: `Views/ExamSimulatorView.swift`  
**ViewModel**: `ExamSimulatorViewModel`  
**表示**: `fullScreenCover`

**UI:**
- ナビゲーションバー (問題番号 / タイマー / フラグ / 一覧ボタン)
- 問題文 + コード (CodeBlockView) + 選択肢
- スライドトランジションで問題間移動
- QuestionListSheet (問題一覧パネル, sheet)
- 提出確認ダイアログ → ExamResultView

### 7.8 ExamResultView

**ファイル**: `Views/ExamResultView.swift`

スコア / 合否 / トピック別正答率チャート / ConfettiView (合格時) / レビューボタン → ExamReviewView (fullScreenCover)

### 7.9 PracticeListView

**ファイル**: `Views/PracticeListView.swift`

CourseListView の `.practice` モードで表示。

**UI 構成:**
- ガイドツアー (初回のみ, 4 ステップ)
- 環境構築ガイドカード → `EnvironmentSetupView`
- 9 カテゴリのコラプシブルセクション (DisclosureGroup)
- 各チャプターカード → `PracticeDetailView`

### 7.10 PracticeDetailView

**ファイル**: `Views/PracticeDetailView.swift`

**UI 構成:**
- チャプター情報ヘッダー
- 演習カード (DisclosureGroup, アコーディオン)
  - 問題文 (RichBodyView)
  - 期待出力 (CodeBlockView)
  - ヒント (DisclosureGroup, 再折りたたみ可)
  - 解答セクション
    - 解答コード (JavaSyntaxHighlighter)
    - 解答解説
    - `.java` ファイル ShareLink (`PracticeService.generateJavaFileURL`)
- 有料コンテンツは PaywallView 表示

### 7.11 EnvironmentSetupView / EnvironmentSetupDetailView

**ファイル**: `Views/EnvironmentSetupView.swift`, `Views/EnvironmentSetupDetailView.swift`

環境構築ガイド。5 セクション（JDK / IDE / CLI / プロジェクト構造 / トラブルシュート等）の目次 → 各セクション詳細にドリルダウン。

### 7.12 GuideTourView

**ファイル**: `Views/GuideTourView.swift`

**構造:**
- `GuideStep` — `id`, `icon`, `title`, `message`, `accentColor`
- `GuideTourOverlay` — フルスクリーンオーバーレイ + カード + ドットインジケーター
- `GuideTourSteps` — 4 画面分のステップ定義

**ツアー定義:**

| 画面 | ステップ数 | 内容 |
|---|---|---|
| `home` | 5 | ようこそ / XP / ストリーク / バッジ / 目標設定 |
| `learn` | 4 | 学習コース / レッスンの進め方 / 無料/Pro / 復習 |
| `practice` | 4 | 実践演習 / 環境構築 / ヒント解答 / .java ダウンロード |
| `exam` | 5 | 試験対策 / 模擬試験 / 非公式注意 / 弱点分析 / 合格目標 |

**UserDefaults キー:**
- `hasSeenHomeTour` / `hasSeenLearnTour` / `hasSeenExamTour` / `hasSeenPracticeTour`

### 7.13 その他のビュー

| ビュー | ファイル | 説明 |
|---|---|---|
| CertificationView | `CertificationView.swift` | 試験対策ダッシュボード (資格セグメント / Java バージョン選択 / 進捗概要 / チャプター別進捗 / 模擬試験 / 履歴 / 弱点 / 復習) |
| ExamReviewView | `ExamReviewView.swift` | 試験全問復習 (fullScreenCover) |
| ExamHistoryView | `ExamHistoryView.swift` | スコア推移チャート |
| WeakPointView | `WeakPointView.swift` | 弱点トピック分析 |
| ReviewView | `ReviewView.swift` | 間隔反復復習 → QuizView |
| GlossaryView | `GlossaryView.swift` | 用語辞典 (検索 + 50 音グループ) |
| ProfileView | `ProfileView.swift` | プロフィール / 統計 / バッジ / 設定リンク |
| SettingsView | `SettingsView.swift` | 設定画面 (SettingsViewModel) |
| BadgeListView | `BadgeListView.swift` | 全 32 バッジ一覧 |
| PaywallView | `PaywallView.swift` | 課金画面 (フルアクセス ¥480) |
| OnboardingView | `OnboardingView.swift` | 初回オンボーディング (5 ページ) |
| LessonListView | `LessonListView.swift` | コース内レッスン一覧 (ステップコネクタ + 進捗表示) |
| CodeExecutionView | `CodeExecutionView.swift` | コード実行結果のターミナル風表示 (タイプライターアニメーション) |
| QuizResultView | `QuizResultView.swift` | クイズセッション結果 (正答数 / 獲得 XP / バッジ / レベルアップ) |
| QuizAnswerViews | `QuizAnswerViews.swift` | 8 種クイズ形式の回答エリアサブビュー群 |
| QuizChoiceStyle | `QuizChoiceStyle.swift` | クイズ選択肢の ButtonStyle 定義 |
| PreviewHelpers | `PreviewHelpers.swift` | SwiftUI Preview 用ヘルパー |

---

## 8. コンポーネント詳細

**ディレクトリ**: `Views/Components/`

### 8.1 CodeBlockView

ターミナル風 UI でコードを表示する汎用コンポーネント。

```swift
struct CodeBlockView: View {
    let code: String
    var showCopyButton: Bool = true
}
```

- `JavaSyntaxHighlighter.highlight()` で Java コードを着色
- 「コピー」ボタンで UIPasteboard にコピー
- ダーク背景 (`AppColor.codeBackground`) + 等幅フォント

### 8.2 JavaSyntaxHighlighter

Java ソースコードのシンタックスハイライトエンジン。

```swift
enum JavaSyntaxHighlighter {
    static func highlight(_ code: String) -> AttributedString
    static func looksLikeJava(_ code: String) -> Bool
}
```

**配色**: VS Code Dark+ テーマ準拠

**トークン優先度** (上から順に適用):
1. コメント (`//`, `/* */`) — グレー
2. 文字列リテラル (`"..."`) — シアン
3. アノテーション (`@Override` 等) — イエロー
4. キーワード (50 語) — パープル/ピンク
5. 型名 (`String`, `Integer` 等) — ティール
6. 数値 — ライトグリーン

### 8.3 RichBodyView

```swift
struct RichBodyView: View {
    let text: String
}
```

Markdown 風の本文をリッチ表示:
- `**太字**` パース
- `|` で始まる行 → `MarkdownTableView` (テーブル表示)
- `・` / `•` で始まる行 → `BulletListView` (箇条書き)
- 通常テキスト → `Text` (行間設定付き)

**内部列挙型:** `enum Segment { case text(String), table([[String]]), bulletList([String]) }`

### 8.4 SectionView

```swift
struct SectionView: View {
    let section: LessonSection
}
```

`LessonSection.sectionType` に応じたカラーバー + アイコン付きカードを表示:
- `.overview` — 青系
- `.rule` — 緑系
- `.code` — パープル系
- `.point` — オレンジ系
- `.tip` — ティール系 + 💡 補足ノート

### 8.5 ConfettiView

```swift
struct ConfettiView: View { ... }
extension View { func confettiOverlay(isActive: Bool) -> some View }
```

60 個のパーティクルを放出する紙吹雪アニメーション。`accessibilityReduceMotion` 対応。

### 8.6 LevelUpOverlayView

```swift
struct LevelUpOverlayView: View {
    let level: Int
    let title: String
    let onDismiss: () -> Void
}
```

レベルアップ祝福オーバーレイ。リングアニメーション + シマーエフェクト + `accessibilityReduceMotion` 対応。

---

## 9. テーマシステム詳細

### 9.1 Theme.swift

**ファイル**: `Theme/Theme.swift`

4 つの設計トークン名前空間を提供。

#### AppColor

| カテゴリ | トークン名 | 値/説明 |
|---|---|---|
| ブランド | `primary` | `#3B82F6` (ブルー) |
| | `primaryDark` | `#1E3A5F` |
| | `primaryLight` | `#93C5FD` |
| | `accent` | `#F59E0B` (ゴールド) |
| | `accentLight` | `#FCD34D` |
| セマンティック | `success` | グリーン |
| | `error` | レッド |
| | `warning` | オレンジ |
| | `info` | ブルー |
| 背景 | `background` | Asset Catalog "Background" |
| | `cardBackground` | Asset Catalog "CardBackground" |
| | `codeBackground` | `Color(hex: "1E1E2E")` |
| | `codeText` | `Color(hex: "D4D4D4")` |
| テキスト | `textPrimary` | Asset Catalog "TextPrimary" |
| | `textSecondary` | Asset Catalog "TextSecondary" |
| | `textTertiary` | Asset Catalog "TextTertiary" |
| ゲーミフィケーション | `xpGold`, `levelPurple`, `badgeBronze/Silver/Gold` | — |
| 機能別 | `practiceIndigo`, `practiceViolet`, `quizCyan`, `quizMagenta` | — |
| ターミナル | `terminalGreen`, `terminalYellow`, `terminalRed` | — |
| チャプター | `chapterColors: [Color]` | 15 色配列 |

#### AppFont

| トークン | フォントスタイル |
|---|---|
| `largeTitle` | `.largeTitle.bold()` |
| `title` | `.title2.bold()` |
| `title3` | `.title3.bold()` |
| `headline` | `.headline` |
| `body` | `.body` |
| `callout` | `.callout` |
| `caption` | `.caption` |
| `code` | `.system(.body, design: .monospaced)` |
| `codeSmall` | `.system(.caption, design: .monospaced)` |

#### AppLayout

| カテゴリ | トークン | 値 |
|---|---|---|
| Padding | `paddingXS/SM/MD/LG/XL` | 4 / 8 / 16 / 24 / 32 |
| 角丸 | `cornerRadius` | 12 |
| | `cornerRadiusSmall` | 8 |
| | `cornerRadiusLarge` | 20 |
| 影 | `cardShadowRadius` | 8 |
| | `cardShadowY` | 2 |
| アイコン | `iconSizeSM/MD/LG` | 20 / 28 / 44 |

#### AppAnimation

| トークン | 値 |
|---|---|
| `quick` | `.easeOut(duration: 0.2)` |
| `standard` | `.easeInOut(duration: 0.3)` |
| `spring` | `.spring(response: 0.3, dampingFraction: 0.6)` |
| `bounce` | `.spring(response: 0.4, dampingFraction: 0.5)` |
| `typewriter` | `.easeInOut(duration: 0.05)` |

#### ViewModifier / ButtonStyle

| 名前 | Extension | 説明 |
|---|---|---|
| `CardStyle` | `.cardStyle(padding:)` | カード背景 + 角丸 + 影 (ダークモード対応) |
| `GlassStyle` | `.glassStyle()` | グラスモーフィズム (.ultraThinMaterial) |
| `PressableButtonStyle` | `.pressable` | タップ時スケールダウン (0.96) |
| `FeatureChip` | — | オンボーディング用チップ表示 |

#### Color Extension

```swift
extension Color {
    init(hex: String)  // 3桁 / 6桁 / 8桁 HEX 対応
}
```

---

### 9.2 ThemeAnimations.swift

**ファイル**: `Theme/ThemeAnimations.swift`

| コンポーネント | 型 | Extension | 説明 |
|---|---|---|---|
| `StaggeredCardAppear` | `ViewModifier` | `.staggeredAppear(index:, total:)` | フェードイン + スライドアップ、`index × 0.06s` 遅延 |
| `ShimmerModifier` | `ViewModifier` | `.shimmer(duration:, isActive:)` | 対角線方向グラデーションスライド |
| `PulseModifier` | `ViewModifier` | `.pulse(min:, max:, duration:)` | 拡縮繰り返しアニメーション |
| `AnimatedProgressBar` | `View` | — | 0→実値アニメーションプログレスバー (`Gradient` 対応) |
| `GlowCardStyle` | `ViewModifier` | `.glowCard(color:)` | ダークモードでグロー + ボーダー |
| `CountUpText` | `View` | — | 数値カウントアップアニメーション (`.numericText()` トランジション) |

> 全アニメーションは `@Environment(\.accessibilityReduceMotion)` で制御

---

### 9.3 ThemeComponents.swift

**ファイル**: `Theme/ThemeComponents.swift`

| コンポーネント | 型 | Extension | 説明 |
|---|---|---|---|
| `FloatingParticlesView` | `View` | — | `Canvas` 描画の浮遊パーティクル (黄金角ベース配置) |
| `SlideTransitionModifier` | `ViewModifier` | `.slideTransition(id:)` | 横スライド + opacity トランジション |
| `SectionAppearModifier` | `ViewModifier` | `.sectionAppear(index:)` | セクションフェードイン (`index × 0.08s` 遅延) |
| `TimerWarningModifier` | `ViewModifier` | `.timerWarning(_:)` | 残り時間少ない時の赤点滅 |
| `SuccessBounceModifier` | `ViewModifier` | `.successBounce(trigger:)` | 正解時バウンスアニメーション |
| `BrandedTitleView` | `View` | — | ナビバー `.principal` 用ブランドタイトル (icon + title + subtitle) |

---

## 10. 拡張メソッド詳細

### 10.1 DateExtensions

**ファイル**: `Extensions/DateExtensions.swift`

```swift
extension Date {
    var dateString: String              // "yyyy-MM-dd" フォーマット
    init?(dateString: String)           // "yyyy-MM-dd" からの初期化
    var isToday: Bool                   // Calendar.isDateInToday
    var isYesterday: Bool               // Calendar.isDateInYesterday
    func daysAgo(_ days: Int) -> Date   // 指定日数前
    func daysLater(_ days: Int) -> Date // 指定日数後
    func daysDifference(from other: Date) -> Int  // 日数差
    var shortDisplayString: String      // "今日" / "昨日" / "M/d"
}
```

### 10.2 ModelContextExtensions

**ファイル**: `Extensions/ModelContextExtensions.swift`

```swift
extension ModelContext {
    func fetchLogged<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>,
        caller: String = #function
    ) -> [T]
    
    func fetchFirstLogged<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>,
        caller: String = #function
    ) -> T?
    
    func fetchCountLogged<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>,
        caller: String = #function
    ) -> Int
}
```

**設計ポイント:**
- 全メソッドで `do-catch` によるエラーハンドリング
- エラー時は `AppLogger.swiftData.warning()` でログ出力
- エラー時の安全なデフォルト値: `[]` / `nil` / `0`
- `fetchFirstLogged` は自動で `fetchLimit = 1` を設定

---

## 11. アプリエントリポイント詳細

**ファイル**: `Java_StepApp.swift`

### 11.1 @main App 構造

```swift
@main
struct Java_ProApp: App {
    let modelContainer: ModelContainer
    
    init() {
        // 1. テスト環境検出
        // 2. ModelContainer 初期化 (5 段階フォールバック)
        // 3. CrashReportService.shared.start()
        // 4. Task { ContentService.shared.loadAllContentAsync() }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
        }
    }
}
```

### 11.2 テスト環境検出

```swift
if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
    // テスト実行中 → 空 Schema のインメモリコンテナ
    // TestDatabase.shared のコンテナと干渉しない
}
```

### 11.3 ModelContainer 初期化フォールバック

```
DEBUG:
  1. 通常初期化 (SQLite, JavaProSchemaV2, MigrationPlan)
  2. ストアファイル削除 → 再初期化
  3. インメモリモード
  4. 空 Schema (Schema()) のインメモリ ← 最終手段

RELEASE:
  1. 通常初期化 (SQLite, JavaProSchemaV2, MigrationPlan)
  2. インメモリモード + @AppStorage("dataRecoveryMode") = true
  3. 空 Schema (Schema()) のインメモリ ← 最終手段

※ 全段階で AppLogger.app.error() でエラーログ出力
```

---

## 12. リソースファイル詳細

### 12.1 JSON リソース概要

| ファイル | レコード数 | 説明 |
|---|---|---|
| `courses_index.json` | 34 コース | コースインデックス |
| `ch01_introduction.json` 〜 `ch38_spring_boot.json` | 34 ファイル / 169 レッスン / 575 クイズ | チャプターコンテンツ |
| `exam_questions_se11_silver_1.json` 等 | 8 ファイル / 640 問 | 模擬試験問題 |
| `glossary.json` | 202 語 | 用語辞典 |
| `practice_exercises.json` | 39 チャプター / 108 問 + 5 セクション | 実践演習 + 環境構築ガイド |

### 12.2 コース一覧 (34 コース)

#### Beginner (8 コース / 46 レッスン) — 無料

| 順序 | コース ID | タイトル | レッスン数 |
|---|---|---|---|
| 1 | ch01_introduction | Java入門 | 3 |
| 2 | ch02_output_variables | 出力と変数 | 6 |
| 3 | ch03_conditionals | 条件分岐 | 5 |
| 4 | ch04_loops | ループ処理 | 5 |
| 5 | ch05_methods | メソッド | 6 |
| 6 | ch06_arrays_lists | 配列とリスト | 7 |
| 7 | ch07_classes | クラスとオブジェクト | 7 |
| 8 | ch08_inheritance | 継承 | 7 |

#### Silver (9 コース / 43 レッスン) — 有料

| 順序 | コース ID | タイトル | レッスン数 |
|---|---|---|---|
| 9 | ch09_exceptions | 例外処理の基本 | 5 |
| 10 | ch12_polymorphism | ポリモーフィズム | 5 |
| 11 | ch13_abstract_interface | 抽象クラスとインタフェース | 5 |
| 12 | ch14_exceptions_advanced | 例外処理の応用 | 5 |
| 13 | ch15_java_api | Java API 活用 | 5 |
| 14 | ch16_lambda | ラムダ式 | 5 |
| 15 | ch17_modules | モジュールシステム入門 | 3 |
| 16 | ch18_silver_exercises | Silver総合演習 | 4 |
| 17 | ch19_java_se17 | Java SE 17新機能 | 6 |

#### Gold (17 コース / 80 レッスン) — 有料

| 順序 | コース ID | タイトル | レッスン数 |
|---|---|---|---|
| 18 | ch10_database | データベースの基本 | 6 |
| 19 | ch11_web | Web開発の基本 | 6 |
| 20 | ch20_nested_classes | ネストクラス | 4 |
| 21 | ch21_generics | ジェネリクス | 5 |
| 22 | ch22_collections | コレクションフレームワーク | 6 |
| 23 | ch23_functional | 関数型プログラミング | 5 |
| 24 | ch24_stream_api | Stream API | 6 |
| 25 | ch25_exceptions_applied | 例外処理の実践 | 4 |
| 26 | ch26_datetime | 日時API | 4 |
| 27 | ch27_concurrency | 並行処理 | 7 |
| 28 | ch28_io_nio | I/O と NIO | 5 |
| 29 | ch29_jdbc | JDBC | 4 |
| 30 | ch30_annotations | アノテーション | 3 |
| 31 | ch31_localization | ローカライゼーション | 3 |
| 32 | ch32_modules_advanced | モジュールシステム応用 | 4 |
| 33 | ch33_gold_exercises | Gold総合演習 | 4 |
| 34 | ch38_spring_boot | Spring Boot入門 | 4 |

### 12.3 Assets.xcassets

| アセット | 型 | 用途 |
|---|---|---|
| `AccentColor` | Color Set | システムアクセントカラー |
| `AppIcon` | App Icon Set | アプリアイコン |
| `Background` | Color Set | 背景色 (ライト/ダーク) |
| `CardBackground` | Color Set | カード背景色 (ライト/ダーク) |
| `TextPrimary` | Color Set | 主要テキスト色 |
| `TextSecondary` | Color Set | 副テキスト色 |
| `TextTertiary` | Color Set | 三次テキスト色 |

---

## 13. テストスイート詳細

**ファイル**: `Tests/Java_ProTests.swift`  
**フレームワーク**: Swift Testing (`@Test`, `@Suite`, `#expect`)

### 13.1 テストインフラ

```swift
enum TestDatabase {
    static let shared: ModelContainer = {
        let schema = Schema([
            UserLessonProgress.self, UserQuizHistory.self,
            UserDailyRecord.self, AppSettings.self,
            UserXPRecord.self, UserBadge.self,
            UserLevel.self, UserExamResult.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
```

> **設計ポイント**: `shared` プロパティで **プロセス内単一** のインメモリコンテナを共有。各テストで `@MainActor` + `ModelContext` を取得し、テスト後にクリーンアップ。

### 13.2 テストスイート一覧

| # | Suite | テスト数 | テスト対象 |
|---|---|---|---|
| 1 | `ContentModelsTests` | 7 | CertificationLevel / QuizType / CourseIndex / QuizChoice JSON デコード |
| 2 | `DateExtensionsTests` | 8 | dateString / isToday / isYesterday / daysAgo / daysLater / daysDifference |
| 3 | `UserModelsTests` | 9 | 各モデル CRUD / LessonStatus 変換 / AppSettings デフォルト / SwiftData 永続化 |
| 4 | `GamificationServiceTests` | 13 | levelThresholds / calculateLevel / XPAmount / badgeDefinitions / awardXP / awardBadge / progressToNextLevel / todayXP / titleForLevel |
| 5 | `ProgressServiceTests` | 8 | getSettings / startLesson / completeLesson / recordQuizAnswer / addStudySeconds / todayStats / streak |
| 6 | `ExamServiceTests` | 7 | examDefinitions / filtering by certLevel+JavaVersion / defaultPassingRate / saveResult / topicDisplayName |
| 7 | `ReviewServiceTests` | 5 | shouldReview / reviewCount / latestHistoryPublic / stage 進行 |
| 8 | `JSONResourcesTests` | 7 | courses_index.json デコード / glossary.json デコード / 全チャプター JSON / 全試験 JSON (正解検証付き) / quizId 一意性 |
| 9 | `ContentServiceTests` | 11 | loadAllContentAsync / getAllCourses / getCourse / getLessons / getQuizzes / searchGlossary / getNextLessonId / totalLessonCount / totalQuizCount |
| 10 | `SchemaVersionsTests` | 4 | V1/V2 schema model count / migration stages / migration plan / in-memory container |

### 13.3 テスト品質指標

| 指標 | 値 |
|---|---|
| 総テスト数 | 89 |
| テストスイート数 | 10 |
| テストコード行数 | 約 1,192 行 |
| 全テスト合格 | ✅ |
| 日本語正解バリデーション | ✅ (全試験問題の `isCorrect` 1 つ以上を検証) |
| quizId 一意性検証 | ✅ (575 + 640 = 1,215 個) |

---

## 改訂履歴

| バージョン | 日付 | 変更内容 |
|---|---|---|
| 1.0.0 | 2026-04-08 | 初版作成 |
| 2.0.0 | 2026-04-12 | 全面改訂。PracticeModels / PracticeService / AppLogger / CrashReportService / 4 ViewModel / GuideTourView / 実践演習ビュー / 環境構築ビュー / コンポーネント 6 種 / ThemeAnimations / ThemeComponents / ModelContextExtensions のセクション追加。Schema V2 詳細。テストスイート 10 個 (89 テスト)。コンテンツ統計全更新 (34 コース / 169 レッスン / 575 クイズ / 202 用語 / 108 演習 / 640 試験問題)。全コース一覧テーブル追加 |
| 2.0.1 | 2026-04-12 | ビュー数修正 (30 Views + 6 Components = 36 ファイル)。ExamSimulatorViewModel 状態プロパティ数・型修正。HomeViewModel 初期値修正。セクション 7.13 に 5 ビュー追加 (LessonListView / CodeExecutionView / QuizResultView / QuizAnswerViews / QuizChoiceStyle)。reminderHour 注釈追加 |
