#!/usr/bin/env python3
"""Translate practice_exercises.json from Japanese to English."""
import json
import re

def translate_solution_code(code):
    """Translate Japanese strings inside Java code (comments and string literals)."""
    if code is None:
        return None
    
    # Comments translations
    comment_map = {
        "// 自己紹介を出力するプログラム": "// Program to print a self-introduction",
        "// 文字列型の変数に名前を格納": "// Store the name in a String variable",
        "// 整数型の変数に年齢を格納": "// Store the age in an int variable",
        "// 変数を使って出力": "// Print using variables",
        "// 四則演算の結果を出力するプログラム": "// Program to print arithmetic operation results",
        "// 足し算": "// Addition",
        "// 引き算": "// Subtraction",
        "// 掛け算": "// Multiplication",
        "// 割り算（int同士は小数点以下切り捨て）": "// Division (integer division truncates decimals)",
        "// 余り": "// Remainder",
        "// 型変換（キャスト）を体験するプログラム": "// Program to experience type casting",
        "// double型の変数": "// double variable",
        "// int型にキャスト（小数点以下は切り捨て）": "// Cast to int (decimals are truncated)",
        "// 点数に応じた成績を判定するプログラム": "// Program to determine grade based on score",
        "// if-else if-else で成績を判定": "// Determine grade using if-else if-else",
        "// switch文で曜日を判定するプログラム": "// Program to determine day of week using switch",
        "// switch文による曜日判定": "// Day of week determination using switch",
        "// 三項演算子で偶数・奇数を判定するプログラム": "// Program to determine even/odd using ternary operator",
        "// 三項演算子で偶数・奇数を判定": "// Determine even/odd using ternary operator",
        "// for文で1〜10の合計を計算するプログラム": "// Program to calculate sum of 1-10 using for loop",
        "// for文で1から10まで繰り返す": "// Loop from 1 to 10 using for",
        "// sumにiを加算": "// Add i to sum",
        "// while文でカウントダウンするプログラム": "// Program to count down using while loop",
        "// while文でカウントダウン": "// Count down using while loop",
        "// カウンターを1減らす": "// Decrement counter by 1",
        "// 九九の表を出力するプログラム": "// Program to print multiplication table",
        "// 外側ループ: 段（2〜9）": "// Outer loop: row (2-9)",
        "// 内側ループ: 掛ける数（1〜9）": "// Inner loop: multiplier (1-9)",
        "// 各段の最後に改行": "// Newline at the end of each row",
        "// 最大値を返すメソッドを作るプログラム": "// Program to create a method that returns the maximum value",
        "// 2つの整数のうち大きい方を返すメソッド": "// Method that returns the larger of two integers",
        "// 文字列を繰り返し出力するメソッドのプログラム": "// Program with a method to repeatedly print a string",
        "// メソッドを呼び出して3回出力": "// Call the method to print 3 times",
        "// 指定された回数だけ文字列を出力するメソッド": "// Method that prints a string the specified number of times",
        "// メソッドのオーバーロードを体験するプログラム": "// Program to experience method overloading",
        "// int版が呼ばれる": "// int version is called",
        "// double版が呼ばれる": "// double version is called",
        "// int型の加算メソッド": "// int addition method",
        "// double型の加算メソッド（オーバーロード）": "// double addition method (overload)",
        "// 配列の合計と平均を計算するプログラム": "// Program to calculate array sum and average",
        "// 拡張for文で合計を計算": "// Calculate sum using enhanced for loop",
        "// 平均を計算（doubleで割ることで小数点も取得）": "// Calculate average (cast to double to get decimals)",
        "// ArrayListで名前を管理するプログラム": "// Program to manage names with ArrayList",
        "// ArrayListの作成": "// Create ArrayList",
        "// 名前を追加": "// Add names",
        "// 一覧表示": "// Display list",
        "// 「鈴木」を削除": "// Remove \"Suzuki\"",
        "// 再度一覧表示": "// Display list again",
        "// 配列のソートと検索を行うプログラム": "// Program to sort and search arrays",
        "// 配列をソート（昇順）": "// Sort array (ascending)",
        "// ソート後の配列を出力": "// Print sorted array",
        "// ソート済み配列から45を二分探索": "// Binary search for 45 in sorted array",
        "// 学生情報を管理するクラス": "// Class to manage student information",
        "// フィールド（属性）": "// Fields (attributes)",
        "// コンストラクタ（初期値を設定）": "// Constructor (set initial values)",
        "// 情報を出力するメソッド": "// Method to print information",
        "// メインメソッド（実行用）": "// Main method (for execution)",
        "// カプセル化を実践する銀行口座クラス": "// Bank account class demonstrating encapsulation",
        "// 残高を外部から直接操作できないように private にする": "// Make balance private to prevent direct external access",
        "// コンストラクタ": "// Constructor",
        "// 入金メソッド": "// Deposit method",
        "// 出金メソッド（残高不足チェック付き）": "// Withdrawal method (with insufficient balance check)",
        "// 残高取得メソッド（getter）": "// Balance getter method",
        "// 親クラス": "// Parent class",
        "// 子クラス: Dog": "// Child class: Dog",
        "// 子クラス: Cat": "// Child class: Cat",
        "// インターフェース定義": "// Interface definition",
        "// Reportクラスがインターフェースを実装": "// Report class implements the interface",
        "// Invoiceクラスもインターフェースを実装": "// Invoice class also implements the interface",
        "// 円クラス": "// Circle class",
        "// 長方形クラス": "// Rectangle class",
        "// Shape型の配列にCircleとRectangleを格納": "// Store Circle and Rectangle in Shape array",
        "// ポリモーフィズム: 同じメソッド呼び出しで異なる処理が実行される": "// Polymorphism: same method call executes different logic",
        "// 抽象クラス（直接インスタンス化できない）": "// Abstract class (cannot be directly instantiated)",
        "// 抽象メソッド（子クラスで必ず実装する）": "// Abstract method (must be implemented by child classes)",
        "// 具象メソッド（共通処理）": "// Concrete method (shared functionality)",
        "// try-catchでゼロ除算を安全に処理するプログラム": "// Program to safely handle division by zero with try-catch",
        "// ゼロで割ると ArithmeticException が発生": "// Division by zero throws ArithmeticException",
        "// 例外をキャッチして安全に処理": "// Catch exception and handle safely",
        "// 例外が発生しても処理は続行される": "// Processing continues even after exception",
        "// 独自例外クラス": "// Custom exception class",
        "// 年齢を検証するメソッド": "// Method to validate age",
        "// エラーメッセージを動的に取得": "// Dynamically retrieve error message",
        "// マルチキャッチ構文を使ったプログラム": "// Program using multi-catch syntax",
        "// 配列の範囲外アクセスまたは数値変換エラーの可能性": "// Possible array out-of-bounds or number format error",
        "// 複数の例外を1つの catch で処理": "// Handle multiple exceptions in a single catch",
        "// 原因の例外も受け取るコンストラクタ": "// Constructor that also accepts the cause exception",
        "// 元の例外を原因として新しい例外にラップ": "// Wrap original exception as cause in new exception",
        "// Stringクラスの主要メソッドを使うプログラム": "// Program using main String class methods",
        "// 大文字に変換": "// Convert to uppercase",
        "// 文字数": "// Character count",
        "// 部分文字列（インデックス7から11の手前まで）": "// Substring (from index 7 to just before 11)",
        "// 文字列の置換": "// String replacement",
        "// StringBuilderで文字列を効率的に連結するプログラム": "// Program to efficiently concatenate strings with StringBuilder",
        "// 1から5を追加": "// Add 1 through 5",
        "// 日付の計算と書式化を行うプログラム": "// Program for date calculation and formatting",
        "// 今日の日付を取得": "// Get today's date",
        "// 書式を指定": "// Specify format",
        "// 30日後の日付": "// Date 30 days later",
        "// @Deprecatedアノテーションの使い方を学ぶプログラム": "// Program to learn how to use @Deprecated annotation",
        "// 非推奨メソッド（使用すると警告が出る）": "// Deprecated method (using it generates a warning)",
        "// 新しいメソッド": "// New method",
        "// テキストブロックを使うプログラム": "// Program using text blocks",
        "// テキストブロック（Java 13+）": "// Text block (Java 13+)",
        "// switch式（arrow構文）を使うプログラム": "// Program using switch expression (arrow syntax)",
        "// switch式で季節を判定（値を返す）": "// Determine season using switch expression (returns value)",
        "// 型パラメータTを持つジェネリクスクラス": "// Generic class with type parameter T",
        "// String型のBox": "// Box of type String",
        "// Integer型のBox": "// Box of type Integer",
        "// TreeSetで重複除去とソートを行うプログラム": "// Program for deduplication and sorting with TreeSet",
        "// TreeSetで重複除去 + ソート": "// Deduplicate + sort with TreeSet",
        "// LinkedHashMapで単語の出現回数を数えるプログラム": "// Program to count word occurrences with LinkedHashMap",
        "// 挿入順を保持するLinkedHashMapで管理": "// Manage with LinkedHashMap preserving insertion order",
        "// 既存の値があれば+1、なければ0+1": "// If existing value, +1; otherwise 0+1",
        "// 結果を出力（挿入順で表示される）": "// Output results (displayed in insertion order)",
        "// ラムダ式でリストをソートするプログラム": "// Program to sort list with lambda expression",
        "// ラムダ式でアルファベット順にソート": "// Sort alphabetically with lambda expression",
        "// Predicateで条件フィルタを行うプログラム": "// Program for conditional filtering with Predicate",
        "// 偶数判定のPredicate": "// Predicate for even number check",
        "// フィルタリング": "// Filtering",
        "// Stream APIでフィルタ・変換・集約を行うプログラム": "// Program to filter, transform, and aggregate with Stream API",
        "// Stream: フィルタ → 変換(2乗) → 合計": "// Stream: filter → transform (square) → sum",
        "// 偶数のみ": "// Even numbers only",
        "// 2乗に変換": "// Transform to square",
        "// 合計": "// Sum",
        "// Streamで文字列操作を行うプログラム": "// Program for string manipulation with Stream",
        "// 5文字以上 → 大文字 → カンマ区切り": "// 5+ characters → uppercase → comma separated",
        "// 開発部の社員を給与の高い順に取得するSQL": "// SQL to get dev dept employees ordered by salary descending",
        "// JDBCでデータベースから情報を取得するプログラム": "// Program to retrieve information from database using JDBC",
        "// 接続情報（環境に合わせて変更してください）": "// Connection info (change according to your environment)",
        "// try-with-resources でリソースを自動解放": "// Auto-release resources with try-with-resources",
        "// 結果を1行ずつ読み取り": "// Read results one row at a time",
        "// Spring Boot REST APIの作成": "// Creating a Spring Boot REST API",
        "// GET /api/greeting?name=太郎 にアクセスすると実行される": "// Executed when accessing GET /api/greeting?name=Taro",
        "// Runnableでスレッドを作成するプログラム": "// Program to create threads with Runnable",
        "// ラムダ式でRunnableを実装": "// Implement Runnable with lambda expression",
        "// スレッドを開始": "// Start threads",
        "// ファイルの書き込みと読み込みを行うプログラム": "// Program for file writing and reading",
        "// ファイルに書き込み": "// Write to file",
        "// ファイルを読み込み": "// Read file",
        "// 後片付け": "// Cleanup",
        "// モジュール宣言ファイル": "// Module declaration file",
        "// java.sql モジュール（JDBC）に依存": "// Depends on java.sql module (JDBC)",
        "// パッケージの公開範囲を制御するモジュール宣言": "// Module declaration controlling package visibility",
        "// 外部に公開するパッケージ": "// Package exported to external modules",
        "// com.mylib.internal は exports しないため": "// Since com.mylib.internal is not exported",
        "// 他のモジュールからはアクセスできない": "// It cannot be accessed from other modules",
        "// Localeによる数値フォーマットのプログラム": "// Program for number formatting with Locale",
        "// 各国のフォーマッタで数値を書式化": "// Format number with each country's formatter",
        "// 静的ネストクラスのプログラム": "// Program for static nested class",
        "// 静的ネストクラス": "// Static nested class",
        "// 外側クラスのインスタンスなしで生成可能": "// Can be created without outer class instance",
        "// 成績管理: 配列・ループ・条件分岐の総合演習": "// Grade management: comprehensive exercise for arrays, loops, conditionals",
        "// 5人の点数を配列で管理": "// Manage scores of 5 students in array",
        "// 最高点の初期値": "// Initial value for max score",
        "// 最低点の初期値": "// Initial value for min score",
        "// 全要素を走査して合計・最大・最小を求める": "// Traverse all elements to find sum, max, min",
        "// 平均（double型にキャストして小数点を保持）": "// Average (cast to double to preserve decimals)",
        "// じゃんけんゲーム: 条件分岐・変数・メソッドの総合演習": "// Rock-Paper-Scissors: comprehensive exercise for conditionals, variables, methods",
        "// 手の名前を返すメソッド": "// Method to return hand name",
        "// コンピュータの手をランダムに決定": "// Randomly determine computer's hand",
        "// 勝敗判定": "// Win/loss determination",
        "// メソッド分割: 責務の分離と再利用性の総合演習": "// Method decomposition: comprehensive exercise for separation of concerns and reusability",
        "// 文字数を返すメソッド": "// Method to return character count",
        "// 大文字に変換するメソッド": "// Method to convert to uppercase",
        "// 逆順にするメソッド": "// Method to reverse",
        "// 簡易家計簿: ArrayList・メソッド分割の総合演習": "// Simple budget tracker: comprehensive exercise for ArrayList and method decomposition",
        "// リストの合計を求めるメソッド": "// Method to calculate list total",
        "// 収入リスト": "// Income list",
        "// 支出リスト": "// Expense list",
        "// 素数判定: ネストfor文・メソッド分割・boolean型の総合演習": "// Prime check: comprehensive exercise for nested for loops, methods, boolean",
        "// 素数判定メソッド": "// Prime check method",
        "// 2未満は素数でない": "// Numbers less than 2 are not prime",
        "// 2からnの平方根まで割り切れるか確認": "// Check divisibility from 2 to sqrt(n)",
        "// 割り切れたら素数でない": "// If divisible, it's not prime",
        "// どれでも割り切れなければ素数": "// If not divisible by any, it's prime",
        "// 文字列表現をオーバーライド": "// Override string representation",
        "// 抽象クラス: 従業員": "// Abstract class: Employee",
        "// 給与計算（サブクラスで実装）": "// Calculate salary (implemented by subclasses)",
        "// 正社員: 月給制": "// Full-time employee: monthly salary",
        "// パート: 時給制": "// Part-time employee: hourly wage",
        "// 支払いインターフェース": "// Payment interface",
        "// クレジットカード支払い": "// Credit card payment",
        "// 銀行振込": "// Bank transfer",
        "// 現金支払い": "// Cash payment",
        "// インターフェース型の配列で統一管理": "// Unified management with interface-type array",
        "// 泳げることを表すインターフェース": "// Interface representing ability to swim",
        "// 動物の抽象クラス": "// Abstract class for animals",
        "// 商品インターフェース": "// Product interface",
        "// 物理商品": "// Physical product",
        "// デジタル商品": "// Digital product",
        "// サブスクリプション商品": "// Subscription product",
        "// カート": "// Cart",
        "// 独自例外: データ破損": "// Custom exception: Data corruption",
        "// ファイル読み込みシミュレーション": "// File reading simulation",
        "// 入力値バリデーション: try-catch の総合演習": "// Input validation: comprehensive exercise for try-catch",
        "// テキスト分析: String API の総合演習": "// Text analysis: comprehensive exercise for String API",
        "// 曜日を日本語に変換": "// Convert day of week to Japanese",
        "// 2日間の期間を計算": "// Calculate period between two dates",
        "// 月末日を計算": "// Calculate last day of month",
        "// パスワード強度: String API・char操作の総合演習": "// Password strength: comprehensive exercise for String API and char operations",
        "// 1. 長さ（8文字以上）": "// 1. Length (8 or more characters)",
        "// 文字列パイプライン: String API・StringBuilder の総合演習": "// String pipeline: comprehensive exercise for String API and StringBuilder",
        "// 1. トリム": "// 1. Trim",
        "// 2. 大文字化": "// 2. Uppercase",
        "// 3. 文字置換": "// 3. Character replacement",
        "// 4. 反転": "// 4. Reverse",
        "// 成績管理: Map・List・ジェネリクスの総合演習": "// Grade management: comprehensive exercise for Map, List, Generics",
        "// 複合ソート": "// Compound sort",
        "// 部門別平均給与": "// Average salary by department",
        "// 統計情報集約: IntSummaryStatistics の総合演習": "// Statistics aggregation: comprehensive exercise for IntSummaryStatistics",
        "// IntSummaryStatistics で統計を一括取得": "// Get all statistics at once with IntSummaryStatistics",
        "// 関数合成: Function・andThen の総合演習": "// Function composition: comprehensive exercise for Function and andThen",
        "// 3つの変換関数を定義": "// Define 3 transformation functions",
        "// andThen で合成: trim → 大文字 → 接頭辞追加": "// Compose with andThen: trim → uppercase → add prefix",
        "// 文字列リストに適用": "// Apply to string list",
        "// タイマー: Thread・sleep の総合演習": "// Timer: comprehensive exercise for Thread and sleep",
        "// ファイル操作: NIO2 の総合演習": "// File operations: comprehensive exercise for NIO2",
        "// 書き込み": "// Write",
        "// 読み込み（行番号付き）": "// Read (with line numbers)",
        "// クリーンアップ": "// Cleanup",
        "// スレッドセーフカウンター: synchronized, AtomicInteger の総合演習": "// Thread-safe counter: comprehensive exercise for synchronized and AtomicInteger",
        "// ディレクトリ探索: NIO2・Stream の総合演習": "// Directory exploration: comprehensive exercise for NIO2 and Stream",
        "// ファイルを拡張子でグルーピング": "// Group files by extension",
        "// 各拡張子の情報を表示": "// Display info for each extension",
        "// 並列タスク: ExecutorService・Future の総合演習": "// Parallel tasks: comprehensive exercise for ExecutorService and Future",
        "// 固定サイズのスレッドプール": "// Fixed-size thread pool",
        "// Callableタスクを定義": "// Define Callable tasks",
        "// タスク送信": "// Submit tasks",
        "// 結果取得": "// Get results",
        "// ブロッキング待機": "// Blocking wait",
        "// 社員CRUD: SQL基礎の総合演習": "// Employee CRUD: comprehensive exercise for SQL basics",
        "// ※ 実際のDB接続なしでSQL文を出力するデモ": "// Demo that outputs SQL statements without actual DB connection",
        "// JDBC接続: PreparedStatement の総合演習": "// JDBC connection: comprehensive exercise for PreparedStatement",
        "// テーブル作成": "// Create table",
        "// PreparedStatementで検索": "// Search with PreparedStatement",
        "// REST API: Spring Boot コントローラの総合演習": "// REST API: comprehensive exercise for Spring Boot controller",
        "// GET: 商品一覧": "// GET: Product list",
        "// GET: 商品詳細（ID指定）": "// GET: Product detail (by ID)",
        "// POST: 商品追加": "// POST: Add product",
        "// DELETE: 商品削除": "// DELETE: Delete product",
        "// トランザクション: commit/rollback の総合演習": "// Transaction: comprehensive exercise for commit/rollback",
        "// 準備": "// Setup",
        "// 送金1: 成功ケース": "// Transfer 1: Success case",
        "// 送金2: 残高不足 → ロールバック": "// Transfer 2: Insufficient balance → rollback",
        "// 残高チェック": "// Balance check",
        "// 引き落とし": "// Withdrawal",
        "// 入金": "// Deposit",
        "// モジュール設計: module-info の総合演習": "// Module design: comprehensive exercise for module-info",
        "// module-info.java の内容を設計": "// Design module-info.java contents",
        "// 多言語あいさつ: Locale・国際化の総合演習": "// Multilingual greeting: comprehensive exercise for Locale and i18n",
        "// ロケールごとのメッセージ（ResourceBundle の代替）": "// Messages per locale (substitute for ResourceBundle)",
        "// 通貨フォーマット: NumberFormat の総合演習": "// Currency format: comprehensive exercise for NumberFormat",
        "// 日本円": "// Japanese Yen",
        "// 米ドル": "// US Dollar",
        "// ユーロ（ドイツ）": "// Euro (Germany)",
        "// 日時国際化: ZonedDateTime, Locale の総合演習": "// DateTime i18n: comprehensive exercise for ZonedDateTime and Locale",
        "// 日本時間の日時": "// DateTime in Japan time",
        "// 各ロケール・タイムゾーンで表示": "// Display in each locale/timezone",
        "// 日本": "// Japan",
        "// 米国（中部時間）": "// US (Central Time)",
        "// フランス": "// France",
        "// 日本語": "// Japanese",
        "// 英語": "// English",
        "// 存在しないキー": "// Non-existent key",
        "// 正常": "// Normal",
        "// null": "// null",
        "// 短く不正な形式": "// Short and invalid format",
        "// シーザー暗号（+shift）": "// Caesar cipher (+shift)",
        "// 文字列反転": "// String reversal",
        "// Base64エンコード / デコード": "// Base64 encode / decode",
        "// 暗号化パイプライン": "// Encryption pipeline",
        "// 復号パイプライン（逆順 × 逆操作）": "// Decryption pipeline (reverse order × inverse operations)",
        "// --- 統計情報 ---": "// --- Statistics ---",
        "// --- 上位N件 ---": "// --- Top N ---",
        "// 数値キーの型チェック": "// Type check for numeric keys",
        "// 原因例外をチェーンしてConfigExceptionとして再スロー": "// Chain cause exception and rethrow as ConfigException",
        "// try-with-resources: 宣言順の逆順で自動close": "// try-with-resources: auto-close in reverse declaration order",
        "// ターミナルで実行（順番に入力してください）:": "// Run in terminal (enter in order):",
        "// ターミナルで実行:": "// Run in terminal:",
        "// HelloWorld.java の doGet メソッド": "// HelloWorld.java doGet method",
        "// HelloController.java": "// HelloController.java",
        "// Homebrewが入っているか確認": "// Check if Homebrew is installed",
        "// 入っていない場合は以下をコピー&ペーストして実行": "// If not installed, copy & paste the following to run",
        "// JDK 17 をインストール": "// Install JDK 17",
        "// システムが JDK を認識するようにリンクを作成": "// Create link so the system recognizes JDK",
        "// Mac: MySQLのインストールと起動": "// Mac: Install and start MySQL",
        "// rootパスワードを設定": "// Set root password",
        "// MySQLにログイン": "// Log in to MySQL",
        "// ログインできたら、以下を実行してデータベース一覧を表示": "// Once logged in, execute the following to show database list",
        "// 確認できたらログアウト": "// Log out after confirming",
        "// コンパイル時にJDBCドライバを指定（Mac/Linux）": "// Specify JDBC driver at compile time (Mac/Linux)",
        "// Windows の場合は区切り文字が ; になります": "// On Windows, the separator is ;",
        "// 1. データベースを作成": "// 1. Create database",
        "// 2. テーブルを作成": "// 2. Create table",
        "// 3. サンプルデータを挿入": "// 3. Insert sample data",
        "// SelfIntroduction.java": "// SelfIntroduction.java",
        # === Additional missing comment translations ===
        "// プレイヤーの手（グー）": "// Player's hand (Rock)",
        "// 給与": "// Salary",
        "// 副業": "// Side job",
        "// ボーナス": "// Bonus",
        "// 家賃": "// Rent",
        "// 食費": "// Food",
        "// 光熱費": "// Utilities",
        "// その他": "// Others",
        "// ポリモーフィズム": "// Polymorphism",
        "// 最初の2回は失敗をシミュレート": "// Simulate failure for the first 2 attempts",
        "// リトライ不可": "// Not retryable",
        "// null = OK, 非null = エラーメッセージ": "// null = OK, non-null = error message",
        "// nullチェックは別ルールに任せる": "// Null check is handled by a separate rule",
        "// 日付計算: java.time API の総合演習": "// Date calculation: java.time API comprehensive exercise",
        "// ジェネリクスペア: 複数型パラメータの総合演習": "// Generics pair: multiple type parameter comprehensive exercise",
        "// AとBを入れ替えた新しいPairを返す": "// Returns a new Pair with A and B swapped",
        "// 集合演算: Set API の総合演習": "// Set operations: Set API comprehensive exercise",
        "// 積集合（共通要素）": "// Intersection (common elements)",
        "// 和集合（全要素）": "// Union (all elements)",
        "// 差集合（AにあってBにない）": "// Difference (in A but not in B)",
        "// ジェネリクスメソッド: 汎用検索の総合演習": "// Generic method: generic search comprehensive exercise",
        "// ジェネリクスメソッド: 条件に合う要素をリストで返す": "// Generic method: Returns elements matching the condition as a list",
        "// Integer型で使用": "// Usage with Integer type",
        "// String型で使用": "// Usage with String type",
        "// Sum金額": "// Total amount",
        "// 最高額商品": "// Highest-priced product",
        "// 1000円以上の商品数": "// Number of products 1000 yen or more",
        "// 部署別にグルーピング": "// Group by department",
        "// CSV → Person変換": "// CSV → Person conversion",
        "// 30歳以上フィルタ": "// Filter for age 30+",
        "// 年齢降順ソート": "// Sort by age descending",
        "// 整形出力": "// Formatted output",
        "// 最小を除去": "// Remove the minimum",
        "// サマリ": "// Summary",
        "// ERROR詳細": "// ERROR details",
        "// 成功レスポンスのファクトリ": "// Success response factory",
        "// エラーレスポンスのファクトリ": "// Error response factory",
        "// 商品検索（IDで検索）": "// Product search (by ID)",
        "// 1秒待機": "// Wait 1 second",
        "// メインスレッドで完了を待機": "// Wait for completion on main thread",
        "// === synchronized なし ===": "// === Without synchronized ===",
        "// === synchronized あり ===": "// === With synchronized ===",
        "// カレントディレクトリ": "// Current directory",
        "// 処理時間シミュレート": "// Simulate processing time",
        "// transitive経由でcom.example.modelも利用可能": "// com.example.model also available via transitive",
        "// Japan語": "// Japanese",
        "// ?に値をバインド": "// Bind value to ?",
        "// 非推奨だが呼び出し可能": "// Deprecated but still callable",
        "// Character countを返すメソッド": "// Method that returns character count",
        "// Convert to uppercaseするメソッド": "// Method that converts to uppercase",
    }
    
    # String literal translations
    string_map = {
        '"名前: "': '"Name: "',
        '"年齢: "': '"Age: "',
        '"太郎"': '"Taro"',
        '"歳"': '""',
        '"点数: "': '"Score: "',
        '"成績: 優"': '"Grade: Excellent"',
        '"成績: 良"': '"Grade: Good"',
        '"成績: 可"': '"Grade: Fair"',
        '"成績: 不可"': '"Grade: Fail"',
        '"曜日番号: "': '"Day number: "',
        '"月曜日"': '"Monday"',
        '"火曜日"': '"Tuesday"',
        '"水曜日"': '"Wednesday"',
        '"木曜日"': '"Thursday"',
        '"金曜日"': '"Friday"',
        '"土曜日"': '"Saturday"',
        '"日曜日"': '"Sunday"',
        '"不正な値です"': '"Invalid value"',
        '"偶数"': '"even"',
        '"奇数"': '"odd"',
        '" は "': '" is "',
        '" です"': '""',
        '"1から10までの合計: "': '"Sum from 1 to 10: "',
        '"発射！"': '"Liftoff!"',
        '"元の価格: "': '"Original price: "',
        '"整数に変換: "': '"Converted to int: "',
        '"ソート後: "': '"After sorting: "',
        '"45 の位置: "': '"Position of 45: "',
        '"合計: "': '"Total: "',
        '"平均: "': '"Average: "',
        '"--- 追加後 ---"': '"--- After adding ---"',
        '"田中"': '"Tanaka"',
        '"鈴木"': '"Suzuki"',
        '"佐藤"': '"Sato"',
        '"--- 削除後 ---"': '"--- After removing ---"',
        '"名前: "': '"Name: "',
        '"ワンワン！"': '"Woof!"',
        '"ニャー！"': '"Meow!"',
        '"レポート: "': '"Report: "',
        '"月次報告書"': '"Monthly Report"',
        '"請求書: #"': '"Invoice: #"',
        '"残高: "': '"Balance: "',
        '"入金後: "': '"After deposit: "',
        '"出金後: "': '"After withdrawal: "',
        '"計算を実行します..."': '"Executing calculation..."',
        '"ゼロでは割れません"': '"Cannot divide by zero"',
        '"処理を続行します"': '"Continuing processing"',
        '"結果: "': '"Result: "',
        '"不正な年齢です: "': '"Invalid age: "',
        '"エラー: "': '"Error: "',
        '"配列エラーまたは数値変換エラーが発生しました"': '"Array error or number format error occurred"',
        '"値: "': '"Value: "',
        '"データ処理に失敗しました"': '"Data processing failed"',
        '"元の文字列: "': '"Original string: "',
        '"大文字: "': '"Uppercase: "',
        '"文字数: "': '"Length: "',
        '"部分文字列: "': '"Substring: "',
        '"置換後: "': '"After replace: "',
        '"今日: "': '"Today: "',
        '"30日後: "': '"30 days later: "',
        '"[非推奨メソッド] 古い処理"': '"[Deprecated] Old logic"',
        '"[新メソッド] 新しい処理"': '"[New Method] New logic"',
        '"春"': '"Spring"',
        '"夏"': '"Summer"',
        '"秋"': '"Autumn"',
        '"冬"': '"Winter"',
        '"不明"': '"Unknown"',
        '"文字列の箱: "': '"String box: "',
        '"数値の箱: "': '"Number box: "',
        '"重複除去後: "': '"After deduplication: "',
        '"ソート後: "': '"After sorting: "',
        '"偶数: "': '"Even numbers: "',
        '"偶数の2乗の合計: "': '"Sum of squares of even numbers: "',
        '"結果: "': '"Result: "',
        '"電気自動車"': '"Electric car"',
        '"電気"': '"Electricity"',
        '"ガソリン車"': '"Gasoline car"',
        '"ガソリン"': '"Gasoline"',
        '"円"': '"circle"',
        '"長方形"': '"rectangle"',
        '"グー"': '"Rock"',
        '"チョキ"': '"Scissors"',
        '"パー"': '"Paper"',
        '"結果: あいこ"': '"Result: Draw"',
        '"結果: 勝ち！"': '"Result: You win!"',
        '"結果: 負け..."': '"Result: You lose..."',
        '"元の文字列: "': '"Original string: "',
        '"=== 家計簿 ==="': '"=== Budget Tracker ==="',
        '"合計収入: "': '"Total income: "',
        '"合計支出: "': '"Total expense: "',
        '"残高: "': '"Balance: "',
        '"黒字です"': '"in the black"',
        '"赤字です"': '"in the red"',
        '"最高点: "': '"Highest: "',
        '"最低点: "': '"Lowest: "',
        '"=== 図書館の蔵書 ==="': '"=== Library Collection ==="',
        '"Java入門"': '"Introduction to Java"',
        '"山田太郎"': '"Taro Yamada"',
        '"デザインパターン"': '"Design Patterns"',
        '"鈴木花子"': '"Hanako Suzuki"',
        '"データベース基礎"': '"Database Fundamentals"',
        '"田中一郎"': '"Ichiro Tanaka"',
        '"=== 給与明細 ==="': '"=== Payroll ==="',
        '"正社員"': '"Full-time"',
        '"パート"': '"Part-time"',
        '"=== 支払い処理 ==="': '"=== Payment Processing ==="',
        '"クレジットカードで"': '"Paid by credit card: "',
        '"銀行振込で"': '"Sent by bank transfer: "',
        '"現金で"': '"Paid in cash: "',
        '"円を支払いました"': '" yen"',
        '"円を送金しました"': '" yen"',
        '"=== 動物園 ==="': '"=== Zoo ==="',
        '"ワンワン！"': '"Woof!"',
        '"ニャー！"': '"Meow!"',
        '"ピーピー！"': '"Tweet tweet!"',
        '"歩く"': '"walk"',
        '"飛ぶ"': '"fly"',
        '"[泳げる]"': '"[can swim]"',
        '"ポチ"': '"Pochi"',
        '"タマ"': '"Tama"',
        '"ピーちゃん"': '"Tweety"',
        '"物理"': '"Physical"',
        '"DL"': '"DL"',
        '"定額"': '"Subscription"',
        '"（月額）"': '" (Monthly)"',
        '"=== カート内容 ==="': '"=== Cart Contents ==="',
        '"Java教科書"': '"Java Textbook"',
        '"オンライン講座"': '"Online Course"',
        '"Proプラン"': '"Pro Plan"',
        '"合計: "': '"Total: "',
        '"[価格表示] "': '"[Price Display] "',
        '"[アラート] "': '"[Alert] "',
        '" が閾値 "': '" exceeded threshold "',
        '" を超えました！現在値: "': '"! Current value: "',
        '"[アラート解除] "': '"[Alert Cleared] "',
        '" が閾値 "': '" is at or below threshold "',
        '" 以下に戻りました。現在値: "': '". Current value: "',
        '"割引なし: "': '"No discount: "',
        '"20%割引: "': '"20% discount: "',
        '"3000円引き: "': '"3000 yen off: "',
        '"式が不正です"': '"Invalid expression"',
        '"不正なトークン: "': '"Invalid token: "',
        '"0で割ることはできません"': '"Cannot divide by zero"',
        '"不正な演算子: "': '"Invalid operator: "',
        '"式: "': '"Expression: "',
        '"経路が見つかりません"': '"No path found"',
        '"預金: "': '"Deposit: "',
        '" → 残高: "': '" → Balance: "',
        '"引出: "': '"Withdrawal: "',
        '"残高不足です（残高: "': '"Insufficient funds (balance: "',
        '"金額は正の数を指定してください"': '"Amount must be a positive number"',
        '"FileNotFoundException"': '"FileNotFoundException"',
        '"DataCorruptException"': '"DataCorruptException"',
        '"読み込み成功"': '"Read successful"',
        '"finallyブロック実行"': '"finally block executed"',
        '"DB接続を開きました"': '"DB connection opened"',
        '"ファイルを開きました"': '"File opened"',
        '"DB操作: "': '"DB operation: "',
        '"実行中..."': '"executing..."',
        '"ファイル操作: "': '"File operation: "',
        '"中..."': '"..."',
        '"書き込み"': '"writing"',
        '"DB接続を閉じました"': '"DB connection closed"',
        '"ファイルを閉じました"': '"File closed"',
        '"接続タイムアウト"': '"Connection timeout"',
        '"レスポンス 200 OK"': '"Response 200 OK"',
        '"中断されました"': '"Interrupted"',
        '"成功: "': '"Success: "',
        '"最終失敗: "': '"Final failure: "',
        '"値がnullです"': '"Value is null"',
        '"文字以上で入力してください"': '" or more characters required"',
        '"メールアドレスの形式が不正です"': '"Invalid email format"',
        '"検証成功: "': '"Validation success: "',
        '"検証エラー:"': '"Validation errors:"',
        '"  - "': '"  - "',
        '"フォーマットが不正です: \'=\'がありません"': '"Invalid format: \'=\' not found"',
        '"値の型が不正です: \'"': '"Invalid value type: \'"',
        '"\'は整数ではありません"': '"\' is not an integer"',
        '"設定の解析に失敗"': '"Failed to parse configuration"',
        '" → OK: "': '" → OK: "',
        '" → エラー: "': '" → Error: "',
        '"  原因: "': '"  Cause: "',
        '"=== テキスト分析 ==="': '"=== Text Analysis ==="',
        '"=== スケジュール ==="': '"=== Schedule ==="',
        '"過去"': '"Past"',
        '"未来"': '"Future"',
        '"クリスマスパーティ"': '"Christmas Party"',
        '"Java試験"': '"Java Exam"',
        '"新学期開始"': '"New Semester Begins"',
        '"タスク"': '"Task"',
        '"認証に失敗しました"': '"Authentication failed"',
        '"アクセス権がありません"': '"Access denied"',
        '"不明なエラーが発生しました"': '"An unknown error occurred"',
        '"こんにちは"': '"Hello"',
        '"世界"': '"World"',
        '"金額: "': '"Amount: "',
        '"ようこそ"': '"Welcome"',
        '"入力値が不正です"': '"Invalid input"',
        '"(デフォルト値)"': '"(Default value)"',
        '"=== モジュール構成 ==="': '"=== Module Structure ==="',
        '"カウントダウン開始！"': '"Countdown start!"',
        '"\\n時間です！"': '"\\nTime\'s up!"',
        '"ファイル書き込み完了: "': '"File write complete: "',
        '"=== ファイル内容 ==="': '"=== File Contents ==="',
        '"NIO2でファイル操作"': '"File operations with NIO2"',
        '"簡単で安全です"': '"Easy and safe"',
        '"=== synchronized なし ==="': '"=== Without synchronized ==="',
        '"期待値: "': '"Expected: "',
        '", 実際: "': '", Actual: "',
        '"=== synchronized あり ==="': '"=== With synchronized ==="',
        '"=== AtomicInteger ==="': '"=== AtomicInteger ==="',
        '"=== ディレクトリ探索: "': '"=== Directory Exploration: "',
        '" ===\"': '" ==="',
        '"(拡張子なし)"': '"(no extension)"',
        '"タスク送信: "': '"Tasks submitted: "',
        '"件"': '" items"',
        '"全タスク完了"': '"All tasks completed"',
        '"計算完了（値: 100）"': '"Calculation done (value: 100)"',
        '"計算完了（値: 200）"': '"Calculation done (value: 200)"',
        '"計算完了（値: 300）"': '"Calculation done (value: 300)"',
        '"=== テーブル作成 ==="': '"=== Create Table ==="',
        '"INSERT成功: "': '"INSERT success: "',
        '"SELECT結果: 山田太郎（営業部）"': '"SELECT result: Taro Yamada (Sales)"',
        '"UPDATE成功: 給与更新"': '"UPDATE success: Salary updated"',
        '"DELETE成功: 1件削除"': '"DELETE success: 1 row deleted"',
        '"接続URL: "': '"Connection URL: "',
        '"スキーマ作成完了"': '"Schema creation complete"',
        '"検索結果:"': '"Search results:"',
        '"DBエラー: "': '"DB error: "',
        '"追加完了"': '"Add complete"',
        '"削除完了"': '"Delete complete"',
        '"送金前: "': '"Before transfer: "',
        '"送金処理: "': '"Transfer: "',
        '"送金後: "': '"After transfer: "',
        '"残高不足"': '"Insufficient balance"',
        '" → ロールバック"': '" → Rollback"',
        '"残高変化なし: "': '"Balance unchanged: "',
        '"成功: "': '"Success: "',
        '"エラー: "': '"Error: "',
        '"商品が見つかりません"': '"Product not found"',
        '"保存: "': '"Saved: "',
        '"全件: "': '"All records: "',
        '"削除後: "': '"After deletion: "',
        '"[Producer] タスク投入: "': '"[Producer] Task submitted: "',
        '"[Producer] 全タスク投入完了"': '"[Producer] All tasks submitted"',
        '"[Consumer] 終了シグナル受信。停止します。"': '"[Consumer] Stop signal received. Shutting down."',
        '"[Consumer] 処理中: "': '"[Consumer] Processing: "',
        '"全処理完了"': '"All processing complete"',
        '"[在庫確認] "': '"[Stock Check] "',
        '": OK"': '": OK"',
        '"在庫がありません"': '"Out of stock"',
        '"[価格計算] "': '"[Price Calc] "',
        '"円（15%OFF）"': '" yen (15% OFF)"',
        '"[決済完了] "': '"[Payment Done] "',
        '"[エラー] "': '"[Error] "',
        '"全注文処理完了"': '"All order processing complete"',
        '"完了"': '"Done"',
        '"営業部"': '"Sales"',
        '"開発部"': '"Development"',
        '"人事部"': '"HR"',
        '"りんご"': '"Apple"',
        '"バナナ"': '"Banana"',
        '"みかん"': '"Orange"',
        '"=== 在庫一覧 ==="': '"=== Inventory List ==="',
        '"個"': '" units"',
        '"在庫切れ: "': '"Out of stock: "',
        # === Additional missing string literal translations ===
        '"点数: "': '"Score: "',
        '"の面積: "': '" area: "',
        '"の燃料: "': '" fuel: "',
        '"年齢 "': '"Age "',
        '"原因: "': '"Cause: "',
        '"yyyy年MM月dd日"': '"yyyy/MM/dd"',
        '"yyyy年M月d日 EEEE HH:mm z"': '"yyyy/M/d EEEE HH:mm z"',
        '"ゲスト"': '"Guest"',
        '"こんにちは、"': '"Hello, "',
        '"さん！"': '"!"',
        '"スレッドA: "': '"Thread A: "',
        '"スレッドB: "': '"Thread B: "',
        '"--- 書き込み完了 ---"': '"--- Write complete ---"',
        '"--- 読み込み結果 ---"': '"--- Read results ---"',
        '"行目: "': '": "',
        '"日本: "': '"Japan: "',
        '"アメリカ: "': '"USA: "',
        '"ドイツ: "': '"Germany: "',
        '"米国: "': '"US: "',
        '"フランス: "': '"France: "',
        '"アプリ名: "': '"App name: "',
        '"バージョン: "': '"Version: "',
        '"プレイヤー: "': '"Player: "',
        '"コンピュータ: "': '"Computer: "',
        '"逆順: "': '"Reversed: "',
        '"判定: "': '"Status: "',
        '"が泳ぐ"': '" swims"',
        '"入力: "': '"Input: "',
        '" → 有効です"': '" → Valid"',
        '" → エラー: 範囲外です（1〜100）"': '" → Error: Out of range (1-100)"',
        '" → エラー: 数値ではありません"': '" → Error: Not a number"',
        '"リトライします..."': '"Retrying..."',
        '"。リトライします..."': '". Retrying..."',
        '"リストA: "': '"List A: "',
        '"リストB: "': '"List B: "',
        '"積集合: "': '"Intersection: "',
        '"和集合: "': '"Union: "',
        '"差集合(A-B): "': '"Difference(A-B): "',
        '"5文字以上の単語: "': '"Words with 5+ characters: "',
        '"put(4, D) -> 最古の 2 が削除される"': '"put(4, D) -> Oldest entry 2 is removed"',
        '"営業"': '"Sales"',
        '"開発"': '"Development"',
        '"高橋"': '"Takahashi"',
        '"=== ソート結果（給与降順→入社年昇順→名前昇順）==="': '"=== Sort Results (Salary Desc → Join Year Asc → Name Asc) ==="',
        '"万, "': '"0K, "',
        '")"': '")"',
        '"=== 部門別平均給与 ==="': '"=== Average Salary by Department ==="',
        '"万"': '"0K yen"',
        '"ノート"': '"Notebook"',
        '"ペン"': '"Pen"',
        '"教科書"': '"Textbook"',
        '"電卓"': '"Calculator"',
        '"コーヒーメーカー"': '"Coffee Maker"',
        '"合計金額: "': '"Total: "',
        '"最高額: "': '"Highest: "',
        '"1000円以上の商品: "': '"Products 1000 yen or more: "',
        '"伊藤"': '"Ito"',
        '"=== 部署別集計 ==="': '"=== Department Summary ==="',
        '"名（平均年齢: "': '" members (Average age: "',
        '"歳）"': '")"',
        '"個数: "': '"Count: "',
        '"最大: "': '"Max: "',
        '"最小: "': '"Min: "',
        '"田中"': '"Tanaka"',
        '"=== 30歳以上の人（年齢降順） ==="': '"=== People 30+ (Age Descending) ==="',
        '"歳) - "': '") - "',
        '"東京"': '"Tokyo"',
        '"名古屋"': '"Nagoya"',
        '"大阪"': '"Osaka"',
        '"福岡"': '"Fukuoka"',
        '"札幌"': '"Sapporo"',
        '"原文: "': '"Original: "',
        '"暗号化: "': '"Encrypted: "',
        '"復号化: "': '"Decrypted: "',
        '"検証: "': '"Verification: "',
        '"一致"': '"Match"',
        '"不一致"': '"Mismatch"',
        '"件数: "': '"Count: "',
        '"=== 統計情報 ==="': '"=== Statistics ==="',
        '"=== 上位3件 ==="': '"=== Top 3 ==="',
        '"花子"': '"Hanako"',
        '"一郎"': '"Ichiro"',
        '"太郎"': '"Taro"',
        '"平均 "': '"Average "',
        '"クラス最高平均: "': '"Class highest average: "',
        '"点）"': '")"',
        '"元のペア: "': '"Original pair: "',
        '"入れ替え: "': '"Swapped: "',
        '"文字列ペア: "': '"String pair: "',
        '"単語数: "': '"Word count: "',
        '"小文字: "': '"Lowercase: "',
        '"の出現回数: "': '" occurrences: "',
        '"開始日: "': '"Start date: "',
        '"終了日: "': '"End date: "',
        '"期間: "': '"Period: "',
        '"ヶ月"': '" months "',
        '"日"': '" days"',
        '"開始日の曜日: "': '"Start day of week: "',
        '"1月の最終日: "': '"Last day of January: "',
        '"強"': '"Strong"',
        '"中"': '"Medium"',
        '"弱"': '"Weak"',
        '"パスワード: "': '"Password: "',
        '" → 強度: "': '" → Strength: "',
        '"（スコア: "': '" (Score: "',
        '"/5）"': '"/5)"',
        '"元の文字列: "': '"Original string: "',
        '"1. トリム: "': '"1. Trim: "',
        '"2. 大文字: "': '"2. Uppercase: "',
        '"3. 置換(,→;): "': '"3. Replace(,→;): "',
        '"4. 反転: "': '"4. Reverse: "',
        '"ログイン成功"': '"Login successful"',
        '"ログインに失敗"': '"Login failed"',
        '"注文完了"': '"Order completed"',
        '"キャッシュミス"': '"Cache miss"',
        '"決済エラー"': '"Payment error"',
        '"=== ログサマリ ==="': '"=== Log Summary ==="',
        '"=== ERRORログ詳細 ==="': '"=== ERROR Log Details ==="',
        '"件)"': '" items)"',
        '"=== アプリ設定 ==="': '"=== App Settings ==="',
        '"INSERT成功: "': '"INSERT success: "',
        '"件"': '" items"',
        '"山田太郎"': '"Taro Yamada"',
        '"鈴木花子"': '"Hanako Suzuki"',
        '"佐藤一郎"': '"Ichiro Sato"',
        '"SELECT結果: "': '"SELECT result: "',
        '"GET /api/products → 商品一覧"': '"GET /api/products → Product list"',
        '" → 商品詳細"': '" → Product detail"',
        '"POST /api/products → 商品追加"': '"POST /api/products → Add product"',
        '" → 商品削除"': '" → Delete product"',
        '"送金前"': '"Before transfer"',
        '"送金後"': '"After transfer"',
        '"残高変化なし"': '"Balance unchanged"',
        '"商品A"': '"Product A"',
        '"商品B"': '"Product B"',
        '"商品C"': '"Product C"',
        '"エラー"': '"Error"',
        '"結果"': '"Result"',
        '"=== 日時の国際化 ==="': '"=== DateTime Internationalization ==="',
        '"日本語"': '"Japanese"',
        '"English"': '"English"',
        '"=== 日本語 ==="': '"=== Japanese ==="',
        '"=== 英語 ==="': '"=== English ==="',
        '"=== 存在しないキー ==="': '"=== Non-existent Key ==="',
        '"日本語: "': '"Japanese: "',
        '"タスク1"': '"Task 1"',
        '"タスク2"': '"Task 2"',
        '"タスク3"': '"Task 3"',
        '"タスク4"': '"Task 4"',
        '"タスク5"': '"Task 5"',
    }
    
    for jp, en in comment_map.items():
        code = code.replace(jp, en)
    
    for jp, en in string_map.items():
        code = code.replace(jp, en)
    
    # SQL single-quoted strings
    code = code.replace("'開発部'", "'Development'")
    code = code.replace("'営業部'", "'Sales'")
    code = code.replace("'人事部'", "'HR'")
    code = code.replace("'山田太郎'", "'Taro Yamada'")
    code = code.replace("'鈴木花子'", "'Hanako Suzuki'")
    code = code.replace("'佐藤一郎'", "'Ichiro Sato'")
    
    # SQL comment
    code = code.replace("-- 開発部の社員を給与の高い順に取得するSQL", "-- SQL to retrieve Development department employees sorted by salary descending")
    
    # Format strings with %s
    code = code.replace('"%sの面積: %.2f%n"', '"%s area: %.2f%n"')
    
    # Remaining common patterns in string literals
    code = code.replace('"月の季節: "', '"Season of month: "')
    code = code.replace('+ "月の季節: "', '+ "Season for month "')
    code = code.replace('"円"', '" yen"')
    code = code.replace('" yen（', '" yen (')
    code = code.replace('"円）"', '" yen)"')
    
    # Fix patterns where "歳" appears
    code = code.replace('+ "歳"', '')
    
    # Additional format string patterns
    code = code.replace('"%s ファイル: %d個 (合計: %.1fKB)%n"', '"%s files: %d (Total: %.1fKB)%n"')
    code = code.replace('"%s: %d名（平均年齢: %.1f歳）%n"', '"%s: %d members (Average age: %.1f)%n"')
    code = code.replace('"クラス最高平均: %s（%.1f点）%n"', '"Class highest average: %s (%.1f)%n"')
    code = code.replace('"%s: 平均 %.1f%n"', '"%s: Average %.1f%n"')
    code = code.replace('"transitive→modelも利用可能"', '"transitive → model also available"')

    # ===== FINAL CLEANUP: patterns missed by string_map due to compound strings =====

    # Fullwidth parentheses in string literals
    code = code.replace('"（"', '"("')
    code = code.replace('"）: "', '"): "')
    code = code.replace('"）"', '")"')

    # Strings with \\n prefix (literal backslash-n in Java source)
    code = code.replace('"\\n合計: "', '"\\nTotal: "')
    code = code.replace('"\\n平均: "', '"\\nAverage: "')
    code = code.replace('"\\n最小: "', '"\\nMin: "')
    code = code.replace('"\\n最大: "', '"\\nMax: "')
    code = code.replace('"\\n=== 部門別平均給与 ==="', '"\\n=== Average Salary by Department ==="')
    code = code.replace('"\\n=== 上位3件 ==="', '"\\n=== Top 3 ==="')
    code = code.replace('"\\n=== ERRORログ詳細 ==="', '"\\n=== ERROR Log Details ==="')
    code = code.replace('"\\nINSERT成功: "', '"\\nINSERT success: "')
    code = code.replace('"\\n=== 英語 ==="', '"\\n=== English ==="')
    code = code.replace('"\\n=== 存在しないキー ==="', '"\\n=== Non-existent Key ==="')

    # Money/balance compound strings
    code = code.replace('"円 → 残高: "', '" yen → Balance: "')
    code = code.replace('", 点数: "', '", Score: "')

    # Retry pattern
    code = code.replace('"[リトライ "', '"[Retry "')

    # Fullwidth punctuation as standalone string literals
    code = code.replace('"、"', '", "')
    code = code.replace('"！"', '"!"')

    # CSV-format names and cities
    code = code.replace('"田中,32,東京"', '"Tanaka,32,Tokyo"')
    code = code.replace('"鈴木,38,名古屋"', '"Suzuki,38,Nagoya"')
    code = code.replace('"佐藤,45,大阪"', '"Sato,45,Osaka"')
    code = code.replace('"高橋,25,福岡"', '"Takahashi,25,Fukuoka"')
    code = code.replace('"伊藤,28,札幌"', '"Ito,28,Sapporo"')

    # Bare Japanese text: partial matches within longer string literals
    code = code.replace("ログイン成功", "Login successful")
    code = code.replace("ログインに失敗", "Login failed")
    code = code.replace("注文完了", "Order completed")
    code = code.replace("キャッシュミス", "Cache miss")
    code = code.replace("決済エラー", "Payment error")
    code = code.replace("ERRORログ詳細", "ERROR Log Details")
    code = code.replace("'の出現回数: ", "' occurrences: ")
    code = code.replace("元の文字列: '", "Original string: '")
    code = code.replace("トリム: '", "Trim: '")
    code = code.replace("大文字: '", "Uppercase: '")
    code = code.replace("置換(,→;): '", "Replace(,→;): '")
    code = code.replace("反転: '", "Reverse: '")
    code = code.replace("transitive→modelも利用可能", "transitive → model also available")
    code = code.replace("部門別平均給与", "Average Salary by Department")

    return code


