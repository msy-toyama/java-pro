# 日本語ハードコード文字列 完全カタログ

> **対象:** `/Java Pro/` 内の全65 Swiftファイル  
> **除外:** コメント、os.Logger のログメッセージ、assertionFailure、デバッグ専用文字列、フォーマットパターン  
> **凡例:** `提案キー` | 日本語原文 | 英訳候補 | ファイル:行 | コンテキスト

---

## 1. Views/MainTabView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `tab.home` | ホーム | Home | Tab label |
| `tab.learn` | 学習 | Learn | Tab label |
| `tab.exam` | 試験対策 | Exam Prep | Tab label |
| `tab.profile` | マイページ | My Page | Tab label |

---

## 2. Views/HomeView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `home.title` | ホーム | Home | navigationTitle |
| `home.subtitle` | プロプロ | ProPro | subtitle / BrandedTitleView |
| `home.today_xp` | 今日のXP | Today's XP | XP統計ラベル |
| `home.streak_days` | 日連続 | day streak | ストリーク表示サフィックス |
| `home.daily_encouragement` | 毎日少しずつ学び続けましょう | Keep learning a little each day | 格言テキスト |
| `home.today_goal` | 今日の目標 | Today's Goal | 目標セクション |
| `home.goal_achieved` | 目標達成！お疲れさまです 🎉 | Goal achieved! Great work 🎉 | 達成メッセージ |
| `home.next_lesson` | 次のレッスン | Next Lesson | レッスン推薦カード |
| `home.today_study` | 今日の学習 | Today's Study | セクションヘッダー |
| `home.lessons` | レッスン | Lessons | 統計ラベル |
| `home.quizzes` | クイズ | Quizzes | 統計ラベル |
| `home.recent_badges` | 最近獲得したバッジ | Recent Badges | セクションヘッダー |
| `home.see_all` | すべて見る | See All | リンクテキスト |
| `home.review_pending` | 復習が %d件 あります | You have %d reviews pending | 復習通知カード |
| `home.review_reminder` | 忘れる前に復習しましょう | Review before you forget | 復習通知サブテキスト |
| `home.overall_progress` | 全体の進捗 | Overall Progress | プログレスセクション |
| `home.lessons_completed` | レッスン完了 | Lessons Completed | プログレスラベル |
| `home.accessibility.xp_progress` | 今日のXP: %d | Today's XP: %d | accessibility label |
| `home.accessibility.streak` | %d日連続学習中 | %d day streak | accessibility label |

---

## 3. Views/RootView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `root.save_error_title` | データ保存エラー | Data Save Error | アラートタイトル |
| `root.save_error_message` | データの保存に失敗しました。アプリを再起動してください。 | Failed to save data. Please restart the app. | アラートメッセージ |
| `root.load_error_title` | データの読み込みに問題が発生しました | An issue occurred loading data | アラートタイトル |
| `root.load_error_message` | 学習データの読み込みに失敗したため、一時的なデータで起動しています。アプリを再インストールしても直らない場合は、お問い合わせください。 | Learning data failed to load. Running with temporary data. If reinstalling doesn't help, please contact support. | アラートメッセージ |
| `root.content_error_title` | 教材データの読み込みエラー | Course Data Loading Error | アラートタイトル |
| `root.content_error_message` | 一部の教材データの読み込みに失敗しました。アプリを再起動してください。 | Some course data failed to load. Please restart the app. | アラートメッセージ |
| `root.launch_title` | プロプロ | ProPro | ロード画面タイトル |
| `root.launch_subtitle` | プロのJavaスキルを手に入れよう | Get pro Java skills | ロード画面サブタイトル |

---

## 4. Views/SettingsView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `settings.section.appearance` | 外観 | Appearance | セクションヘッダー |
| `settings.section.goals` | 学習目標 | Study Goals | セクションヘッダー |
| `settings.section.feedback` | フィードバック | Feedback | セクションヘッダー |
| `settings.section.reminder` | 学習リマインダー | Study Reminder | セクションヘッダー |
| `settings.section.plan` | プラン | Plan | セクションヘッダー |
| `settings.section.data` | データ管理 | Data Management | セクションヘッダー |
| `settings.section.app_info` | アプリ情報 | App Info | セクションヘッダー |
| `settings.theme` | テーマ | Theme | ピッカーラベル |
| `settings.theme.light` | ライト | Light | テーマ選択肢 |
| `settings.theme.dark` | ダーク | Dark | テーマ選択肢 |
| `settings.theme.system` | システム | System | テーマ選択肢 |
| `settings.cert_goal` | 目標資格 | Target Certification | ピッカーラベル |
| `settings.cert.beginner` | 入門（資格なし） | Beginner (No Cert) | 資格選択肢 |
| `settings.daily_goal` | 1日の目標: %d分 | Daily goal: %d min | スライダーラベル |
| `settings.haptic` | 触覚フィードバック | Haptic Feedback | トグルラベル |
| `settings.haptic_test` | 振動をテスト | Test Haptic | ボタンラベル |
| `settings.sound` | 効果音 | Sound Effects | トグルラベル |
| `settings.volume` | 音量: | Volume: | スライダーラベル |
| `settings.sound.correct` | 正解 | Correct | サウンドプレビュー |
| `settings.sound.incorrect` | 不正解 | Incorrect | サウンドプレビュー |
| `settings.sound.complete` | 完了 | Complete | サウンドプレビュー |
| `settings.sound.level_up` | レベルUP | Level Up | サウンドプレビュー |
| `settings.notification` | 毎日の通知 | Daily Notification | トグルラベル |
| `settings.notification_time` | 通知時間 | Notification Time | DatePicker ラベル |
| `settings.full_access` | フルアクセス | Full Access | ラベル |
| `settings.purchased` | 購入済み | Purchased | ステータスラベル |
| `settings.purchase_full` | フルアクセスを購入 | Purchase Full Access | ボタン |
| `settings.restore` | 購入を復元 | Restore Purchase | ボタン |
| `settings.reset_data` | 学習データをリセット | Reset Learning Data | ボタン |
| `settings.version` | バージョン | Version | ラベル |
| `settings.build` | ビルド | Build | ラベル |
| `settings.terms` | 利用規約 | Terms of Use | リンク |
| `settings.privacy` | プライバシーポリシー | Privacy Policy | リンク |
| `settings.oracle_disclaimer` | Oracle、Java、Java SEは、Oracle Corporation及びその関連会社の米国及びその他の国における登録商標です。本アプリはOracle社に認定されたものではなく、Oracle社とは一切関係ありません。 | Oracle, Java, and Java SE are registered trademarks of Oracle Corporation. This app is not endorsed by or affiliated with Oracle. | 免責事項テキスト |
| `settings.reset_confirm_title` | 学習データをリセット | Reset Learning Data | アラートタイトル |
| `settings.reset_confirm_message` | すべての学習進捗、クイズ履歴、XP、バッジがリセットされます。この操作は取り消せません。 | All progress, quiz history, XP, and badges will be reset. This cannot be undone. | アラートメッセージ |
| `settings.reset_button` | リセットする | Reset | アラートボタン |
| `settings.cancel` | キャンセル | Cancel | アラートボタン |
| `settings.reset_complete_title` | リセット完了 | Reset Complete | アラートタイトル |
| `settings.reset_complete_message` | 学習データがリセットされました。 | Learning data has been reset. | アラートメッセージ |
| `settings.reset_error_title` | エラー | Error | アラートタイトル |
| `settings.reset_error_message` | リセットに失敗しました。もう一度お試しください。 | Reset failed. Please try again. | アラートメッセージ |
| `settings.notification_denied_title` | 通知が許可されていません | Notifications Not Allowed | アラートタイトル |
| `settings.notification_denied_message` | 設定アプリから通知を許可してください。 | Please allow notifications in the Settings app. | アラートメッセージ |
| `settings.open_settings` | 設定を開く | Open Settings | アラートボタン |

