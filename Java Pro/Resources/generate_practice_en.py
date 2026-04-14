#!/usr/bin/env python3
"""Generate practice_exercises_en.json from practice_exercises.json.
Translates all Japanese text fields to English.
"""
import json, copy, re, os, sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# =============================================================
# Part 1: Solution Code Translation (comments + string literals)
# =============================================================
# Import the translation logic from existing helper
sys.path.insert(0, SCRIPT_DIR)
from translate_exercises import translate_solution_code
from exercise_translations import EX_TRANS

def translate_expected_output(text):
    """Apply common Japanese→English replacements to expectedOutput."""
    if not text:
        return text
    reps = [
        # ===== FULL-LINE / LONG PHRASES FIRST (avoid partial replacement) =====
        ("曜日番号: 3\n水曜日", "Day number: 3\nWednesday"),
        ("7 は odd です", "7 is odd"),
        ("ワンワン！", "Woof!"),
        ("ニャー！", "Meow!"),
        ("レポート: 月次報告書", "Report: Monthly Report"),
        ("請求書: #1234 ¥50,000", "Invoice: #1234 ¥50,000"),
        ("円の面積: 78.54", "Circle area: 78.54"),
        ("長方形の面積: 24.00", "Rectangle area: 24.00"),
        ("電気自動車の燃料: 電気", "Electric car fuel: Electric"),
        ("ガソリン車の燃料: ガソリン", "Gasoline car fuel: Gasoline"),
        ("年齢 25: OK", "Age 25: OK"),
        ("原因: java.lang.NumberFormatException", "Cause: java.lang.NumberFormatException"),
        ("原因: フォーマットが不正です: '='がありません", "Cause: Invalid format: '=' is missing"),
        ("原因: 値の型が不正です: 'abc'は整数ではありません", "Cause: Invalid value type: 'abc' is not an integer"),
        ("原因: ", "Cause: "),
        ("2026年01月15日", "2026/01/15"),
        ("2026年02月14日", "2026/02/14"),
        ("2026年1月15日 木曜日", "2026/1/15 Thursday"),
        ("偶数の2乗の合計: ", "Sum of squares of even numbers: "),
        ("-- クエリ結果（想定） --", "-- Query results (expected) --"),
        ("開発部", "Development"),
        ("営業部", "Sales"),
        ("人事部", "HR"),
        ("→ こんにちは、Taroさん！", "→ Hello, Taro!"),
        ("スレッドA", "Thread A"),
        ("スレッドB", "Thread B"),
        ("(出力順は実行ごとに変わります)", "(Output order varies per execution)"),
        ("// com.mylib.internal は非公開", "// com.mylib.internal is private"),
        ("結果: 勝ち！", "Result: You win!"),
        ("合計収入: 350000円", "Total income: 350000 yen"),
        ("合計支出: 185000円", "Total expenses: 185000 yen"),
        ("合計収入: ", "Total income: "),
        ("合計支出: ", "Total expenses: "),
        ("0で割ることはできません", "Cannot divide by zero"),
        ("山田太郎（正社員）: 300000円", "Taro Yamada (Full-time): 300000 yen"),
        ("鈴木花子（パート）: 160000円", "Hanako Suzuki (Part-time): 160000 yen"),
        ("正社員", "Full-time"),
        ("パート", "Part-time"),
        ("クレジットカードで5000円を支払いました", "Paid 5000 yen by credit card"),
        ("銀行振込で12000円を送金しました", "Sent 12000 yen by bank transfer"),
        ("現金で800円を支払いました", "Paid 800 yen in cash"),
        ("クレジットカードで", "Paid by credit card: "),
        ("銀行振込で", "Sent by bank transfer: "),
        ("現金で", "Paid in cash: "),
        ("を支払いました", " paid"),
        ("を送金しました", " transferred"),
        ("[物理] Java教科書: 3500円", "[Physical] Java Textbook: 3500 yen"),
        ("[DL] オンライン講座: 1200円", "[DL] Online Course: 1200 yen"),
        ("[定額] Proプラン（月額）: 980円", "[Subscription] Pro Plan (Monthly): 980 yen"),
        ("[物理]", "[Physical]"),
        ("[DL]", "[DL]"),
        ("[定額]", "[Subscription]"),
        ("Java教科書", "Java Textbook"),
        ("オンライン講座", "Online Course"),
        ("月額", "Monthly"),
        ("[アラート] AAPL が閾値 180 を超えました！現在値: 200",
         "[Alert] AAPL exceeded threshold 180! Current value: 200"),
        ("[アラート解除] AAPL が閾値 180 以下に戻りました。現在値: 170",
         "[Alert Cleared] AAPL is at or below threshold 180. Current value: 170"),
        ("[アラート]", "[Alert]"),
        ("[アラート解除]", "[Alert Cleared]"),
        ("が閾値", " exceeded threshold"),
        ("を超えました！現在値:", "! Current value:"),
        ("以下に戻りました。現在値:", " is at or below threshold. Current value:"),
        ("現在値: ", "Current value: "),
        ("割引なし: 10000円", "No discount: 10000 yen"),
        ("20%割引: 8000円", "20% discount: 8000 yen"),
        ("3000円引き: 7000円", "3000 yen off: 7000 yen"),
        ("割引なし", "No discount"),
        ("割引", "discount"),
        ("引き", " off"),
        ("入力: abc → エラー: 数値ではありません", "Input: abc → Error: Not a number"),
        ("入力: 150 → エラー: 範囲外です（1〜100）", "Input: 150 → Error: Out of range (1-100)"),
        ("入力: ", "Input: "),
        ("数値ではありません", "Not a number"),
        ("範囲外です（1〜100）", "Out of range (1-100)"),
        ("預金: 10000円 → 残高: 10000円", "Deposit: 10000 yen → Balance: 10000 yen"),
        ("預金: 5000円 → 残高: 15000円", "Deposit: 5000 yen → Balance: 15000 yen"),
        ("引出: 3000円 → 残高: 12000円", "Withdrawal: 3000 yen → Balance: 12000 yen"),
        ("引出: 20000円 → エラー: 残高不足です（残高: 12000円）",
         "Withdrawal: 20000 yen → Error: Insufficient funds (balance: 12000 yen)"),
        ("預金: -100円 → エラー: 金額は正の数を指定してください",
         "Deposit: -100 yen → Error: Amount must be a positive number"),
        ("預金: ", "Deposit: "),
        ("引出: ", "Withdrawal: "),
        ("残高不足です", "Insufficient funds"),
        ("金額は正の数を指定してください", "Amount must be a positive number"),
        ("設定の解析に失敗", "Configuration parsing failed"),
        ("フォーマットが不正です", "Invalid format"),
        ("'='がありません", "'=' is missing"),
        ("値の型が不正です", "Invalid value type"),
        ("は整数ではありません", " is not an integer"),
        ("単語数: ", "Word count: "),
        ("クラス最高平均: 花子", "Class highest average: Hanako"),
        ("クラス最高平均: ", "Class highest average: "),
        ("クラス最高", "Class highest"),
        ("合計金額: 6800円", "Total: 6800 yen"),
        ("最高額: コーヒーメーカー（3500円）", "Highest: Coffee Maker (3500 yen)"),
        ("1000円以上の商品: 3個", "Products 1000 yen or more: 3"),
        ("合計金額: ", "Total: "),
        ("最高額: ", "Highest: "),
        ("以上の商品: ", " or more products: "),
        ("コーヒーメーカー", "Coffee Maker"),
        ("営業部: 2名（平均年齢: 32.5歳）", "Sales: 2 members (Average age: 32.5)"),
        ("開発部: 2名（平均年齢: 30.0歳）", "Development: 2 members (Average age: 30.0)"),
        ("人事部: 1名（平均年齢: 40.0歳）", "HR: 1 member (Average age: 40.0)"),
        ("名（平均年齢: ", " members (Average age: "),
        ("平均年齢: ", "Average age: "),
        ("名（平均", " members (Average "),
        ("平均", "Average "),
        ("=== 30歳以上の人（年齢降順） ===",
         "=== People 30+ (Age Descending) ==="),
        ("=== 30以上の人（年齢降順） ===",
         "=== People 30+ (Age Descending) ==="),
        ("佐藤 (45歳) - 大阪", "Sato (45) - Osaka"),
        ("鈴木 (38歳) - 名古屋", "Suzuki (38) - Nagoya"),
        ("田中 (32歳) - 東京", "Tanaka (32) - Tokyo"),
        ("大阪", "Osaka"),
        ("名古屋", "Nagoya"),
        ("東京", "Tokyo"),
        ("件数: ", "Count: "),
        ("上位3件", "Top 3"),
        ("上位3", "Top 3"),
        ("INSERT成功: 3件", "INSERT success: 3 rows"),
        ("SELECT結果: ", "SELECT result: "),
        ("山田太郎（営業部）", "Taro Yamada (Sales)"),
        ("UPDATE成功: 給与更新", "UPDATE success: Salary updated"),
        ("DELETE成功: 1件削除", "DELETE success: 1 row deleted"),
        ("INSERT成功: ", "INSERT success: "),
        ("DELETE成功: ", "DELETE success: "),
        ("件削除", " row(s) deleted"),
        ("送金前: A=10000円, B=5000円", "Before transfer: A=10000 yen, B=5000 yen"),
        ("送金処理: A→B 3000円", "Transfer: A→B 3000 yen"),
        ("送金後: A=7000円, B=8000円", "After transfer: A=7000 yen, B=8000 yen"),
        ("送金処理: A→B 20000円", "Transfer: A→B 20000 yen"),
        ("エラー: 残高不足 → ロールバック", "Error: Insufficient balance → Rollback"),
        ("残高変化なし: A=7000円, B=8000円", "Balance unchanged: A=7000 yen, B=8000 yen"),
        ("送金前: ", "Before transfer: "),
        ("送金処理: ", "Transfer: "),
        ("送金後: ", "After transfer: "),
        ("残高変化なし: ", "Balance unchanged: "),
        ("ロールバック", "Rollback"),
        ("Java入門", "Intro to Java"),
        ("商品が見つかりません", "Product not found"),
        ("全件: ", "All records: "),
        ("全 items: ", "All records: "),
        ("期待値: 10000, 実際: ", "Expected: 10000, Actual: "),
        ("期待値: ", "Expected: "),
        ("実際: ", "Actual: "),
        ("（不定）", "(varies)"),
        ("=== ディレクトリ探索: ./src ===", "=== Directory Explorer: ./src ==="),
        ("ディレクトリ探索: ", "Directory Explorer: "),
        (".java ファイル: 5個 (合計: 12.5KB)", ".java files: 5 (Total: 12.5KB)"),
        (".txt ファイル: 2個 (合計: 1.2KB)", ".txt files: 2 (Total: 1.2KB)"),
        ("ファイル: ", "files: "),
        ("個 (合計: ", " (Total: "),
        ("タスク送信: 3件", "Tasks submitted: 3"),
        ("タスク送信: ", "Tasks submitted: "),
        ("結果1: 計算完了（値: 100）", "Result 1: Calculation done (value: 100)"),
        ("結果2: 計算完了（値: 200）", "Result 2: Calculation done (value: 200)"),
        ("結果3: 計算完了（値: 300）", "Result 3: Calculation done (value: 300)"),
        ("計算完了", "Calculation done"),
        ("タスク1", "Task 1"),
        ("タスク2", "Task 2"),
        ("タスク3", "Task 3"),
        ("タスク4", "Task 4"),
        ("タスク5", "Task 5"),
        ("[価格計算] 商品A: 850円（15%OFF）", "[Price Calc] Product A: 850 yen (15% OFF)"),
        ("[決済完了] 商品A: 850円", "[Payment Done] Product A: 850 yen"),
        ("[価格計算] 商品B: 1700円（15%OFF）", "[Price Calc] Product B: 1700 yen (15% OFF)"),
        ("[決済完了] 商品B: 1700円", "[Payment Done] Product B: 1700 yen"),
        ("[価格計算]", "[Price Calc]"),
        ("[決済完了]", "[Payment Done]"),
        ("商品A", "Product A"),
        ("商品B", "Product B"),
        ("商品C", "Product C"),
        ("在庫がありません", "Out of stock"),
        ("transitive→modelも利用可能", "transitive → model also available"),
        ("不明なエラーが発生しました", "An unknown error occurred"),
        ("Unknownなエラーが発生しました", "An unknown error occurred"),
        ("=== 英語 ===", "=== English ==="),
        # ===== ORIGINAL ENTRIES =====
        ("名前: 太郎", "Name: Taro"),
        ("年齢: 20歳", "Age: 20"),
        ("名前: ", "Name: "),
        ("年齢: ", "Age: "),
        ("身長: ", "Height: "),
        ("点数: ", "Score: "),
        ("成績: 優", "Grade: Excellent"),
        ("成績: 良", "Grade: Good"),
        ("成績: 可", "Grade: Fair"),
        ("成績: 不可", "Grade: Fail"),
        ("80点は合格です", "80 points: Passed"),
        ("りんごは赤色です", "Apple is red"),
        ("偶数", "even"),
        ("奇数", "odd"),
        ("1から10までの合計: ", "Sum from 1 to 10: "),
        ("発射！", "Liftoff!"),
        ("合計: ", "Total: "),
        ("平均: ", "Average: "),
        ("最高点: ", "Highest: "),
        ("最低点: ", "Lowest: "),
        ("元の価格: ", "Original price: "),
        ("整数に変換: ", "Converted to int: "),
        ("ソート後: ", "After sorting: "),
        ("45 の位置: ", "Position of 45: "),
        ("--- 追加後 ---", "--- After adding ---"),
        ("--- 削除後 ---", "--- After removing ---"),
        ("残高: ", "Balance: "),
        ("入金後: ", "After deposit: "),
        ("出金後: ", "After withdrawal: "),
        ("計算を実行します...", "Executing calculation..."),
        ("ゼロでは割れません", "Cannot divide by zero"),
        ("処理を続行します", "Continuing processing"),
        ("結果: ", "Result: "),
        ("不正な年齢です: ", "Invalid age: "),
        ("エラー: ", "Error: "),
        ("元の文字列: ", "Original string: "),
        ("大文字: ", "Uppercase: "),
        ("文字数: ", "Length: "),
        ("部分文字列: ", "Substring: "),
        ("置換後: ", "After replace: "),
        ("今日: ", "Today: "),
        ("30日後: ", "30 days later: "),
        ("[非推奨メソッド] 古い処理", "[Deprecated] Old logic"),
        ("[新メソッド] 新しい処理", "[New Method] New logic"),
        ("春", "Spring"),
        ("夏", "Summer"),
        ("秋", "Autumn"),
        ("冬", "Winter"),
        ("不明", "Unknown"),
        ("文字列の箱: ", "String box: "),
        ("数値の箱: ", "Number box: "),
        ("重複除去後: ", "After deduplication: "),
        ("偶数: ", "Even numbers: "),
        ("偶数の2乗の合計: ", "Sum of squares of even numbers: "),
        ("月の季節: ", "Season of month: "),
        ("int → double: ", "int → double: "),
        ("double → int: ", "double → int: "),
        ("文字 'A' の文字コード: ", "Character code of 'A': "),
        ("合計金額（税込）: ", "Total (tax included): "),
        ("歳", ""),
        ("円", " yen"),
        ("日本: ", "Japan: "),
        ("アメリカ: ", "USA: "),
        ("ドイツ: ", "Germany: "),
        ("アプリ名: ", "App name: "),
        ("バージョン: ", "Version: "),
        ("--- 書き込み完了 ---", "--- Write complete ---"),
        ("--- 読み込み結果 ---", "--- Read results ---"),
        ("1行目: ", "Line 1: "),
        ("2行目: ", "Line 2: "),
        ("3行目: ", "Line 3: "),
        ("配列エラーまたは数値変換エラーが発生しました", "Array error or number format error occurred"),
        ("値: ", "Value: "),
        ("データ処理に失敗しました", "Data processing failed"),
        ("プレイヤー: グー", "Player: Rock"),
        ("コンピュータ: チョキ", "Computer: Scissors"),
        ("結果: 勝ち！", "Result: You win!"),
        ("元の文字列: Hello Java", "Original string: Hello Java"),
        ("逆順: avaJ olleH", "Reversed: avaJ olleH"),
        ("=== 家計簿 ===", "=== Budget Tracker ==="),
        ("合計収入: 350000円", "Total income: 350000 yen"),
        ("合計支出: 185000円", "Total expense: 185000 yen"),
        ("残高: 165000円", "Balance: 165000 yen"),
        ("判定: 黒字です", "Status: In the black"),
        ("=== 図書館の蔵書 ===", "=== Library Collection ==="),
        ("[ISBN: 001] Java入門 - 山田太郎", "[ISBN: 001] Introduction to Java - Taro Yamada"),
        ("[ISBN: 002] デザインパターン - 鈴木花子", "[ISBN: 002] Design Patterns - Hanako Suzuki"),
        ("[ISBN: 003] データベース基礎 - 田中一郎", "[ISBN: 003] Database Fundamentals - Ichiro Tanaka"),
        ("=== 給与明細 ===", "=== Payroll ==="),
        ("山田太郎（正社員）: 300000円", "Taro Yamada (Full-time): 300000 yen"),
        ("鈴木花子（パート）: 160000円", "Hanako Suzuki (Part-time): 160000 yen"),
        ("=== 支払い処理 ===", "=== Payment Processing ==="),
        ("クレジットカードで5000円を支払いました", "Paid 5000 yen by credit card"),
        ("銀行振込で12000円を送金しました", "Sent 12000 yen by bank transfer"),
        ("現金で800円を支払いました", "Paid 800 yen in cash"),
        ("=== 動物園 ===", "=== Zoo ==="),
        ("ポチ: ワンワン！（歩く）[泳げる]", "Pochi: Woof! (walk) [can swim]"),
        ("タマ: ニャー！（歩く）", "Tama: Meow! (walk)"),
        ("ピーちゃん: ピーピー！（飛ぶ）", "Tweety: Tweet tweet! (fly)"),
        ("=== カート内容 ===", "=== Cart Contents ==="),
        ("[物理] Java教科書: 3500円", "[Physical] Java Textbook: 3500 yen"),
        ("[DL] オンライン講座: 1200円", "[DL] Online Course: 1200 yen"),
        ("[定額] Proプラン（月額）: 980円", "[Subscription] Pro Plan (Monthly): 980 yen"),
        ("合計: 5680円", "Total: 5680 yen"),
        ("[価格表示] AAPL: ", "[Price Display] AAPL: "),
        ("[アラート] AAPL が閾値 180 を超えました！現在値: 200",
         "[Alert] AAPL exceeded threshold 180! Current value: 200"),
        ("[アラート解除] AAPL が閾値 180 以下に戻りました。現在値: 170",
         "[Alert Cleared] AAPL is at or below threshold 180. Current value: 170"),
        ("割引なし: 10000円", "No discount: 10000 yen"),
        ("20%割引: 8000円", "20% discount: 8000 yen"),
        ("3000円引き: 7000円", "3000 yen off: 7000 yen"),
        ("式: ", "Expression: "),
        ("結果: 14", "Result: 14"),
        ("結果: 2", "Result: 2"),
        ("エラー: 0で割ることはできません", "Error: Cannot divide by zero"),
        ("入力: 42 → 有効です", "Input: 42 → Valid"),
        ("入力: abc → エラー: 数値ではありません", "Input: abc → Error: Not a number"),
        ("入力: 150 → エラー: 範囲外です（1〜100）", "Input: 150 → Error: Out of range (1-100)"),
        ("読み込み成功", "Read successful"),
        ("finallyブロック実行", "finally block executed"),
        ("預金: 10000円 → 残高: 10000円", "Deposit: 10000 yen → Balance: 10000 yen"),
        ("預金: 5000円 → 残高: 15000円", "Deposit: 5000 yen → Balance: 15000 yen"),
        ("引出: 3000円 → 残高: 12000円", "Withdrawal: 3000 yen → Balance: 12000 yen"),
        ("引出: 20000円 → エラー: 残高不足です（残高: 12000円）",
         "Withdrawal: 20000 yen → Error: Insufficient funds (balance: 12000 yen)"),
        ("預金: -100円 → エラー: 金額は正の数を指定してください",
         "Deposit: -100 yen → Error: Amount must be a positive number"),
        ("DB接続を開きました", "DB connection opened"),
        ("ファイルを開きました", "File opened"),
        ("DB操作: SELECT実行中...", "DB operation: SELECT executing..."),
        ("ファイル操作: 書き込み中...", "File operation: writing..."),
        ("ファイルを閉じました", "File closed"),
        ("DB接続を閉じました", "DB connection closed"),
        ("[リトライ 1/3] NetworkException: 接続タイムアウト。リトライします...",
         "[Retry 1/3] NetworkException: Connection timeout. Retrying..."),
        ("[リトライ 2/3] NetworkException: 接続タイムアウト。リトライします...",
         "[Retry 2/3] NetworkException: Connection timeout. Retrying..."),
        ("成功: レスポンス 200 OK", "Success: Response 200 OK"),
        ("検証成功: taro@example.com", "Validation success: taro@example.com"),
        ("検証エラー:", "Validation errors:"),
        ("  - 値がnullです", "  - Value is null"),
        ("  - 3文字以上で入力してください", "  - 3 or more characters required"),
        ("  - メールアドレスの形式が不正です", "  - Invalid email format"),
        ("=== テキスト分析 ===", "=== Text Analysis ==="),
        ("'l'の出現回数: ", "Occurrences of 'l': "),
        ("大文字: 2", "Uppercase: 2"),
        ("小文字: 8", "Lowercase: 8"),
        ("開始日: ", "Start date: "),
        ("終了日: ", "End date: "),
        ("期間: 2ヶ月30日", "Period: 2 months 30 days"),
        ("開始日の曜日: 木曜日", "Start day of week: Thursday"),
        ("1月の最終日: ", "Last day of January: "),
        ("パスワード: abc → 強度: 弱（スコア: 1/5）",
         "Password: abc → Strength: Weak (Score: 1/5)"),
        ("パスワード: Hello123 → 強度: 中（スコア: 3/5）",
         "Password: Hello123 → Strength: Medium (Score: 3/5)"),
        ("パスワード: P@ssw0rd! → 強度: 強（スコア: 5/5）",
         "Password: P@ssw0rd! → Strength: Strong (Score: 5/5)"),
        ("=== スケジュール ===", "=== Schedule ==="),
        ("[過去] 2025-12-25 10:00 - クリスマスパーティ",
         "[Past] 2025-12-25 10:00 - Christmas Party"),
        ("[未来] 2027-06-15 14:30 - Java試験",
         "[Future] 2027-06-15 14:30 - Java Exam"),
        ("[未来] 2027-09-01 09:00 - 新学期開始",
         "[Future] 2027-09-01 09:00 - New Semester Begins"),
        ("元の文字列: '  Hello, World!  '", "Original string: '  Hello, World!  '"),
        ("1. トリム: 'Hello, World!'", "1. Trim: 'Hello, World!'"),
        ("2. 大文字: 'HELLO, WORLD!'", "2. Uppercase: 'HELLO, WORLD!'"),
        ("3. 置換(,→;): 'HELLO; WORLD!'", "3. Replace(,→;): 'HELLO; WORLD!'"),
        ("4. 反転: '!DLROW ;OLLEH'", "4. Reverse: '!DLROW ;OLLEH'"),
        ("=== ログサマリ ===", "=== Log Summary ==="),
        ("件", " items"),
        ("=== ERRORログ詳細 ===", "=== ERROR Log Details ==="),
        ("UserService: ログインに失敗", "UserService: Login failed"),
        ("PaymentService: 決済エラー", "PaymentService: Payment error"),
        ("=== アプリ設定 ===", "=== App Settings ==="),
        ("太郎: 平均", "Taro: Average"),
        ("花子: 平均", "Hanako: Average"),
        ("一郎: 平均", "Ichiro: Average"),
        ("クラス最高平均: 花子", "Class highest average: Hanako"),
        ("元のペア: ", "Original pair: "),
        ("入れ替え: ", "Swapped: "),
        ("文字列ペア: ", "String pair: "),
        ("=== 在庫一覧 ===", "=== Inventory List ==="),
        ("りんご: 50個", "Apple: 50 units"),
        ("バナナ: 30個", "Banana: 30 units"),
        ("みかん: 0個", "Orange: 0 units"),
        ("在庫切れ: [みかん]", "Out of stock: [Orange]"),
        ("リストA: ", "List A: "),
        ("リストB: ", "List B: "),
        ("積集合: ", "Intersection: "),
        ("和集合: ", "Union: "),
        ("差集合(A-B): ", "Difference(A-B): "),
        ("偶数: ", "Even: "),
        ("5文字以上の単語: ", "Words with 5+ characters: "),
        ("合計金額: 6800円", "Total: 6800 yen"),
        ("最高額: コーヒーメーカー（3500円）", "Highest: Coffee Maker (3500 yen)"),
        ("1000円以上の商品: 3個", "Products 1000 yen or more: 3"),
        ("=== 部署別集計 ===", "=== Department Summary ==="),
        ("営業部: 2名（平均年齢: 32.5歳）", "Sales: 2 members (Average age: 32.5)"),
        ("開発部: 2名（平均年齢: 30.0歳）", "Development: 2 members (Average age: 30.0)"),
        ("人事部: 1名（平均年齢: 40.0歳）", "HR: 1 member (Average age: 40.0)"),
        ("=== 統計情報 ===", "=== Statistics ==="),
        ("個数: ", "Count: "),
        ("合計: 321", "Total: 321"),
        ("平均: 53.5", "Average: 53.5"),
        ("最大: 95", "Max: 95"),
        ("最小: 12", "Min: 12"),
        ("=== 30歳以上の人（年齢降順） ===",
         "=== People 30+ (Age Descending) ==="),
        ("佐藤 (45歳) - 大阪", "Sato (45) - Osaka"),
        ("鈴木 (38歳) - 名古屋", "Suzuki (38) - Nagoya"),
        ("田中 (32歳) - 東京", "Tanaka (32) - Tokyo"),
        ("原文: Hello", "Original: Hello"),
        ("暗号化: ", "Encrypted: "),
        ("復号化: Hello", "Decrypted: Hello"),
        ("検証: 一致", "Verification: Match"),
        ("=== 統計情報 ===", "=== Statistics ==="),
        ("件数: 8", "Count: 8"),
        ("合計: 360", "Total: 360"),
        ("平均: 45.0", "Average: 45.0"),
        ("最小: 10", "Min: 10"),
        ("最大: 90", "Max: 90"),
        ("=== 上位3件 ===", "=== Top 3 ==="),
        ("=== テーブル作成 ===", "=== Create Table ==="),
        ("INSERT成功: 3件", "INSERT success: 3 rows"),
        ("SELECT結果: 山田太郎（営業部）", "SELECT result: Taro Yamada (Sales)"),
        ("UPDATE成功: 給与更新", "UPDATE success: Salary updated"),
        ("DELETE成功: 1件削除", "DELETE success: 1 row deleted"),
        ("接続URL: ", "Connection URL: "),
        ("スキーマ作成完了", "Schema creation complete"),
        ("検索結果:", "Search results:"),
        ("GET /api/products → 商品一覧", "GET /api/products → Product list"),
        ("GET /api/products/1 → 商品詳細", "GET /api/products/1 → Product detail"),
        ("POST /api/products → 商品追加", "POST /api/products → Add product"),
        ("DELETE /api/products/1 → 商品削除", "DELETE /api/products/1 → Delete product"),
        ("送金前: A=10000円, B=5000円", "Before transfer: A=10000 yen, B=5000 yen"),
        ("送金処理: A→B 3000円", "Transfer: A→B 3000 yen"),
        ("送金後: A=7000円, B=8000円", "After transfer: A=7000 yen, B=8000 yen"),
        ("送金処理: A→B 20000円", "Transfer: A→B 20000 yen"),
        ("エラー: 残高不足 → ロールバック", "Error: Insufficient balance → Rollback"),
        ("残高変化なし: A=7000円, B=8000円", "Balance unchanged: A=7000 yen, B=8000 yen"),
        ("成功: {status:200", "Success: {status:200"),
        ("エラー: {status:404", "Error: {status:404"),
        ("商品が見つかりません", "Product not found"),
        ("保存: ", "Saved: "),
        ("全件: ", "All records: "),
        ("削除後: ", "After deletion: "),
        ("[Producer] タスク投入: ", "[Producer] Task submitted: "),
        ("[Producer] 全タスク投入完了", "[Producer] All tasks submitted"),
        ("[Consumer] 終了シグナル受信。停止します。",
         "[Consumer] Stop signal received. Shutting down."),
        ("[Consumer] 処理中: ", "[Consumer] Processing: "),
        ("全処理完了", "All processing complete"),
        ("[在庫確認] 商品A: OK", "[Stock Check] Product A: OK"),
        ("[価格計算] 商品A: 850円（15%OFF）", "[Price Calc] Product A: 850 yen (15% OFF)"),
        ("[決済完了] 商品A: 850円", "[Payment Done] Product A: 850 yen"),
        ("[在庫確認] 商品B: OK", "[Stock Check] Product B: OK"),
        ("[価格計算] 商品B: 1700円（15%OFF）", "[Price Calc] Product B: 1700 yen (15% OFF)"),
        ("[決済完了] 商品B: 1700円", "[Payment Done] Product B: 1700 yen"),
        ("[在庫確認] 商品C: 在庫なし", "[Stock Check] Product C: Out of stock"),
        ("[エラー] 商品C: 在庫がありません", "[Error] Product C: Out of stock"),
        ("全注文処理完了", "All order processing complete"),
        ("カウントダウン開始！", "Countdown start!"),
        ("時間です！", "Time's up!"),
        ("ファイル書き込み完了: output.txt", "File write complete: output.txt"),
        ("=== ファイル内容 ===", "=== File Contents ==="),
        ("NIO2でファイル操作", "File operations with NIO2"),
        ("簡単で安全です", "Easy and safe"),
        ("=== synchronized なし ===", "=== Without synchronized ==="),
        ("期待値: 10000, 実際: ", "Expected: 10000, Actual: "),
        ("=== synchronized あり ===", "=== With synchronized ==="),
        ("期待値: 10000, 実際: 10000", "Expected: 10000, Actual: 10000"),
        ("=== AtomicInteger ===", "=== AtomicInteger ==="),
        ("タスク送信: 3件", "Tasks submitted: 3"),
        ("結果1: 計算完了（値: 100）", "Result 1: Calculation done (value: 100)"),
        ("結果2: 計算完了（値: 200）", "Result 2: Calculation done (value: 200)"),
        ("結果3: 計算完了（値: 300）", "Result 3: Calculation done (value: 300)"),
        ("全タスク完了", "All tasks completed"),
        ("=== モジュール構成 ===", "=== Module Structure ==="),
        ("日本語: こんにちは、世界！", "Japanese: Hello, World!"),
        ("Français: Bonjour, le monde!", "Français: Bonjour, le monde!"),
        ("金額: 1234567.89", "Amount: 1234567.89"),
        ("日本: ￥1,234,568", "Japan: ￥1,234,568"),
        ("米国: $1,234,567.89", "US: $1,234,567.89"),
        ("ドイツ: 1.234.567,89 €", "Germany: 1.234.567,89 €"),
        ("=== 日時の国際化 ===", "=== DateTime Internationalization ==="),
        ("日本: 2026年1月15日 木曜日 09:30 JST",
         "Japan: 2026/1/15 Thursday 09:30 JST"),
        ("米国: Thursday, January 15, 2026 at 7:30 PM CST",
         "US: Thursday, January 15, 2026 at 7:30 PM CST"),
        ("フランス: jeudi 15 janvier 2026 à 01:30 CET",
         "France: jeudi 15 janvier 2026 à 01:30 CET"),
        ("=== 日本語 ===", "=== Japanese ==="),
        ("=== English ===", "=== English ==="),
        ("E001: 認証に失敗しました", "E001: Authentication failed"),
        ("E002: アクセス権がありません", "E002: Access denied"),
        ("E999: 不明なエラーが発生しました", "E999: An unknown error occurred"),
        ("E001: Authentication failed", "E001: Authentication failed"),
        ("E002: Access denied", "E002: Access denied"),
        ("E999: An unknown error occurred", "E999: An unknown error occurred"),
        ("greeting = ようこそ", "greeting = Welcome"),
        ("error.invalid = 入力値が不正です", "error.invalid = Invalid input"),
        ("greeting = Welcome", "greeting = Welcome"),
        ("error.invalid = Invalid input", "error.invalid = Invalid input"),
        ("=== 存在しないキー ===", "=== Non-existent Key ==="),
        ("unknown.key = (デフォルト値)", "unknown.key = (Default value)"),
        ("=== ソート結果（給与降順→入社年昇順→名前昇順）===",
         "=== Sort Results (Salary Desc → Join Year Asc → Name Asc) ==="),
        ("田中(開発, 600万, 2018)", "Tanaka (Development, 6M, 2018)"),
        ("鈴木(開発, 500万, 2019)", "Suzuki (Development, 5M, 2019)"),
        ("高橋(営業, 550万, 2017)", "Takahashi (Sales, 5.5M, 2017)"),
        ("佐藤(営業, 450万, 2020)", "Sato (Sales, 4.5M, 2020)"),
        ("=== 部門別平均給与 ===", "=== Average Salary by Department ==="),
        ("営業: 500.0万", "Sales: 500.0 (10K yen)"),
        ("開発: 550.0万", "Development: 550.0 (10K yen)"),
        ("put(1, A), put(2, B), put(3, C)", "put(1, A), put(2, B), put(3, C)"),
        ("get(1) = A", "get(1) = A"),
        ("put(4, D) -> 最古の 2 が削除される",
         "put(4, D) -> Oldest entry 2 is removed"),
        ("get(2) = null", "get(2) = null"),
        ("田中", "Tanaka"),
        ("鈴木", "Suzuki"),
        ("佐藤", "Sato"),
        ("高橋", "Takahashi"),
        ("伊藤", "Ito"),
        ("花子", "Hanako"),
        ("太郎", "Taro"),
        ("一郎", "Ichiro"),
    ]
    for jp, en in reps:
        text = text.replace(jp, en)

    # ===== FINAL CLEANUP: catch patterns broken by replacement ordering =====
    # Original form before 奇数→odd fires
    text = text.replace("は 奇数 です", "is odd")
    text = text.replace("は odd です", "is odd")
    # Partial name translations (太郎→Taro fires before full-line match)
    text = text.replace("山田Taro", "Yamada Taro")
    # Greeting patterns
    text = text.replace("こんにちは、", "Hello, ")
    text = text.replace("さん！", "!")
    # Animal names
    text = text.replace("ポチ", "Pochi")
    text = text.replace("タマ", "Tama")
    text = text.replace("歩く", "walk")
    text = text.replace("泳げる", "can swim")
    # Validation
    text = text.replace("有効です", "Valid")
    # Inventory/stock
    text = text.replace("在庫確認", "Stock Check")
    text = text.replace("在庫なし", "Out of stock")
    text = text.replace("エラー", "Error")
    # Department/salary (partially translated intermediates)
    text = text.replace("部門別Average 給与", "Average Salary by Department")
    text = text.replace("部門別平均給与", "Average Salary by Department")
    # Fullwidth parentheses → ASCII (must come after specific patterns above)
    text = text.replace("（", "(")
    text = text.replace("）", ")")
    # "点)" left after fullwidth paren conversion e.g. "91.7点)"
    text = text.replace("点)", " points)")
    # Fullwidth yen sign → standard yen sign
    text = text.replace("￥", "¥")

    return text