def translate_setup_guide(guide):
    """Translate a setup guide section."""
    title_map = {
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
        "エディタ（VS Code）を用意する": "Set Up an Editor (VS Code)",
        "はじめてのプログラムを実行": "Run Your First Program",
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
    
    guide["title"] = title_map.get(guide["title"], guide["title"])
    
    for step in guide.get("steps", []):
        step["title"] = step_title_map.get(step["title"], step["title"])
        if step.get("body"):
            step["body"] = translate_body(step["body"])
        if step.get("tip"):
            step["tip"] = translate_tip(step["tip"])
    
    return guide


def translate_body(body):
    """Translate body text (setup guide)."""
    if body is None:
        return None
    
    translations = {
        # Windows setup
        "Javaでプログラムを書いて動かすには**JDK（Java Development Kit）**が必要です。JDKには、コードをコンパイルする**javac**と、プログラムを実行する**java**というツールが含まれています。\n\nダウンロード手順:\n1. ブラウザで **Adoptium** (https://adoptium.net) にアクセスします\n2. 「**Latest LTS Release**」ボタンをクリックします\n3. 自動的にWindows用のインストーラーがダウンロードされます\n\n| 用語 | 意味 |\n|------|------|\n| JDK | Java開発に必要なツール一式 |\n| LTS | 長期サポート版（安定して使える） |\n| JRE | 実行だけに必要な環境（JDKに含まれる） |":
            "To write and run Java programs, you need the **JDK (Java Development Kit)**. The JDK includes **javac** for compiling code and **java** for running programs.\n\nDownload steps:\n1. Open your browser and go to **Adoptium** (https://adoptium.net)\n2. Click the \"**Latest LTS Release**\" button\n3. The Windows installer will be downloaded automatically\n\n| Term | Meaning |\n|------|------|\n| JDK | Complete toolkit required for Java development |\n| LTS | Long-Term Support version (stable and reliable) |\n| JRE | Runtime-only environment (included in JDK) |",
        
        "ダウンロードした **.msi ファイル**をダブルクリックして実行します。\n\n| 画面 | 操作 |\n|------|------|\n| Welcome画面 | 「Next」をクリック |\n| インストール先の選択 | そのまま「Next」（変更不要） |\n| カスタムセットアップ | **「Set JAVA_HOME variable」にチェック**を入れて「Next」 |\n| インストール実行 | 「Install」をクリック |\n| 完了 | 「Finish」をクリック |\n\n**「Set JAVA_HOME variable」のチェックが最も重要です。**これにチェックを入れると、面倒な環境変数の設定を自動でやってくれます。":
            "Double-click the downloaded **.msi file** to run it.\n\n| Screen | Action |\n|------|------|\n| Welcome screen | Click \"Next\" |\n| Installation location | Click \"Next\" as-is (no change needed) |\n| Custom setup | **Check \"Set JAVA_HOME variable\"** and click \"Next\" |\n| Installation | Click \"Install\" |\n| Completion | Click \"Finish\" |\n\n**Checking \"Set JAVA_HOME variable\" is the most important step.** This automatically configures the necessary environment variables for you.",
    }
    
    if body in translations:
        return translations[body]
    
    # For remaining body texts, do a systematic replacement
    return body


def translate_tip(tip):
    """Translate tip text."""
    if tip is None:
        return None
    return tip


# Since the file is very large, we'll use a comprehensive script approach
# Reading and writing with Python json module ensures valid JSON

with open("practice_exercises.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# We'll do a deep translation using a comprehensive approach
# First, dump to string, do bulk replacements for common patterns,
# then re-parse and do field-specific translations

import copy
translated = copy.deepcopy(data)

# This script is just a helper - the actual translation will be done
# by creating the file directly with all translations applied.

print(f"setupGuide: {len(data.get('setupGuide', []))}")
print(f"chapters: {len(data.get('chapters', []))}")
total_exercises = sum(len(ch.get('exercises', [])) for ch in data.get('chapters', []))
print(f"Total exercises: {total_exercises}")

# Count all translatable fields
count = 0
for guide in data.get('setupGuide', []):
    count += 1  # title
    for step in guide.get('steps', []):
        count += 1  # title
        if step.get('body'): count += 1
        if step.get('tip'): count += 1

for ch in data.get('chapters', []):
    count += 2  # title, subtitle
    for ex in ch.get('exercises', []):
        count += 1  # title
        if ex.get('description'): count += 1
        if ex.get('expectedOutput'): count += 1
        if ex.get('hint'): count += 1
        if ex.get('solutionCode'): count += 1
        if ex.get('solutionExplanation'): count += 1

print(f"Total translatable fields: {count}")