---

## 5. Views/ProfileView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `profile.title` | マイページ | My Page | navigationTitle |
| `profile.settings` | 設定 | Settings | ToolbarItemボタン |
| `profile.xp_progress` | XP進捗 | XP Progress | セクションヘッダー |
| `profile.stats` | 学習統計 | Study Stats | セクションヘッダー |
| `profile.lessons_completed` | レッスン完了 | Lessons Completed | 統計ラベル |
| `profile.quiz_correct` | クイズ正解 | Quiz Correct | 統計ラベル |
| `profile.streak_days` | 連続日数 | Streak Days | 統計ラベル |
| `profile.badges_earned` | 獲得バッジ | Badges Earned | 統計ラベル |
| `profile.see_all` | すべて見る | See All | リンクテキスト |
| `profile.no_badges` | まだバッジを獲得していません\n学習を進めてバッジを集めましょう！ | No badges yet. Keep learning to earn them! | 空状態テキスト |
| `profile.locked_badges` | 未獲得バッジ | Locked Badges | セクションヘッダー |

---

## 6. Views/CourseListView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `learn.mode.textbook` | 教材学習 | Textbook Study | LearnMode enum |
| `learn.mode.practice` | 実践演習 | Practice Exercises | LearnMode enum |
| `learn.mode.label` | 学習モード | Study Mode | Picker label |
| `learn.title` | 学習 | Learn | navigationTitle |
| `learn.courses` | コース一覧 | Course List | セクションヘッダー |
| `learn.glossary` | 用語集 | Glossary | ナビゲーションリンク |
| `learn.category.basics` | Javaの基礎を学ぶ | Learn Java Basics | カテゴリタイトル |
| `learn.category.oop` | オブジェクト指向設計 | Object-Oriented Design | カテゴリタイトル |
| `learn.category.errorhandling` | エラーハンドリング | Error Handling | カテゴリタイトル |
| `learn.category.api` | Java標準ライブラリ活用 | Java Standard Library | カテゴリタイトル |
| `learn.category.generics` | データ構造とジェネリクス | Data Structures & Generics | カテゴリタイトル |
| `learn.category.functional` | 関数型とStream処理 | Functional & Stream Processing | カテゴリタイトル |
| `learn.category.web` | データベースとWeb開発 | Database & Web Development | カテゴリタイトル |
| `learn.category.concurrency` | 並行処理とファイルI/O | Concurrency & File I/O | カテゴリタイトル |
| `learn.category.modules` | モジュールと国際化 | Modules & i18n | カテゴリタイトル |
| `learn.category.exam` | 試験対策演習 | Exam Prep Exercises | カテゴリタイトル |
| `learn.category.other` | その他 | Other | カテゴリタイトル |
| `learn.premium` | プレミアム | Premium | ロックバッジ |

---

## 7. Views/LessonListView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `lesson_list.completed` | レッスン完了 | Lessons Completed | header subtitle |
| `lesson_list.status.not_started` | 未開始 | Not Started | ステータスラベル |
| `lesson_list.status.in_progress` | 学習中 | In Progress | ステータスラベル |
| `lesson_list.status.completed` | 完了 | Completed | ステータスラベル |

---

## 8. Views/LessonDetailView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `lesson_detail.back` | 一覧 | List | ToolbarItem戻るボタン |
| `lesson_detail.done` | 完了 | Done | ToolbarItemボタン |
| `lesson_detail.quiz_challenge` | クイズに挑戦 | Take Quiz | ボタン |
| `lesson_detail.quiz_count` | %d問のクイズで理解度をチェック | Check understanding with %d quiz questions | サブテキスト |
| `lesson_detail.complete_title` | レッスン完了！ | Lesson Complete! | 完了画面タイトル |
| `lesson_detail.complete_congrats` | おめでとうございます 🎉 | Congratulations 🎉 | 完了画面メッセージ |
| `lesson_detail.related_practice` | 関連する実践演習 | Related Practice Exercises | セクションヘッダー |
| `lesson_detail.not_found` | レッスンが見つかりません | Lesson not found | エラーメッセージ |
| `lesson_detail.load_error` | コンテンツの読み込みに失敗しました | Failed to load content | エラーメッセージ |

---

## 9. Views/QuizView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `quiz.no_quiz` | クイズなし | No Quiz | 空状態タイトル |
| `quiz.no_quiz_message` | このレッスンにはクイズがありません | This lesson has no quizzes | 空状態メッセージ |
| `quiz.close` | 閉じる | Close | ナビゲーションボタン |
| `quiz.correct` | 正解！ | Correct! | 回答フィードバック |
| `quiz.incorrect` | 不正解 | Incorrect | 回答フィードバック |
| `quiz.next` | 次の問題 | Next Question | ボタン |
| `quiz.show_result` | 結果を見る | View Results | ボタン |
| `quiz.dismiss_confirm_title` | クイズを中断しますか？ | Quit quiz? | アラートタイトル |
| `quiz.dismiss_confirm_cancel` | 中断する | Quit | アラートボタン |
| `quiz.dismiss_confirm_continue` | 続ける | Continue | アラートボタン |
| `quiz.dismiss_confirm_message` | 現在の進捗（%d/%d 正解）は保存されません。 | Current progress (%d/%d correct) will not be saved. | アラートメッセージ |

---

## 10. Views/QuizResultView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `quiz_result.title` | クイズ結果 | Quiz Results | navigationTitle |
| `quiz_result.close` | 閉じる | Close | ナビゲーションボタン |
| `quiz_result.accuracy` | 正解率: %d%% | Accuracy: %d%% | 結果表示 |
| `quiz_result.xp_earned` | +%d XP 獲得！ | +%d XP earned! | XP表示 |
| `quiz_result.perfect_bonus` | パーフェクトボーナス含む | Including perfect bonus | サブテキスト |
| `quiz_result.level_up` | レベルアップ！ | Level Up! | レベルアップ通知 |
| `quiz_result.new_badge` | 新しいバッジを獲得！ | New badge earned! | バッジ通知 |
| `quiz_result.perfect` | パーフェクト！ | Perfect! | 結果メッセージ（100%） |
| `quiz_result.great` | 素晴らしい！ | Great! | 結果メッセージ（≥80%） |
| `quiz_result.good` | いい感じです！ | Looking good! | 結果メッセージ（≥60%） |
| `quiz_result.retry_message` | もう一度挑戦しましょう | Let's try again | 結果メッセージ（<60%） |
| `quiz_result.next_lesson` | 次のレッスンへ | Next Lesson | ボタン |
| `quiz_result.next_content` | 次のコンテンツへ | Next Content | ボタン |
| `quiz_result.retry` | もう一度挑戦 | Try Again | ボタン |
| `quiz_result.close_button` | 閉じる | Close | ボタン |
| `quiz_result.practice_prompt` | 学んだ内容を実践しよう！ | Practice what you learned! | テキスト |
| `quiz_result.practice_button` | 実践演習に挑戦 | Try Practice Exercise | ボタン |

---