# =============================================================
# Part 2: Setup Guide Body/Tip Translations
# =============================================================
SETUP_BODY = {}
SETUP_TIP = {}

# -- Windows --
SETUP_BODY["win_01"] = "To write and run Java programs, you need the **JDK (Java Development Kit)**. The JDK includes **javac** for compiling code and **java** for running programs.\n\nDownload steps:\n1. Open your browser and go to **Adoptium** (https://adoptium.net)\n2. Click the \"**Latest LTS Release**\" button\n3. The Windows installer will be downloaded automatically\n\n| Term | Meaning |\n|------|------|\n| JDK | Complete toolkit required for Java development |\n| LTS | Long-Term Support version (stable and reliable) |\n| JRE | Runtime-only environment (included in JDK) |"
SETUP_TIP["win_01"] = "Choose JDK version **17** or **21**. These are LTS (Long-Term Support) versions, so they will be stable and supported for a long time."
SETUP_BODY["win_02"] = "Double-click the downloaded **.msi file** to run it.\n\n| Screen | Action |\n|------|------|\n| Welcome screen | Click \"Next\" |\n| Installation location | Click \"Next\" as-is (no change needed) |\n| Custom setup | **Check \"Set JAVA_HOME variable\"** and click \"Next\" |\n| Installation | Click \"Install\" |\n| Completion | Click \"Finish\" |\n\n**Checking \"Set JAVA_HOME variable\" is the most important step.** This automatically configures the necessary environment variables for you."
SETUP_TIP["win_02"] = "Using the Adoptium installer automatically sets environment variables (JAVA_HOME and PATH), saving you the trouble of manual configuration."
SETUP_BODY["win_03"] = "Let's verify that the JDK was installed correctly.\n\n**How to open Command Prompt:**\n1. Press the **Windows key** on your keyboard\n2. Type \"**cmd**\"\n3. Click **\"Command Prompt\"** when it appears\n\nOnce the black screen opens, type the following commands one line at a time and press Enter."
SETUP_TIP["win_03"] = "If you see \"'java' is not recognized as an internal or external command...\", **restart your computer** and try again. If that doesn't work, manually add the JDK's **bin folder** (e.g., C:\\Program Files\\Eclipse Adoptium\\jdk-17\\bin) to the PATH environment variable."
SETUP_BODY["win_04"] = "Prepare a **text editor** for writing programs. **Visual Studio Code (VS Code)** is recommended for beginners.\n\n**VS Code installation steps:**\n1. Go to https://code.visualstudio.com in your browser\n2. Click the \"**Download for Windows**\" button\n3. Run the downloaded installer\n4. Follow the on-screen instructions and click \"Next\"\n\n**Adding Java extensions:**\n1. Launch VS Code\n2. Click the square icon (**Extensions**) on the left side\n3. Type \"**Extension Pack for Java**\" in the search box\n4. Click \"**Install**\" for the displayed extension\n\n| Feature | What it does |\n|------|----------|\n| Code completion | Shows suggestions as you type |\n| Error display | Highlights mistakes with red underlines |\n| Debugging | Run your program step by step |"
SETUP_TIP["win_04"] = "You can compile and run Java with Notepad too, but using VS Code significantly improves efficiency with **syntax highlighting** and **error display**."
SETUP_BODY["win_05"] = "Let's create and run an actual Java program!\n\n**File creation steps:**\n1. Create a new folder called \"**JavaTest**\" on your Desktop\n2. In VS Code, go to \"File\" → \"Open Folder\" → select the \"JavaTest\" folder\n3. Click the \"New File\" icon in the left panel\n4. Name the file **HelloWorld.java** (match uppercase/lowercase exactly)\n5. Copy and paste the code below, then save (Ctrl + S)\n\n**Compile and run:**\n1. In VS Code, open \"Terminal\" → \"New Terminal\"\n2. Run the following commands in order"
SETUP_TIP["win_05"] = "The file name must be **exactly the same as the class name** (HelloWorld.java). Uppercase and lowercase must match precisely. If you see \"Hello, World!\" displayed, your environment setup is **complete**!"