## 11. Views/CertificationView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `cert.title` | 試験対策 | Exam Prep | navigationTitle |
| `cert.exam_history` | 模擬試験の履歴 | Mock Exam History | ナビゲーションリンク |
| `cert.weak_points` | 弱点分析 | Weakness Analysis | ナビゲーションリンク |
| `cert.review` | 復習 | Review | ナビゲーションリンク |
| `cert.disclaimer` | ※本アプリの模擬試験はOracle公式ではありません… | *This app's mock exams are not official Oracle exams… | 免責事項テキスト |
| `cert.level` | 資格レベル | Certification Level | ピッカーラベル |
| `cert.java_version` | Javaバージョン | Java Version | ピッカーラベル |
| `cert.progress` | 学習進捗 | Study Progress | セクションヘッダー |
| `cert.passed` | 模擬試験に合格しました | Passed mock exam | 合格バッジ |
| `cert.lessons` | レッスン | Lessons | 進捗ラベル |
| `cert.quiz_correct` | クイズ正解 | Quiz Correct | 進捗ラベル |
| `cert.best_score` | 最高スコア | Best Score | 進捗ラベル |
| `cert.chapter_progress` | チャプター別進捗 | Chapter Progress | セクションヘッダー |
| `cert.mock_exam` | 模擬試験 | Mock Exam | セクションヘッダー |
| `cert.take_exam` | 受験 | Take Exam | ボタン |

---

## 12. Views/ExamSimulatorView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `exam.cancel` | 中断 | Cancel | ToolbarItemボタン |
| `exam.confirm_end_title` | 試験を終了しますか？ | End exam? | アラートタイトル |
| `exam.confirm_end_submit` | 終了して採点 | End & Grade | アラートボタン |
| `exam.confirm_end_continue` | 続ける | Continue | アラートボタン |
| `exam.answered` | 回答済み: | Answered: | 進捗表示 |
| `exam.loading` | 問題を読み込み中... | Loading questions... | ロード中表示 |
| `exam.title` | 模擬試験 | Mock Exam | navigationTitle |
| `exam.select_count` | %dつ選択してください | Select %d | 複数選択指示 |
| `exam.flag` | フラグ | Flag | ボタン |
| `exam.prev` | 前の問題 | Previous | ボタン |
| `exam.question_list` | 問題一覧 | Question List | ボタン |
| `exam.next_or_grade` | 次の問題 / 採点する | Next / Grade | ボタン（コンテキストにより変化） |
| `exam.list.answered` | 回答済み: | Answered: | 問題一覧統計 |
| `exam.list.flagged` | フラグ: | Flagged: | 問題一覧統計 |
| `exam.list.unanswered` | 未回答: | Unanswered: | 問題一覧統計 |
| `exam.list.end` | 試験を終了する | End Exam | ボタン |
| `exam.list.close` | 閉じる | Close | ボタン |

---

## 13. Views/ExamResultView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `exam_result.title` | 模擬試験結果 | Mock Exam Results | navigationTitle |
| `exam_result.pass` | 合格！ | Passed! | 結果表示 |
| `exam_result.fail` | 不合格 | Failed | 結果表示 |
| `exam_result.accuracy` | 正答率: | Accuracy: | ラベル |
| `exam_result.passing_line` | 合格ライン: | Passing Line: | ラベル |
| `exam_result.xp_earned` | +500 XP 獲得！ | +500 XP earned! | XP獲得表示 |
| `exam_result.topic_accuracy` | 分野別正答率 | Topic Accuracy | セクションヘッダー |
| `exam_result.time_spent` | 所要時間: | Time Spent: | ラベル |
| `exam_result.review_solutions` | 解答・解説を確認 | Review Solutions | ボタン |
| `exam_result.close` | 閉じる | Close | ボタン |

---

## 14. Views/ExamReviewView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `exam_review.title` | 解答・解説 | Solutions & Explanations | navigationTitle |
| `exam_review.close` | 閉じる | Close | ボタン |
| `exam_review.filter.all` | 全問題 | All Questions | フィルタータブ |
| `exam_review.filter.incorrect` | 不正解のみ | Incorrect Only | フィルタータブ |
| `exam_review.all_correct_title` | すべて正解です！ | All Correct! | 空状態タイトル |
| `exam_review.all_correct_message` | 不正解の問題はありません。 | No incorrect questions. | 空状態メッセージ |
| `exam_review.explanation` | 解説 | Explanation | セクションヘッダー |
| `exam_review.correct_answer` | 正解 | Correct Answer | ラベル |
| `exam_review.your_answer` | あなたの回答 | Your Answer | ラベル |
| `exam_review.prev` | 前へ | Previous | ボタン |
| `exam_review.next` | 次へ | Next | ボタン |

---

## 15. Views/ExamHistoryView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `exam_history.empty_title` | 受験履歴なし | No Exam History | 空状態タイトル |
| `exam_history.empty_message` | 模擬試験を受けると、結果がここに表示されます | Take a mock exam to see results here | 空状態メッセージ |
| `exam_history.title` | 受験履歴 | Exam History | navigationTitle |
| `exam_history.summary` | 成績サマリー | Performance Summary | セクションヘッダー |
| `exam_history.attempt_count` | %d回受験 | %d attempts | 受験回数 |
| `exam_history.pass` | 合格 | Passed | ラベル |
| `exam_history.best_accuracy` | 最高正答率 | Best Accuracy | ラベル |
| `exam_history.avg_accuracy` | 平均正答率 | Average Accuracy | ラベル |
| `exam_history.chart_title` | 正答率の推移 | Accuracy Trend | チャートタイトル |
| `exam_history.pass_label` | 合格 | Pass | チャートアノテーション |
| `exam_history.fail_label` | 不合格 | Fail | チャートアノテーション |
| `exam_history.accuracy_percent` | 正答率 %d%% | Accuracy %d%% | 履歴行表示 |

---

## 16. Views/WeakPointView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `weak.analyzing` | 分析中… | Analyzing… | ロード中表示 |
| `weak.none_title` | 弱点なし！ | No Weak Points! | 空状態タイトル |
| `weak.none_message` | すべての分野でよい正答率です。引き続き学習を続けましょう！ | Good accuracy in all areas. Keep it up! | 空状態メッセージ |
| `weak.title` | 弱点分析 | Weakness Analysis | navigationTitle |
| `weak.areas_count` | %d分野で改善の余地があります | %d areas need improvement | サブタイトル |
| `weak.threshold_note` | 正答率 80% 未満の分野を表示しています | Showing areas below 80% accuracy | 注記 |
| `weak.correct_rate` | 正解: | Correct: | ラベル |
| `weak.study_tips` | 学習のコツ | Study Tips | セクションヘッダー |
| `weak.tip.review_mistakes` | 間違えた問題を重点的に復習しましょう | Focus on reviewing mistakes | ヒント行 |
| `weak.tip.revisit_lessons` | 解説をもう一度読み直しましょう | Re-read the explanations | ヒント行 |
| `weak.tip.practice` | 関連する実践演習に取り組みましょう | Try related practice exercises | ヒント行 |
| `weak.action.study_weak` | 苦手分野のレッスンを復習する | Review weak area lessons | 推奨アクション |
| `weak.action.retake_exam` | 模擬試験を再受験する | Retake mock exam | 推奨アクション |

---

## 17. Views/ReviewView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `review.title` | 復習 | Review | navigationTitle |
| `review.start` | 復習を開始する | Start Review | ボタン |
| `review.how_it_works` | 復習の仕組み | How It Works | セクションヘッダー |
| `review.stage.immediate` | 間違えた直後 → 即復習 | Right after a mistake → Immediate review | ステージ説明 |
| `review.stage.24h` | 1回正解 → 24時間後に復習 | 1 correct → Review after 24h | ステージ説明 |
| `review.stage.3d` | 2回正解 → 3日後に復習 | 2 correct → Review after 3 days | ステージ説明 |
| `review.stage.7d` | 3回正解 → 7日後に復習 | 3 correct → Review after 7 days | ステージ説明 |
| `review.stage.done` | 4回正解 → 定着完了！ | 4 correct → Mastered! | ステージ説明 |
| `review.weak_themes` | 苦手なテーマ | Weak Themes | セクションヘッダー |
| `review.empty_title` | 復習するクイズはありません | No quizzes to review | 空状態タイトル |
| `review.empty_message` | レッスンを進めてクイズに回答すると\nここに復習が表示されます | Complete lessons and quizzes to see reviews here | 空状態メッセージ |