# -- Mac --
SETUP_BODY["mac_01"] = "On Mac, you'll use the **Terminal** app to install the JDK.\n\n**How to open Terminal:**\n1. Press **Command + Space** on your keyboard (opens Spotlight search)\n2. Type \"**Terminal**\"\n3. Click \"Terminal.app\" to open it\n\nTerminal is a tool for giving commands to your computer by typing text. It might feel a bit difficult at first, but all you need to do is **copy & paste commands and press Enter**."
SETUP_TIP["mac_01"] = "Adding Terminal to the \"Dock\" is convenient for quick access in the future. Right-click the Terminal icon → \"Options\" → \"Keep in Dock\"."
SETUP_BODY["mac_02"] = "**Homebrew** is a tool (package manager) for easily installing software on Mac. Using Homebrew is the easiest way to install the JDK.\n\nTo check if Homebrew is already installed, run the following in Terminal. If a version number is displayed, it's already installed."
SETUP_TIP["mac_02"] = "During the Homebrew installation, you'll be asked for a password. Enter your **Mac login password** (nothing will appear on screen as you type, but this is normal)."
SETUP_BODY["mac_03"] = "Use Homebrew to install the **JDK (Java Development Kit)**. Run the following commands in Terminal."
SETUP_TIP["mac_03"] = "You'll be asked for a password when running the **sudo** command. Enter your Mac login password. If you prefer not to use Homebrew, you can also download a .pkg installer from **Adoptium** (https://adoptium.net) and run it (no link creation needed in that case)."
SETUP_BODY["mac_04"] = "Let's verify that the JDK was installed correctly. Run the following commands in Terminal.\n\nIf version information (e.g., openjdk 17.0.x) is displayed, the installation was successful."
SETUP_TIP["mac_04"] = "If the version is not displayed, try **closing and reopening Terminal**. If that doesn't work, add the following to your shell configuration file (~/.zshrc):\nexport JAVA_HOME=$(/usr/libexec/java_home)"
SETUP_BODY["mac_05"] = "Prepare a **text editor** for writing programs. **Visual Studio Code (VS Code)** is recommended.\n\n**VS Code installation steps:**\n1. Go to https://code.visualstudio.com in your browser\n2. Click the \"**Download for Mac**\" button\n3. Unzip the downloaded .zip file and move it to the Applications folder\n\n**Adding Java extensions:**\n1. Launch VS Code\n2. Click the square icon (**Extensions**) on the left side\n3. Search for and install \"**Extension Pack for Java**\"\n\n| Feature | What it does |\n|------|----------|\n| Code completion | Shows suggestions as you type |\n| Error display | Highlights mistakes with red underlines |\n| Debugging | Run your program step by step |"
SETUP_TIP["mac_05"] = "The default TextEdit app on macOS uses \"Rich Text\" mode by default. If you use it, make sure to switch to \"Format\" → \"Make Plain Text\" in the menu."
SETUP_BODY["mac_06"] = "Let's create and run an actual Java program!\n\n**File creation steps:**\n1. Create a new folder called \"**JavaTest**\" on your Desktop\n2. In VS Code, go to \"File\" → \"Open Folder\" → select the \"JavaTest\" folder\n3. Click the \"New File\" icon in the left panel\n4. Name the file **HelloWorld.java**\n5. Copy and paste the code below, then save (Command + S)\n\n**Compile and run:**\n1. In VS Code, open \"Terminal\" → \"New Terminal\"\n2. Run the following commands in order"
SETUP_TIP["mac_06"] = "The file name must be **exactly the same as the class name** (HelloWorld.java). If you see \"Hello, World!\" displayed, your environment setup is **complete**!"