---

## 18. Views/BadgeListView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `badges.title` | バッジコレクション | Badge Collection | navigationTitle |
| `badges.tab.earned` | 獲得済み | Earned | タブラベル |
| `badges.tab.locked` | 未獲得 | Locked | タブラベル |
| `badges.progress` | %d / %d バッジ獲得 | %d / %d badges earned | プログレステキスト |
| `badges.completion` | コンプリート率 %d%% | Completion %d%% | プログレステキスト |
| `badges.locked` | 未獲得 | Locked | バッジステータス |
| `badges.earned_at` | に獲得 | Earned on | バッジ獲得日付プレフィックス |
| `badges.close` | 閉じる | Close | ボタン |

---

## 19. Views/OnboardingView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `onboarding.skip` | スキップ | Skip | ボタン |
| `onboarding.next` | 次へ | Next | ボタン |
| `onboarding.title` | プロプロ | ProPro | ブランドタイトル |
| `onboarding.tagline` | Javaを、一歩ずつ。 | Java, one step at a time. | キャッチコピー |
| `onboarding.description` | 初心者のために設計されたJava学習アプリ | A Java learning app for beginners | 説明文 |
| `onboarding.feature.lessons` | レッスン | Lessons | 機能チップ |
| `onboarding.feature.quizzes` | クイズ | Quizzes | 機能チップ |
| `onboarding.feature.review` | 復習 | Review | 機能チップ |
| `onboarding.feature.exam` | 模擬試験 | Mock Exam | 機能チップ |
| `onboarding.lesson_title` | レッスンで学ぶ | Learn with Lessons | ページタイトル |
| `onboarding.lesson_desc` | 解説→コード例→ポイントの流れで\nJavaの基礎を着実にマスター | Master Java fundamentals through\nexplanation → code → key points | 説明文 |
| `onboarding.quiz_title` | クイズで定着 | Retain with Quizzes | ページタイトル |
| `onboarding.review_title` | 忘却曲線で復習 | Review with Spaced Repetition | ページタイトル |
| `onboarding.pace_title` | あなたのペースで | At Your Own Pace | ページタイトル |
| `onboarding.pace_desc` | 1日の学習目標を選びましょう | Choose your daily study goal | 説明文 |
| `onboarding.goal.light.title` | ゆっくり | Casual | 目標タイトル |
| `onboarding.goal.light.desc` | 5分 / 1日 | 5 min / day | 目標説明 |
| `onboarding.goal.medium.title` | ちょうどいい | Moderate | 目標タイトル |
| `onboarding.goal.medium.desc` | 15分 / 1日 | 15 min / day | 目標説明 |
| `onboarding.goal.heavy.title` | がっつり | Intensive | 目標タイトル |
| `onboarding.goal.heavy.desc` | 30分 / 1日 | 30 min / day | 目標説明 |
| `onboarding.reminder` | 毎日のリマインダー通知 | Daily reminder notification | トグルテキスト |
| `onboarding.start` | 学習をはじめる | Start Learning | ボタン |
| `onboarding.section.overview` | 概要 | Overview | モックセクションカード |
| `onboarding.section.rule` | ルール | Rule | モックセクションカード |
| `onboarding.section.code` | コード | Code | モックセクションカード |
| `onboarding.section.point` | ポイント | Point | モックセクションカード |

---

## 20. Views/PaywallView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `paywall.title` | プロプロ フルアクセス | ProPro Full Access | タイトル |
| `paywall.subtitle` | 買い切りで全コンテンツが永久に使い放題 | One-time purchase for permanent full content | サブタイトル |
| `paywall.free_title` | 無料で使える機能 | Free Features | セクション |
| `paywall.free.lessons` | 入門〜継承の全レッスン（ch01-ch08） | All beginner-to-inheritance lessons (ch01-ch08) | 機能説明 |
| `paywall.free.quiz` | 各レッスンのクイズ | Quizzes for each lesson | 機能説明 |
| `paywall.free.review` | 忘却曲線ベースの復習 | Spaced repetition review | 機能説明 |
| `paywall.free.exam` | SE11 Silver 模擬試験 1 | SE11 Silver Mock Exam 1 | 機能説明 |
| `paywall.free.glossary` | 用語辞典 | Glossary | 機能説明 |
| `paywall.pro_title` | フルアクセスで解放 | Unlock with Full Access | セクション |
| `paywall.pro.all_lessons` | Silver / Gold 全レッスン | All Silver / Gold lessons | 機能説明 |
| `paywall.pro.all_exams` | 全8種の模擬試験 | All 8 mock exams | 機能説明 |
| `paywall.pro.practice` | 実践演習 | Practice exercises | 機能説明 |
| `paywall.pro.future` | 今後追加されるすべてのコンテンツ | All future content | 機能説明 |
| `paywall.purchased` | 購入済み — 全コンテンツが利用可能です | Purchased — All content available | 購入済みステータス |
| `paywall.one_time` | 買い切り | One-time purchase | ラベル |
| `paywall.one_time_desc` | 一度の購入で永久に使えます | One purchase for permanent access | 説明 |
| `paywall.buy_button` | でフルアクセスを購入 | Purchase full access for | ボタンテキスト |
| `paywall.loading` | 商品情報を読み込み中... | Loading product info... | ロード中 |
| `paywall.restore` | 以前の購入を復元 | Restore previous purchase | ボタン |
| `paywall.disclaimer` | ※購入はApple IDに紐付けられます… | *Purchases are tied to your Apple ID… | 免責事項 |
| `paywall.privacy` | プライバシーポリシー | Privacy Policy | リンク |
| `paywall.terms` | 利用規約 | Terms of Use | リンク |
| `paywall.full_access` | フルアクセス | Full Access | navigationTitle |

---

## 21. Views/GlossaryView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `glossary.title` | Java用語辞典 | Java Glossary | ヘッダータイトル |
| `glossary.count` | %d件の用語を収録 | %d terms included | サブタイトル |
| `glossary.search` | 用語を検索... | Search terms... | 検索プレースホルダー |
| `glossary.clear_search` | 検索をクリア | Clear search | ボタン |
| `glossary.no_results` | 「%@」に一致する用語が見つかりません | No terms matching "%@" | 空状態メッセージ |
| `glossary.nav_title` | 用語集 | Glossary | navigationTitle |
| `glossary.detail_title` | 用語詳細 | Term Detail | ディテールnav title |
| `glossary.close` | 閉じる | Close | ボタン |
| `glossary.related_lessons` | 関連レッスン | Related Lessons | セクションヘッダー |

---