# -- DB --
SETUP_BODY["db_01"] = "**MySQL** is a **database management system** for storing and managing data. The technology for connecting to MySQL from a Java program to read and write data is called **JDBC**.\n\n| Term | Meaning |\n|------|------|\n| MySQL | A free database system |\n| JDBC | A mechanism for accessing databases from Java |\n| SQL | A language for issuing commands to databases |\n| Table | A unit for storing data in tabular format |\n\nThis guide covers everything from installing MySQL to creating a practice database."
SETUP_TIP["db_01"] = "Database topics are covered in Chapter 10 and beyond in this app. It's fine to learn the basics of Java first before starting this section."
SETUP_BODY["db_02"] = "Install according to your OS.\n\n**[Windows]**\n1. Go to https://dev.mysql.com/downloads/installer/\n2. Download \"**MySQL Installer for Windows**\"\n3. Run the installer and select \"**Server only**\"\n4. Follow the on-screen instructions and set a **root password**\n\n**[Mac]**\nUse Homebrew to install with the following commands."
SETUP_TIP["db_02"] = "Make sure to note down the **root password** you set during installation. You'll need this password every time you connect to the database."
SETUP_BODY["db_03"] = "Let's verify that MySQL is running correctly. Run the following in Command Prompt (Windows) or Terminal (Mac).\n\nWhen prompted for a password, enter the **root password** you set during installation."
SETUP_TIP["db_03"] = "If you see \"mysql: command not found\", MySQL's bin folder is not added to PATH.\n\n**Windows:** Add C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin to PATH\n**Mac:** Check if mysql is \"started\" with brew services list"
SETUP_BODY["db_04"] = "To connect to MySQL from Java, you need the **JDBC driver** (mysql-connector-j).\n\n**Download steps:**\n1. Go to https://dev.mysql.com/downloads/connector/j/\n2. Select \"**Platform Independent**\"\n3. Download the **.zip** file and extract it\n4. Copy the **mysql-connector-j-x.x.x.jar** file to your project folder\n\nYou need to specify this .jar file path when compiling and running."
SETUP_TIP["db_04"] = "**-cp** is an option to specify the classpath (where Java looks for libraries). **.** (dot) means the current folder. On Windows, the separator is **;** (semicolon), and on Mac/Linux it's **:** (colon)."
SETUP_BODY["db_05"] = "Let's create the database and table for JDBC practice. Log in to MySQL and execute the following SQL statements in order.\n\nTable structure to create:\n\n| Column | Type | Description |\n|----------|------|------|\n| id | INT (Primary Key) | Employee ID (auto-increment) |\n| name | VARCHAR(50) | Employee name |\n| department | VARCHAR(30) | Department |\n| salary | INT | Monthly salary |"
SETUP_TIP["db_05"] = "This **employees** table is used in JDBC practice exercises. Each SQL command is covered in detail in Chapter 10 \"Database Introduction\" of this app."