## 22. Views/GuideTourView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `guide.begin` | はじめる | Get Started | 最終ステップボタン |
| `guide.next` | 次へ | Next | ボタン |
| `guide.skip` | スキップ | Skip | ボタン |
| `guide.home.welcome.title` | ようこそ プロプロ へ！ | Welcome to ProPro! | ステップタイトル |
| `guide.home.welcome.message` | このホーム画面があなたの学習ダッシュボードです。\n今日の学習状況がひと目でわかります。 | This home screen is your learning dashboard. See today's progress at a glance. | ステップメッセージ |
| `guide.home.xp.title` | XPを貯めてレベルアップ | Earn XP to Level Up | ステップタイトル（コンテキスト推定） |
| `guide.home.xp.message` | レッスンやクイズを完了するとXP（経験値）がもらえます。\nXPを貯めてレベルを上げましょう！ | Earn XP by completing lessons and quizzes. Level up by accumulating XP! | ステップメッセージ |
| `guide.home.streak.title` | 連続学習でストリーク獲得 | Earn Streaks with Daily Study | ステップタイトル |
| `guide.home.streak.message` | 毎日学習を続けると連続日数が増えます。\nストリークを伸ばしてモチベーションを維持しましょう！ | Study daily to build your streak. Keep going to stay motivated! | ステップメッセージ |
| `guide.home.badges.title` | バッジを集めよう | Collect Badges | ステップタイトル |
| `guide.home.badges.message` | 学習の節目や達成条件に応じてバッジが獲得できます。\nレッスン完了・ストリーク継続・試験合格など\nさまざまなバッジを目指しましょう！ | Earn badges at milestones — lesson completion, streaks, exam passes, and more! | ステップメッセージ |
| `guide.home.goal.title` | 目標を設定して学習 | Set Goals & Study | ステップタイトル |
| `guide.learn.courses.title` | 学習コース | Study Courses | ステップタイトル |
| `guide.learn.lesson_flow.title` | レッスンの進め方 | How Lessons Work | ステップタイトル |
| `guide.learn.lesson_flow.message` | 各レッスンは解説→コード例→クイズの流れです。\nクイズに正解するとレッスンが完了し、\nXPが獲得できます。 | Each lesson flows: explanation → code → quiz. Answer correctly to complete and earn XP. | ステップメッセージ |
| `guide.learn.pro.title` | 無料 & Proコンテンツ | Free & Pro Content | ステップタイトル |
| `guide.learn.pro.message` | 入門〜継承までのレッスンは無料で学べます。\nポリモーフィズム以降のコンテンツは\nProプランですべてアクセスできます。 | Beginner through inheritance lessons are free. Polymorphism onward requires Pro. | ステップメッセージ |
| `guide.learn.review.title` | 復習で定着 | Review for Retention | ステップタイトル |
| `guide.learn.review.message` | 完了したレッスンは時間をあけて復習できます。\n間隔反復学習で記憶の定着率がアップします。 | Review completed lessons over time. Spaced repetition boosts retention. | ステップメッセージ |
| `guide.practice.title` | 実践演習 | Practice Exercises | ステップタイトル |
| `guide.practice.message` | 学んだ知識を実際のコードで確認できます。\n各章のテーマに沿った\nコーディング課題に挑戦しましょう。 | Apply knowledge with real code. Try coding challenges for each chapter. | ステップメッセージ |
| `guide.practice.setup.title` | まずは環境構築 | Start with Environment Setup | ステップタイトル |
| `guide.practice.setup.message` | 最初に環境構築ガイドを見て\nJavaの実行環境を準備してください。\nWindows/Mac 両方の手順を用意しています。 | Check the setup guide first. We have steps for both Windows and Mac. | ステップメッセージ |
| `guide.practice.hints.title` | ヒントと解答付き | Hints & Solutions Included | ステップタイトル |
| `guide.practice.hints.message` | わからない問題にはヒントが用意されています。\n解答コードにはコメント付きで\n初学者でも理解できるようにしています。 | Hints available for tough problems. Solution code includes comments for beginners. | ステップメッセージ |
| `guide.practice.download.message` | 解答コードは .java ファイルとして\nダウンロードできます。\nお手元の環境で実行して動作を確認しましょう。 | Download solution code as .java files. Run them on your machine to verify. | ステップメッセージ |
| `guide.exam.title` | 試験対策モード | Exam Prep Mode | ステップタイトル |
| `guide.exam.mock.title` | 模擬試験にチャレンジ | Take Mock Exams | ステップタイトル |
| `guide.exam.mock.message` | 本番に近い形式の模擬試験を受けられます。\nタイマー付きで時間管理の練習もできます。\nSE 11 と SE 17 の両方に対応しています。 | Take exams in a realistic format with timers. Supports both SE 11 and SE 17. | ステップメッセージ |
| `guide.exam.disclaimer.title` | 非公式の模擬試験です | Unofficial Mock Exams | ステップタイトル |
| `guide.exam.disclaimer.message` | 本アプリの模擬試験はOracle公式ではありません。\n本番の出題傾向に基づいた学習用教材として\n作成しています。実力チェックにご活用ください。 | These exams are not official Oracle exams. They're study materials based on real exam trends. | ステップメッセージ |
| `guide.exam.analysis.title` | 弱点を分析 | Analyze Weaknesses | ステップタイトル |
| `guide.exam.analysis.message` | 模擬試験の結果からトピック別の正答率を分析し、\n弱点を可視化します。\n苦手分野を重点的に復習しましょう。 | Analyze topic accuracy from exam results to visualize weaknesses. Focus on weak areas. | ステップメッセージ |
| `guide.exam.goal.title` | 合格を目指そう | Aim to Pass | ステップタイトル |
| `guide.exam.goal.message` | 合格ラインは正答率%d%%です。\n模擬試験を繰り返し受けて\n確実に合格できる力を身につけましょう！ | Passing line is %d%% accuracy. Take mock exams repeatedly to build confidence! | ステップメッセージ |
| `guide.accessibility.bg` | ガイドツアー背景 | Guide tour background | accessibility label |
| `guide.accessibility.bg_hint` | タップして次のステップへ進みます | Tap to proceed to the next step | accessibility hint |
| `guide.accessibility.step` | ステップ %d / %d | Step %d / %d | accessibility label |
| `guide.accessibility.end_hint` | ガイドツアーを終了してアプリを開始します | End guide tour and start the app | accessibility hint |
| `guide.accessibility.next_hint` | 次のガイドステップに進みます | Proceed to next guide step | accessibility hint |
| `guide.accessibility.skip_hint` | ガイドツアーをスキップします | Skip guide tour | accessibility hint |

---

## 23. Views/PracticeListView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `practice.env_guide` | 環境構築ガイド | Environment Setup Guide | ナビゲーションリンクタイトル |
| `practice.env_guide_desc` | Java / DB / Web の開発環境セットアップ | Set up Java / DB / Web dev environment | サブタイトル |
| `practice.premium` | プレミアム | Premium | ロックバッジ |
| `practice.difficulty.beginner` | 初級 | Beginner | 難易度ラベル |
| `practice.difficulty.intermediate` | 中級 | Intermediate | 難易度ラベル |
| `practice.difficulty.advanced` | 上級 | Advanced | 難易度ラベル |

---

## 24. Views/PracticeDetailView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `practice_detail.free` | 無料 | Free | バッジ |
| `practice_detail.problem` | 問題 | Problem | セクションヘッダー |
| `practice_detail.expected_output` | 期待される出力 | Expected Output | セクションヘッダー |
| `practice_detail.show_hint` | ヒントを見る | Show Hint | ボタン |
| `practice_detail.show_solution` | 解答を見る | Show Solution | ボタン |
| `practice_detail.hide_solution` | 解答を隠す | Hide Solution | ボタン |
| `practice_detail.solution_code` | 解答コード | Solution Code | セクションヘッダー |
| `practice_detail.solution_explanation` | 解答の詳細解説 | Solution Explanation | セクションヘッダー |
| `practice_detail.download` | をダウンロード | Download | ボタンサフィックス |
| `practice_detail.file_error` | ファイルの生成に失敗しました | Failed to generate file | エラーメッセージ |

---

## 25. Views/EnvironmentSetupView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `env_setup.title` | 環境構築ガイド | Environment Setup Guide | navigationTitle |
| `env_setup.header` | 開発環境を準備しよう | Prepare Your Dev Environment | ヘッダーテキスト |
| `env_setup.desc` | 必要な環境構築を選んでください。ステップに沿って進めれば、初心者でも安心です。 | Choose the environment to set up. Follow the steps — easy for beginners. | 説明文 |
| `env_setup.step` | ステップ | Step | ステップラベルプレフィックス |

---

## 26. Views/EnvironmentSetupDetailView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `env_setup_detail.step` | ステップ | Step | ステップラベルプレフィックス |

---

## 27. Views/CodeExecutionView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `execution.success` | 実行結果（正常） | Execution Result (Success) | 結果ラベル |
| `execution.success_mismatch` | 実行結果（正常・期待と異なる出力） | Execution Result (Success, Unexpected Output) | 結果ラベル |
| `execution.error` | 実行結果（エラー） | Execution Result (Error) | 結果ラベル |
| `execution.error_occurred` | エラーが発生しました | An error occurred | エラーテキスト |
| `execution.no_output` | (出力なし) | (No output) | 空出力テキスト |
| `execution.your_result` | あなたの選択の実行結果 | Execution result of your choice | セクションタイトル |
| `execution.correct_result` | 正解の実行結果 | Correct execution result | セクションタイトル |
| `execution.this_code_result` | このコードの実行結果 | This code's execution result | セクションタイトル |
| `execution.fixed_result` | 修正後の実行結果 | Execution result after fix | セクションタイトル |
| `execution.fixed_success` | 修正後（正常実行） | After fix (Successful execution) | ラベル |

---

## 28. Views/QuizAnswerViews.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `quiz_answer.your_order` | あなたの並び順： | Your order: | 並び替え問題ラベル |
| `quiz_answer.undo` | 取り消す | Undo | ボタン |
| `quiz_answer.submit_order` | この順番で回答する | Submit this order | ボタン |
| `quiz_answer.select_count` | %dつ選択してください | Select %d | 複数選択指示 |
| `quiz_answer.submit_selection` | この選択で回答する（%d個選択中） | Submit selection (%d selected) | ボタン |
| `quiz_answer.submit_combination` | この組み合わせで回答する | Submit this combination | ボタン |

---

## 29. Views/Components/SectionView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `section.type.overview` | 概要 | Overview | セクションタイプラベル |
| `section.type.rule` | ルール | Rule | セクションタイプラベル |
| `section.type.code` | コード | Code | セクションタイプラベル |
| `section.type.point` | ポイント | Key Point | セクションタイプラベル |
| `section.type.tip` | 補足 | Tip | セクションタイプラベル |

---

## 30. Views/Components/LevelUpOverlayView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `level_up.tap_continue` | タップして続ける | Tap to continue | 指示テキスト |
| `level_up.message` | レベルアップ！レベル%d… | Level Up! Level %d… | レベルアップメッセージ |

---

## 31. Views/Components/GlossaryPopupView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `glossary_popup.related` | 関連レッスン | Related Lessons | セクションヘッダー |
| `glossary_popup.close` | 閉じる | Close | ボタン |

---

## 32. Views/Components/CodeBlockView.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `code_block.copied` | コピー済み | Copied | ボタン状態テキスト |
| `code_block.copy` | コピー | Copy | ボタンテキスト |
| `code_block.accessibility.copied` | コピー済み | Copied | accessibility label |
| `code_block.accessibility.copy` | コードをコピー | Copy code | accessibility label |

---