# -- Web --
SETUP_BODY["web_01"] = "**Spring Boot** is a **framework** (a development foundation tool) for easily building web applications in Java.\n\n| Term | Meaning |\n|------|------|\n| Spring Boot | Web development framework for Java |\n| Maven | Tool for library management and builds |\n| Endpoint | A URL for accessing the web app |\n| localhost | Your own computer (for development) |\n\nThis guide covers creating a Spring Boot project and verifying it works."
SETUP_TIP["web_01"] = "Spring Boot is covered in Chapter 38 of this app. We recommend learning Java basics, object-oriented programming, and exception handling first."
SETUP_BODY["web_02"] = "Use the **Spring Initializr** web tool to auto-generate a project template.\n\n**Steps:**\n1. Go to https://start.spring.io in your browser\n2. Configure the settings as follows\n\n| Setting | Value |\n|----------|----------|\n| Project | **Maven** |\n| Language | **Java** |\n| Spring Boot | **Latest stable version** (without SNAPSHOT) |\n| Group | com.example |\n| Artifact | demo |\n| Packaging | Jar |\n| Java | 17 |\n\n3. Click \"**ADD DEPENDENCIES**\" on the right and add \"**Spring Web**\"\n4. Click \"**GENERATE**\" to download the ZIP\n5. Extract the ZIP and save it to your preferred location"
SETUP_TIP["web_02"] = "If using VS Code, adding both the \"**Extension Pack for Java**\" and \"**Spring Boot Extension Pack**\" extensions is recommended."
SETUP_BODY["web_03"] = "Let's verify the project works correctly. In Command Prompt (Windows) or Terminal (Mac), navigate to the extracted folder and run the following command."
SETUP_TIP["web_03"] = "On successful startup, you'll see the message \"**Started DemoApplication**\". Open your browser and go to **http://localhost:8080**. If you see a \"**Whitelabel Error Page**\", the app is running correctly (the error is normal since we haven't created any pages yet). Press **Ctrl + C** to stop the app."
SETUP_BODY["web_04"] = "Let's create a page you can access from a browser. Create the following file.\n\n| Item | Content |\n|------|------|\n| File name | HelloController.java |\n| Location | src/main/java/com/example/demo/ |\n| Role | Defines the action when a URL is accessed |"
SETUP_TIP["web_04"] = "After saving the file, restart the app and go to **http://localhost:8080/hello** in your browser. If you see \"**Hello, Spring Boot!**\", your web app development environment setup is **complete**!"