## 33. Services/GamificationService.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `level.title.1` | Java見習い | Java Apprentice | レベル称号（Lv1-2） |
| `level.title.3` | Hello Worlder | Hello Worlder | レベル称号（Lv3-4） |
| `level.title.5` | コード初心者 | Code Beginner | レベル称号（Lv5-7） |
| `level.title.8` | 配列探検家 | Array Explorer | レベル称号（Lv8-9） |
| `level.title.10` | 変数マスター | Variable Master | レベル称号（Lv10-12） |
| `level.title.13` | メソッド使い | Method User | レベル称号（Lv13-14） |
| `level.title.15` | ループ使い | Loop User | レベル称号（Lv15-17） |
| `level.title.18` | クラス設計士 | Class Designer | レベル称号（Lv18-19） |
| `level.title.20` | オブジェクト職人 | Object Craftsman | レベル称号（Lv20-22） |
| `level.title.23` | 例外ハンドラー | Exception Handler | レベル称号（Lv23-24） |
| `level.title.25` | Silver挑戦者 | Silver Challenger | レベル称号（Lv25-27） |
| `level.title.28` | API探求者 | API Explorer | レベル称号（Lv28-29） |
| `level.title.30` | ラムダ使い | Lambda User | レベル称号（Lv30-32） |
| `level.title.33` | Streamマスター | Stream Master | レベル称号（Lv33-34） |
| `level.title.35` | 並行処理者 | Concurrency Handler | レベル称号（Lv35-37） |
| `level.title.38` | Gold挑戦者 | Gold Challenger | レベル称号（Lv38-39） |
| `level.title.40` | モジュール設計士 | Module Designer | レベル称号（Lv40-42） |
| `level.title.43` | アーキテクト | Architect | レベル称号（Lv43-44） |
| `level.title.45` | Java賢者 | Java Sage | レベル称号（Lv45-47） |
| `level.title.48` | 伝説のコーダー | Legendary Coder | レベル称号（Lv48-49） |
| `level.title.50` | Javaマスター | Java Master | レベル称号（Lv50） |
| `badge.first_lesson.name` | はじめの一歩 | First Step | バッジ名 |
| `badge.first_lesson.desc` | 最初のレッスンを完了 | Complete first lesson | バッジ説明 |
| `badge.lesson_10.name` | 学習家 | Studious | バッジ名 |
| `badge.lesson_10.desc` | 10レッスン完了 | Complete 10 lessons | バッジ説明 |
| `badge.lesson_25.name` | 勉強熱心 | Eager Learner | バッジ名 |
| `badge.lesson_25.desc` | 25レッスン完了 | Complete 25 lessons | バッジ説明 |
| `badge.lesson_50.name` | 知識の泉 | Fountain of Knowledge | バッジ名 |
| `badge.lesson_50.desc` | 50レッスン完了 | Complete 50 lessons | バッジ説明 |
| `badge.lesson_100.name` | 学問の達人 | Master Scholar | バッジ名 |
| `badge.lesson_100.desc` | 100レッスン完了 | Complete 100 lessons | バッジ説明 |
| `badge.all_ch01.name` | 入門マスター | Intro Master | バッジ名 |
| `badge.all_ch01.desc` | Chapter 01 完全制覇 | Complete all Chapter 01 | バッジ説明 |
| `badge.oop_master.name` | OOPマスター | OOP Master | バッジ名 |
| `badge.oop_master.desc` | OOP全チャプター完了 | Complete all OOP chapters | バッジ説明 |
| `badge.all_lessons.name` | 全レッスン制覇 | All Lessons Complete | バッジ名 |
| `badge.all_lessons.desc` | 全レッスン完了 | Complete all lessons | バッジ説明 |
| `badge.quiz_10.name` | クイズ初心者 | Quiz Beginner | バッジ名 |
| `badge.quiz_10.desc` | 10問正解 | 10 correct answers | バッジ説明 |
| `badge.quiz_50.name` | クイズ好き | Quiz Lover | バッジ名 |
| `badge.quiz_50.desc` | 50問正解 | 50 correct answers | バッジ説明 |
| `badge.quiz_100.name` | クイズマスター | Quiz Master | バッジ名 |
| `badge.quiz_100.desc` | 100問正解 | 100 correct answers | バッジ説明 |
| `badge.quiz_200.name` | クイズエキスパート | Quiz Expert | バッジ名 |
| `badge.quiz_200.desc` | 200問正解 | 200 correct answers | バッジ説明 |
| `badge.quiz_500.name` | クイズの鬼 | Quiz Demon | バッジ名 |
| `badge.quiz_500.desc` | 500問正解 | 500 correct answers | バッジ説明 |
| `badge.perfect_3.name` | パーフェクト×3 | Perfect ×3 | バッジ名 |
| `badge.perfect_3.desc` | 3回全問正解 | 3 perfect scores | バッジ説明 |
| `badge.perfect_10.name` | パーフェクト×10 | Perfect ×10 | バッジ名 |
| `badge.perfect_10.desc` | 10回全問正解 | 10 perfect scores | バッジ説明 |
| `badge.speed_demon.name` | スピードスター | Speed Star | バッジ名 |
| `badge.speed_demon.desc` | 30秒以内に全問正解 | All correct within 30 seconds | バッジ説明 |
| `badge.error_finder.name` | バグハンター | Bug Hunter | バッジ名 |
| `badge.error_finder.desc` | エラー発見問題10問正解 | 10 correct error-finding questions | バッジ説明 |
| `badge.streak_3.name` | 3日連続 | 3 Day Streak | バッジ名 |
| `badge.streak_3.desc` | 3日連続学習 | 3 consecutive days of study | バッジ説明 |
| `badge.streak_7.name` | 1週間連続 | 1 Week Streak | バッジ名 |
| `badge.streak_7.desc` | 7日連続学習 | 7 consecutive days of study | バッジ説明 |
| `badge.streak_14.name` | 2週間連続 | 2 Week Streak | バッジ名 |
| `badge.streak_14.desc` | 14日連続学習 | 14 consecutive days of study | バッジ説明 |
| `badge.streak_30.name` | 30日連続 | 30 Day Streak | バッジ名 |
| `badge.streak_30.desc` | 30日連続学習！ | 30 consecutive days of study! | バッジ説明 |
| `badge.streak_50.name` | 50日の絆 | 50 Day Bond | バッジ名 |
| `badge.streak_50.desc` | 50日連続学習 | 50 consecutive days of study | バッジ説明 |
| `badge.streak_100.name` | 100日の絆 | 100 Day Bond | バッジ名 |
| `badge.streak_100.desc` | 100日連続学習 | 100 consecutive days of study | バッジ説明 |
| `badge.streak_365.name` | 年間皆勤 | Year-round Attendance | バッジ名 |
| `badge.streak_365.desc` | 365日連続学習 | 365 consecutive days of study | バッジ説明 |
| `badge.silver_ready.name` | Silver準備完了 | Silver Ready | バッジ名 |
| `badge.silver_ready.desc` | Silver範囲の全レッスン完了 | Complete all Silver-range lessons | バッジ説明 |
| `badge.silver_pass.name` | Silver合格 | Silver Pass | バッジ名 |
| `badge.silver_pass.desc` | Silver模擬試験で合格点 | Pass Silver mock exam | バッジ説明 |
| `badge.gold_ready.name` | Gold準備完了 | Gold Ready | バッジ名 |
| `badge.gold_ready.desc` | Gold範囲の全レッスン完了 | Complete all Gold-range lessons | バッジ説明 |
| `badge.gold_pass.name` | Gold合格 | Gold Pass | バッジ名 |
| `badge.gold_pass.desc` | Gold模擬試験で合格点 | Pass Gold mock exam | バッジ説明 |
| `badge.xp_1000.name` | XP 1,000突破 | XP 1,000 Reached | バッジ名 |
| `badge.xp_1000.desc` | 累計1,000 XP獲得 | Earned 1,000 total XP | バッジ説明 |
| `badge.xp_5000.name` | XP 5,000突破 | XP 5,000 Reached | バッジ名 |
| `badge.xp_5000.desc` | 累計5,000 XP獲得 | Earned 5,000 total XP | バッジ説明 |
| `badge.xp_10000.name` | XP 10,000突破 | XP 10,000 Reached | バッジ名 |
| `badge.xp_10000.desc` | 累計10,000 XP獲得 | Earned 10,000 total XP | バッジ説明 |
| `badge.xp_30000.name` | XPマスター | XP Master | バッジ名 |
| `badge.xp_30000.desc` | 累計30,000 XP獲得 | Earned 30,000 total XP | バッジ説明 |

---

## 34. Services/NotificationService.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `notification.title` | 今日もJavaを学ぼう 📚 | Let's learn Java today 📚 | 通知タイトル |
| `notification.body.1` | 5分だけでOK！今日のレッスンが待っています。 | Just 5 minutes! Today's lesson is waiting. | 通知本文 |
| `notification.body.2` | 昨日の復習が溜まっています。サクッと確認しましょう。 | Yesterday's reviews are piling up. Let's check quickly. | 通知本文 |
| `notification.body.3` | 継続は力なり！今日もJavaを一歩進めませんか？ | Consistency is key! Take one more step in Java today? | 通知本文 |
| `notification.body.4` | スキマ時間にクイズ1問だけ解いてみましょう。 | Try solving just one quiz in your free time. | 通知本文 |
| `notification.body.5` | 毎日続けることが上達の近道です。 | Daily practice is the fastest path to mastery. | 通知本文 |
| `notification.body.6` | 今日はどの章を学びますか？ | Which chapter will you study today? | 通知本文 |

---