# -- Eclipse --
SETUP_BODY["eclipse_01"] = "**Eclipse** is one of the most widely used **Integrated Development Environments (IDEs)** for Java development. You can write, run, and debug code all in one screen.\n\n| Term | Meaning |\n|------|------|\n| IDE | A tool that integrates code editing, execution, and debugging |\n| Eclipse | A standard IDE for Java development (free) |\n| Pleiades | A package that adds Japanese localization and useful plugins to Eclipse |\n| Tomcat | A web server for running Servlets / JSP |\n| Spring Tool Suite | A plugin for Spring Boot development in Eclipse |\n\nWith Eclipse, you can complete everything from project creation to execution **using only the GUI**, compared to VS Code + command line."
SETUP_TIP["eclipse_01"] = "This guide uses **Pleiades All in One**. It includes Eclipse, Japanese localization, JDK, and Tomcat all together, making it easy for beginners to set up."
SETUP_BODY["eclipse_02"] = "**Steps:**\n1. Go to https://willbrains.jp in your browser\n2. Click \"**Eclipse 2024**\" (latest yearly version)\n3. Select your OS (**Windows** / **Mac**)\n4. Download the **Java** \"**Full Edition**\"\n\n| Edition | Contents |\n|-------------|------|\n| Standard | Eclipse + plugins only |\n| Full Edition | Eclipse + **JDK** + **Tomcat** bundled (recommended) |\n\n**Windows:**\n- Extract the downloaded zip to a short path like **C:\\pleiades** (avoid the Desktop)\n- After extraction, double-click **eclipse.exe** to launch\n\n**Mac:**\n- Open the downloaded dmg and drag **Eclipse** to the **Applications** folder\n- On first launch, if you see \"Cannot verify the developer\", go to **System Settings → Privacy & Security → Open Anyway**"
SETUP_TIP["eclipse_02"] = "With the Full Edition, you don't need the JDK installation from the Windows/Mac setup guides. However, if you want to use javac/java commands from the command line, you'll need to install JDK and configure PATH separately."
SETUP_BODY["eclipse_03"] = "**Servlet** and **JSP** are fundamental technologies for creating web applications in Java. Eclipse and Tomcat make development easy.\n\n**Steps:**\n1. Launch Eclipse and select **File → New → Dynamic Web Project** from the menu\n2. Enter \"HelloServlet\" as the **Project name**\n3. Select **Apache Tomcat** as the **Target runtime** (if not listed, specify installed Tomcat via \"New Runtime\")\n4. Click \"**Finish**\"\n\n| Term | Meaning |\n|------|------|\n| Servlet | A Java program that handles HTTP requests |\n| JSP | A mechanism for embedding Java code in HTML |\n| Dynamic Web Project | A project format for Servlets / JSP |\n| Tomcat | A web server for running Servlets / JSP |"
SETUP_TIP["eclipse_03"] = "If you're using the Full Edition, Tomcat is already included so no additional installation is needed."
SETUP_BODY["eclipse_04"] = "Let's add a Servlet to the project and display it in a browser.\n\n**Steps:**\n1. Right-click **src/main/java** in the project → **New → Servlet**\n2. Enter \"com.example\" as the **Package name** and \"HelloServlet\" as the **Class name**, then click \"**Finish**\"\n3. Modify the **doGet** method in the generated code as shown below\n4. Right-click the project → **Run As → Run on Server** → select **Tomcat** and click \"**Finish**\""
SETUP_TIP["eclipse_04"] = "Go to **http://localhost:8080/HelloServlet/HelloServlet** in your browser. If you see \"**Hello, Servlet!**\", it's successful. To stop Tomcat, click the stop button in the \"**Servers**\" view in Eclipse."
SETUP_BODY["eclipse_05"] = "By adding the **Spring Tool Suite (STS) plugin** to Eclipse, you can also create and run Spring Boot projects within Eclipse.\n\n**STS plugin installation:**\n1. Go to **Help → Eclipse Marketplace** from the Eclipse menu\n2. Type \"**Spring Tools**\" in the search box\n3. Click \"**Install**\" for \"**Spring Tools 4**\" and follow the instructions\n4. **Restart** Eclipse\n\n**Creating a Spring Boot project:**\n1. Select **File → New → Spring Starter Project** from the menu\n2. Configure as follows\n\n| Setting | Value |\n|----------|----|\n| Name | demo |\n| Type | Maven |\n| Packaging | Jar |\n| Java Version | 17 |\n| Group | com.example |\n\n3. Click \"**Next**\" and check **Spring Web**\n4. Click \"**Finish**\" to auto-generate the project"
SETUP_TIP["eclipse_05"] = "This allows you to do the same thing as the **Spring Initializr** (website) introduced in the \"Web App Development Environment Setup\" guide, but within the Eclipse interface."
SETUP_BODY["eclipse_06"] = "Let's add a controller to the Spring Boot project from Step 5 and run it.\n\n**Steps:**\n1. Right-click **src/main/java → com.example.demo** package → **New → Class**\n2. Enter \"HelloController\" as the **Class name** and click \"**Finish**\"\n3. Paste the code below into the generated file\n4. Right-click **DemoApplication.java** → **Run As → Spring Boot App**"
SETUP_TIP["eclipse_06"] = "Go to **http://localhost:8080/hello** in your browser. If you see \"**Hello, Spring Boot on Eclipse!**\", your environment setup is **complete**! Also verify that \"**Started DemoApplication**\" appears in the Console view. To stop, click the red **stop button** in the console."