## 35. Services/ExamService.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `exam_def.se11_silver_1.title` | SE11 Silver 模擬試験 1 | SE11 Silver Mock Exam 1 | 試験タイトル |
| `exam_def.se11_silver_1.subtitle` | 1Z0-815 出題範囲対応 · 80問 / 180分 | 1Z0-815 scope · 80 questions / 180 min | 試験サブタイトル |
| `exam_def.se11_silver_2.title` | SE11 Silver 模擬試験 2 | SE11 Silver Mock Exam 2 | 試験タイトル |
| `exam_def.se11_gold_1.title` | SE11 Gold 模擬試験 1 | SE11 Gold Mock Exam 1 | 試験タイトル |
| `exam_def.se11_gold_2.title` | SE11 Gold 模擬試験 2 | SE11 Gold Mock Exam 2 | 試験タイトル |
| `exam_def.se17_silver_1.title` | SE17 Silver 模擬試験 1 | SE17 Silver Mock Exam 1 | 試験タイトル |
| `exam_def.se17_silver_1.subtitle` | 1Z0-825 出題範囲対応 · 60問 / 90分 | 1Z0-825 scope · 60 questions / 90 min | 試験サブタイトル |
| `exam_def.se17_silver_2.title` | SE17 Silver 模擬試験 2 | SE17 Silver Mock Exam 2 | 試験タイトル |
| `exam_def.se17_gold_1.title` | SE17 Gold 模擬試験 1 | SE17 Gold Mock Exam 1 | 試験タイトル |
| `exam_def.se17_gold_2.title` | SE17 Gold 模擬試験 2 | SE17 Gold Mock Exam 2 | 試験タイトル |
| `exam_def.se11_gold.subtitle` | 1Z0-816 出題範囲対応 · 80問 / 180分 | 1Z0-816 scope · 80 questions / 180 min | 試験サブタイトル |
| `exam_def.se17_gold.subtitle` | 1Z0-826 出題範囲対応 · 60問 / 90分 | 1Z0-826 scope · 60 questions / 90 min | 試験サブタイトル |
| `topic.java_basics` | Javaの基本 | Java Basics | トピック表示名 |
| `topic.variables` | 変数・データ型 | Variables & Data Types | トピック表示名 |
| `topic.operators` | 演算子 | Operators | トピック表示名 |
| `topic.control_flow` | 条件分岐 | Conditionals | トピック表示名 |
| `topic.loops` | ループ | Loops | トピック表示名 |
| `topic.arrays` | 配列 | Arrays | トピック表示名 |
| `topic.methods` | メソッド | Methods | トピック表示名 |
| `topic.strings` | 文字列 | Strings | トピック表示名 |
| `topic.classes` | クラス | Classes | トピック表示名 |
| `topic.encapsulation` | カプセル化 | Encapsulation | トピック表示名 |
| `topic.inheritance` | 継承 | Inheritance | トピック表示名 |
| `topic.polymorphism` | ポリモーフィズム | Polymorphism | トピック表示名 |
| `topic.interfaces` | インターフェース | Interfaces | トピック表示名 |
| `topic.exceptions` | 例外処理 | Exception Handling | トピック表示名 |
| `topic.java_api` | Java API | Java API | トピック表示名 |
| `topic.lambda` | ラムダ式 | Lambda Expressions | トピック表示名 |
| `topic.modules` | モジュール | Modules | トピック表示名 |
| `topic.generics` | ジェネリクス | Generics | トピック表示名 |
| `topic.collections` | コレクション | Collections | トピック表示名 |
| `topic.streams` | Stream API | Stream API | トピック表示名 |
| `topic.concurrency` | 並行処理 | Concurrency | トピック表示名 |
| `topic.io_nio` | I/O・NIO.2 | I/O & NIO.2 | トピック表示名 |
| `topic.jdbc` | JDBC | JDBC | トピック表示名 |
| `topic.annotations` | アノテーション | Annotations | トピック表示名 |
| `topic.localization` | ローカライゼーション | Localization | トピック表示名 |
| `topic.nested_classes` | ネストクラス | Nested Classes | トピック表示名 |
| `topic.var_type_inference` | var型推論 | var Type Inference | トピック表示名 |
| `topic.switch_expressions` | switch式 | Switch Expressions | トピック表示名 |
| `topic.sealed_classes` | sealedクラス | Sealed Classes | トピック表示名 |
| `topic.pattern_matching` | パターンマッチング | Pattern Matching | トピック表示名 |
| `topic.general` | その他 | Other | トピック表示名 |

---

## 36. Services/StoreService.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `store.error.load_failed` | 商品情報の取得に失敗しました。通信状況をご確認ください。 | Failed to load product info. Check your connection. | エラーメッセージ |
| `store.error.not_found` | 商品が見つかりません | Product not found | エラーメッセージ |
| `store.error.pending` | 購入の承認を待っています | Waiting for purchase approval | エラーメッセージ |
| `store.error.unknown` | 予期しない購入結果が返されました。しばらく待ってから再試行してください | Unexpected purchase result. Please wait and try again. | エラーメッセージ |
| `store.error.purchase` | 購入エラー: %@ | Purchase error: %@ | エラーメッセージ |
| `store.error.restore` | 復元エラー: %@ | Restore error: %@ | エラーメッセージ |

---

## 37. Services/SaveErrorNotifier.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `save_error.message` | データの保存に失敗しました。 | Failed to save data. | エラーメッセージ |

---

## 38. Services/CrashReportService.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `crash.summary.crash` | クラッシュ: %d件 | Crash: %d reports | 診断サマリ |
| `crash.summary.hang` | ハング: %d件 | Hang: %d reports | 診断サマリ |
| `crash.summary.disk` | ディスク書込超過: %d件 | Disk write excess: %d reports | 診断サマリ |

---

## 39. ViewModels/HomeViewModel.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `home.streak.0` | 今日も学びましょう！ | Let's learn today! | ストリークメッセージ（0日） |
| `home.streak.1` | 学習スタート！ | Study started! | ストリークメッセージ（1日） |
| `home.streak.short` | いい調子です！ | Good pace! | ストリークメッセージ（2-6日） |
| `home.streak.medium` | 素晴らしい継続力！ | Amazing consistency! | ストリークメッセージ（7-29日） |
| `home.streak.long` | 圧巻の継続です！ | Incredible dedication! | ストリークメッセージ（30日以上） |
| `home.default_title` | Java見習い | Java Apprentice | デフォルトレベル称号 |

---

## 40. Models/ContentModels.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `quiz_type.four_choice` | 4択問題 | Multiple Choice | クイズタイプラベル |
| `quiz_type.multi_choice` | 複数選択 | Multi-Select | クイズタイプラベル |
| `quiz_type.fill_blank` | 穴埋め問題 | Fill in the Blank | クイズタイプラベル |
| `quiz_type.reorder` | 並び替え問題 | Reorder | クイズタイプラベル |
| `quiz_type.output_predict` | 出力予想 | Output Prediction | クイズタイプラベル |
| `quiz_type.error_find` | エラー発見 | Error Finding | クイズタイプラベル |
| `quiz_type.code_complete` | コード補完 | Code Completion | クイズタイプラベル |
| `quiz_type.exam_simulator` | 試験形式 | Exam Format | クイズタイプラベル |

---

## 41. Extensions/DateExtensions.swift

| キー | 日本語 | 英訳候補 | コンテキスト |
|------|--------|----------|-------------|
| `date.today` | 今日 | Today | 短い日付表示 |
| `date.yesterday` | 昨日 | Yesterday | 短い日付表示 |

---

## ファイル別 日本語文字列なし（確認済み）

以下のファイルはUI表示用の日本語ハードコード文字列が**ゼロ**であることを確認済み：

- Models/UserModels.swift（enum rawValueは英語、SwiftDataプロパティのみ）
- Models/PracticeModels.swift（構造体定義のみ）
- Models/JavaStepSchemaVersions.swift（Schema定義のみ）
- Services/ProgressService.swift（ロジックのみ、UI文字列なし）
- Services/ReviewService.swift（ロジックのみ）
- Services/PracticeService.swift（ロジックのみ）
- Services/SoundService.swift（音声生成のみ）
- Services/AppLogger.swift（Logger定義のみ）
- Services/AnalyticsService.swift（ロジックのみ）
- Services/AppearanceManager.swift（外観制御のみ）
- Services/ContentService.swift（JSONロード/キャッシュのみ）
- ViewModels/QuizViewModel.swift（ロジックのみ）
- ViewModels/SettingsViewModel.swift（ロジックのみ）
- ViewModels/ExamSimulatorViewModel.swift（ロジックのみ）
- Theme/Theme.swift（定数定義のみ）
- Theme/ThemeComponents.swift（ViewModifier定義のみ）
- Theme/ThemeAnimations.swift（アニメーション定義のみ）
- Extensions/ModelContextExtensions.swift（ヘルパーのみ）
- Views/Components/RichBodyView.swift（テキストレンダリングのみ）
- Views/Components/ConfettiView.swift（アニメーションのみ）
- Views/Components/JavaSyntaxHighlighter.swift（構文ハイライトのみ）
- Views/Components/QuizChoiceStyle.swift（スタイル定義のみ）
- Views/Components/PreviewHelpers.swift（プレビュー用のみ）
- Java_StepApp.swift（アプリエントリポイント、UI文字列なし）

---

## 統計サマリー

| カテゴリ | ファイル数 | 文字列数（概算） |
|----------|-----------|-----------------|
| Views (メイン) | 20 | ~280 |
| Views/Components | 4 | ~15 |
| Services | 5 | ~55 |
| ViewModels | 1 | ~7 |
| Models | 1 | ~8 |
| Extensions | 1 | ~2 |
| **合計** | **32ファイル** | **~367文字列** |