# =============================================================
# Part 3: Chapter Title/Subtitle Translations
# =============================================================
CH = {
    "ch02": ("Output & Variables", "Practice Data Types and Variable Declarations"),
    "ch03": ("Conditional Branching", "Using if and switch Statements"),
    "ch04": ("Loops", "Master for and while Loops"),
    "ch05": ("Methods", "Group and Reuse Code"),
    "ch06": ("Arrays & Lists", "Manage Data in Collections"),
    "ch07": ("Class Fundamentals", "First Steps in Object-Oriented Programming"),
    "ch08": ("Inheritance & Interfaces", "Extending and Unifying Classes"),
    "ch12": ("Polymorphism", "Learn Flexible Design with Polymorphism"),
    "ch13": ("Abstract Classes & Interfaces", "Learn Design-Level Abstraction"),
    "ch09": ("Exception Handling Basics", "Write Error-Resilient Programs"),
    "ch14": ("Advanced Exception Handling", "Multi-catch and try-with-resources"),
    "ch25": ("Practical Exception Handling", "Exception Design and Real-World Patterns"),
    "ch15": ("Java API Essentials", "Standard Libraries: String, Math, and More"),
    "ch26": ("Date & Time API", "Using the java.time Package"),
    "ch30": ("Annotations", "Add Metadata to Your Code"),
    "ch19": ("Java 17 Features", "Records, Sealed Classes & Pattern Matching"),
    "ch21": ("Generics", "Write Type-Safe Code"),
    "ch22": ("Collections Framework", "Master List, Map & Set"),
    "ch16": ("Lambda Expressions", "Fundamentals of Functional Programming"),
    "ch23": ("Functional Interfaces", "Using Function & Predicate"),
    "ch24": ("Stream API", "Write Collection Operations Declaratively"),
    "ch10": ("Database Fundamentals", "Learn SQL and Table Operations"),
    "ch29": ("JDBC", "Connect to Databases from Java"),
    "ch38": ("Introduction to Spring Boot", "Build REST APIs"),
    "ch27": ("Concurrency", "Learn Thread Fundamentals"),
    "ch28": ("I/O & NIO", "Master File Operations"),
    "ch17": ("Module System", "Basics of module-info.java"),
    "ch32": ("Module System Details", "Learn exports and provides"),
    "ch31": ("Localization", "Learn Multilingual Support Basics"),
    "ch20": ("Nested Classes", "Using Inner and Static Nested Classes"),
    "comprehensive_basics": ("Basics Comprehensive Exercises", "Comprehensive Exercises Covering Output, Variables, Conditionals, Loops, Methods & Arrays"),
    "comprehensive_oop": ("OOP Comprehensive Exercises", "Comprehensive Exercises Combining Classes, Inheritance & Polymorphism"),
    "comprehensive_error": ("Error Handling Comprehensive Exercises", "Comprehensive Exercises Combining Exceptions, Custom Exceptions & Multi-catch"),
    "comprehensive_stdlib": ("Standard Library Comprehensive Exercises", "Comprehensive Exercises Covering String, Date/Time & Annotations"),
    "comprehensive_collections": ("Collections Comprehensive Exercises", "Comprehensive Exercises Covering Generics, List, Map & Set"),
    "comprehensive_functional": ("Functional & Stream Comprehensive Exercises", "Comprehensive Exercises Covering Lambda, Functional Interfaces & Stream"),
    "comprehensive_dbweb": ("DB & Web Development Comprehensive Exercises", "Comprehensive Exercises Covering SQL, JDBC & Spring Boot"),
    "comprehensive_concurrency": ("Concurrency & I/O Comprehensive Exercises", "Comprehensive Exercises Covering Threads, File Operations & NIO"),
    "comprehensive_modules": ("Module & i18n Comprehensive Exercises", "Comprehensive Exercises on Module System & Localization"),
}

# =============================================================
# Part 4: Exercise Titles
# =============================================================
ET = {
    "prac_ch02_01": "Print a Self-Introduction",
    "prac_ch02_02": "Display Calculation Results",
    "prac_ch02_03": "Type Casting",
    "prac_ch03_01": "Grade Determination with if Statement",
    "prac_ch03_02": "Day of Week Judgment with switch",
    "prac_ch03_03": "Even/Odd with Ternary Operator",
    "prac_ch04_01": "Sum with for Loop",
    "prac_ch04_03": "Countdown with while Loop",
    "prac_ch04_02": "Multiplication Table with Nested Loops",
    "prac_ch05_01": "Method That Returns Maximum Value",
    "prac_ch05_02": "Method with Variable Arguments",
    "prac_ch05_03": "Method Overloading",
    "prac_ch06_01": "Array Sum and Average",
    "prac_ch06_02": "ArrayList Operations",
    "prac_ch06_03": "Array Sorting and Searching",
    "prac_ch07_01": "Student Class with Constructor",
    "prac_ch07_02": "Encapsulation with Bank Account",
    "prac_ch08_01": "Inheritance (Animal Classes)",
    "prac_ch08_02": "Interface Implementation",
    "prac_ch12_01": "Polymorphism with Shapes",
    "prac_ch13_01": "Abstract Class and Interface",
    "prac_ch09_01": "Division with try-catch",
    "prac_ch09_02": "Custom Exception",
    "prac_ch14_01": "Multi-catch and Exception Chaining",
    "prac_ch25_01": "Exception Chaining in Practice",
    "prac_ch15_01": "String API Methods",
    "prac_ch15_02": "StringBuilder for Efficient Concatenation",
    "prac_ch26_01": "Date Calculation and Formatting",
    "prac_ch30_01": "@Deprecated Annotation",
    "prac_ch19_02": "Text Blocks and Switch Expressions",
    "prac_ch19_01": "Record Classes",
    "prac_ch21_01": "Generic Box Class",
    "prac_ch22_02": "Deduplication with TreeSet",
    "prac_ch22_01": "Word Count with LinkedHashMap",
    "prac_ch16_01": "Sorting with Lambda Expressions",
    "prac_ch23_01": "Filtering with Predicate",
    "prac_ch24_01": "Stream Filter and Aggregate",
    "prac_ch24_02": "Stream String Operations",
    "prac_ch10_01": "SQL Query Writing",
    "prac_ch29_01": "JDBC Database Access",
    "prac_ch38_01": "Spring Boot REST API",
    "prac_ch27_01": "Thread Creation with Runnable",
    "prac_ch28_01": "File Writing and Reading",
    "prac_ch17_01": "Writing module-info.java",
    "prac_ch32_01": "Package Export",
    "prac_ch31_01": "Locale and Number Formatting",
    "prac_ch20_01": "Static Nested Class",
    "comp_basics_01": "Grade Management System",
    "comp_basics_02": "Rock-Paper-Scissors Game",
    "comp_basics_03": "String Processing with Methods",
    "comp_basics_04": "Simple Budget Tracker",
    "comp_basics_05": "Prime Number Checker",
    "comp_basics_06": "Simple Calculator (Reverse Polish Notation)",
    "comp_basics_07": "Maze Path Finding",
    "comp_oop_01": "Library Book Management",
    "comp_oop_02": "Employee Payroll Calculation",
    "comp_oop_03": "Payment Processing with Interfaces",
    "comp_oop_04": "Zoo Simulator",
    "comp_oop_05": "E-Commerce Product Management",
    "comp_oop_06": "Design Pattern: Observer Pattern",
    "comp_oop_07": "Design Pattern: Strategy Pattern",
    "comp_error_01": "Input Value Validator",
    "comp_error_02": "File Reading Simulation",
    "comp_error_03": "Safe Bank Account Operations",
    "comp_error_04": "Configuration File Parser",
    "comp_error_05": "Resource Management Simulation",
    "comp_error_06": "HTTP Client with Retry Mechanism",
    "comp_error_07": "Validation Framework",
    "comp_stdlib_01": "Text Analysis Tool",
    "comp_stdlib_02": "Date Calculation Utility",
    "comp_stdlib_03": "Password Strength Checker",
    "comp_stdlib_04": "Schedule Manager",
    "comp_stdlib_05": "String Transformation Pipeline",
    "comp_stdlib_06": "Regular Expression Parser",
    "comp_stdlib_07": "Config Builder (Builder + sealed)",
    "comp_coll_01": "Student Grade Map",
    "comp_coll_02": "Generic Pair Class",
    "comp_coll_03": "Inventory Management System",
    "comp_coll_04": "Set Operations: Union, Intersection, Difference",
    "comp_coll_05": "Generic Search Method",
    "comp_coll_06": "LRU Cache Implementation",
    "comp_coll_07": "Immutable Collections and Advanced Comparator",
    "comp_func_01": "Sales Aggregation with Stream",
    "comp_func_02": "Function Composition Pipeline",
    "comp_func_03": "Department Grouping with Stream",
    "comp_func_04": "Custom Collectors Implementation",
    "comp_func_05": "Data Transformation Pipeline",
    "comp_func_06": "String Encryption with Functional Pipeline",
    "comp_func_07": "Custom Stream Collector",
    "comp_dbweb_01": "Employee Table Design and CRUD",
    "comp_dbweb_02": "JDBC Connection Pattern",
    "comp_dbweb_03": "REST API Design",
    "comp_dbweb_04": "Transaction Management",
    "comp_dbweb_05": "API Response Design",
    "comp_dbweb_06": "DAO Pattern Design",
    "comp_conc_01": "Countdown Timer",
    "comp_conc_02": "File Read and Write",
    "comp_conc_03": "Multi-Thread Counter",
    "comp_conc_04": "Directory Explorer",
    "comp_conc_05": "Parallel Tasks with ExecutorService",
    "comp_conc_06": "Producer-Consumer Pattern",
    "comp_conc_07": "Async Pipeline with CompletableFuture",
    "comp_mod_01": "Module Dependency Design",
    "comp_mod_02": "Multilingual Greeting Program",
    "comp_mod_03": "Currency Formatter",
    "comp_mod_04": "Internationalized DateTime Display",
    "comp_mod_05": "Multilingual Error Messages",
    "comp_mod_06": "Configuration Management with ResourceBundle",
}


# =============================================================
# Part 5: Main Processing
# =============================================================
def main():
    src = os.path.join(SCRIPT_DIR, "practice_exercises.json")
    with open(src, "r", encoding="utf-8") as f:
        data = json.load(f)

    out = copy.deepcopy(data)
    count = 0

    # --- Setup Guides ---
    setup_title_map = {
        "Windows での Java セットアップ": "Java Setup on Windows",
        "Mac での Java セットアップ": "Java Setup on Mac",
        "データベース環境の準備": "Database Environment Setup",
        "Web アプリ開発環境の準備": "Web App Development Environment Setup",
        "Eclipse での Web アプリ開発環境": "Web App Development with Eclipse",
    }
    step_title_map = {
        "JDK をダウンロード": "Download JDK",
        "インストーラーを実行": "Run the Installer",
        "インストールを確認する": "Verify Installation",
        "エディタ（VS Code）を用意する": "Set Up an Editor (VS Code)",
        "はじめてのプログラムを実行": "Run Your First Program",
        "ターミナルを開く": "Open Terminal",
        "Homebrew をインストール": "Install Homebrew",
        "JDK をインストール": "Install JDK",
        "インストールを確認": "Verify Installation",
        "MySQL とは": "What Is MySQL",
        "MySQL のインストール": "Install MySQL",
        "MySQLの動作確認": "Verify MySQL Is Running",
        "JDBCドライバの準備": "Prepare the JDBC Driver",
        "練習用データベースの作成": "Create the Practice Database",
        "Spring Boot とは": "What Is Spring Boot",
        "Spring Boot プロジェクトの作成": "Create a Spring Boot Project",
        "プロジェクトの起動確認": "Verify Project Startup",
        "Hello World エンドポイントの作成": "Create a Hello World Endpoint",
        "Eclipse とは": "What Is Eclipse",
        "Eclipse（Pleiades）をインストール": "Install Eclipse (Pleiades)",
        "Servlet / JSP プロジェクトを作成する": "Create a Servlet / JSP Project",
        "はじめての Servlet を実行する": "Run Your First Servlet",
        "Spring Boot プロジェクトを Eclipse で作成する": "Create a Spring Boot Project in Eclipse",
        "Eclipse で Spring Boot を実行する": "Run Spring Boot in Eclipse",
    }

    for guide in out.get("setupGuide", []):
        old = guide["title"]
        if old in setup_title_map:
            guide["title"] = setup_title_map[old]; count += 1
        for step in guide.get("steps", []):
            sid = step["id"]
            old_t = step["title"]
            if old_t in step_title_map:
                step["title"] = step_title_map[old_t]; count += 1
            if sid in SETUP_BODY and step.get("body"):
                step["body"] = SETUP_BODY[sid]; count += 1
            if sid in SETUP_TIP and step.get("tip"):
                step["tip"] = SETUP_TIP[sid]; count += 1

    # --- Chapters & Exercises ---
    for chapter in out.get("chapters", []):
        cid = chapter["id"]
        if cid in CH:
            chapter["title"] = CH[cid][0]; count += 1
            chapter["subtitle"] = CH[cid][1]; count += 1

        for ex in chapter.get("exercises", []):
            eid = ex["id"]

            # Title
            if eid in ET:
                ex["title"] = ET[eid]; count += 1

            # SolutionCode (comment + string translation)
            if ex.get("solutionCode"):
                ex["solutionCode"] = translate_solution_code(ex["solutionCode"])
                count += 1

            # ExpectedOutput
            if ex.get("expectedOutput"):
                ex["expectedOutput"] = translate_expected_output(ex["expectedOutput"])
                count += 1

            # Description
            if ex.get("description"):
                if eid in EX_TRANS and "d" in EX_TRANS[eid]:
                    ex["description"] = EX_TRANS[eid]["d"]
                count += 1

            # Hint
            if ex.get("hint"):
                if eid in EX_TRANS and "h" in EX_TRANS[eid]:
                    ex["hint"] = EX_TRANS[eid]["h"]
                count += 1

            # SolutionExplanation
            if ex.get("solutionExplanation"):
                if eid in EX_TRANS and "x" in EX_TRANS[eid]:
                    ex["solutionExplanation"] = EX_TRANS[eid]["x"]
                count += 1

    # --- Write output ---
    dst = os.path.join(SCRIPT_DIR, "practice_exercises_en.json")
    with open(dst, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print(f"Generated: {dst}")
    print(f"Translated fields: {count}")
    
    # Validation
    with open(dst, "r", encoding="utf-8") as f:
        d = json.load(f)
    print(f"Valid JSON: OK")
    print(f"setupGuide: {len(d.get('setupGuide', []))}")
    print(f"chapters: {len(d.get('chapters', []))}")
    total_ex = sum(len(ch.get('exercises', [])) for ch in d.get('chapters', []))
    print(f"Total exercises: {total_ex}")


if __name__ == "__main__":
    main()
