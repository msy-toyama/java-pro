//
//  JavaSyntaxHighlighter.swift
//  Java Pro
//
//  Java コードにシンタックスハイライト（構文色分け）を適用する。
//  VS Code Dark+ テーマに準拠した配色を使用し、
//  コメント・文字列・キーワード・型・数値・アノテーションを色分けする。
//  AttributedString を返し、SwiftUI の Text で直接使用できる。
//

import SwiftUI
import UIKit

// MARK: - シンタックスハイライター

/// Java コードの構文色分けを行うユーティリティ。
/// VS Code Dark+ テーマに準拠した配色で、コメント・文字列・キーワード・
/// 型名・数値・アノテーションを自動検出して色分けする。
enum JavaSyntaxHighlighter {

    // MARK: - Colors (VS Code Dark+ theme)

    /// デフォルトのテキスト色
    static let defaultColor  = UIColor(red: 0.831, green: 0.831, blue: 0.831, alpha: 1) // #D4D4D4
    /// キーワード（public, class, if, for 等）
    static let keywordColor  = UIColor(red: 0.337, green: 0.612, blue: 0.839, alpha: 1) // #569CD6
    /// 文字列リテラル（"..." / '...'）
    static let stringColor   = UIColor(red: 0.808, green: 0.569, blue: 0.471, alpha: 1) // #CE9178
    /// コメント（// ... / /* ... */）
    static let commentColor  = UIColor(red: 0.416, green: 0.600, blue: 0.333, alpha: 1) // #6A9955
    /// 型名（String, List, Optional 等）
    static let typeColor     = UIColor(red: 0.306, green: 0.788, blue: 0.690, alpha: 1) // #4EC9B0
    /// 数値リテラル（42, 3.14, 100L 等）
    static let numberColor   = UIColor(red: 0.710, green: 0.808, blue: 0.659, alpha: 1) // #B5CEA8
    /// アノテーション（@Override, @Test 等）
    static let annotationColor = UIColor(red: 0.863, green: 0.863, blue: 0.667, alpha: 1) // #DCDCAA

    // MARK: - Keyword / Type Sets

    /// Java 予約語
    private static let keywords: Set<String> = [
        "abstract", "assert", "boolean", "break", "byte", "case", "catch",
        "char", "class", "const", "continue", "default", "do", "double",
        "else", "enum", "extends", "final", "finally", "float", "for",
        "goto", "if", "implements", "import", "instanceof", "int",
        "interface", "long", "native", "new", "package", "private",
        "protected", "public", "return", "short", "static", "strictfp",
        "super", "switch", "synchronized", "this", "throw", "throws",
        "transient", "try", "var", "void", "volatile", "while",
        "true", "false", "null", "record", "sealed", "permits", "yield",
        "module", "requires", "exports", "opens", "uses", "provides",
        "with", "to", "open", "transitive"
    ]

    /// 頻出 Java 型名
    private static let types: Set<String> = [
        "String", "Integer", "Long", "Double", "Float", "Character",
        "Boolean", "Byte", "Short", "Object", "Number", "Math", "System",
        "Thread", "Runnable", "Comparable", "Iterable", "Iterator",
        "Collection", "List", "ArrayList", "LinkedList",
        "Map", "HashMap", "TreeMap", "LinkedHashMap", "ConcurrentHashMap",
        "Set", "HashSet", "TreeSet", "LinkedHashSet",
        "Queue", "Deque", "Stack", "PriorityQueue", "ArrayDeque",
        "Optional", "Stream", "Collectors", "Arrays", "Collections",
        "StringBuilder", "StringBuffer", "StringJoiner",
        "Exception", "RuntimeException", "Error",
        "IOException", "SQLException", "NullPointerException",
        "IllegalArgumentException", "IndexOutOfBoundsException",
        "ClassNotFoundException", "FileNotFoundException",
        "ArithmeticException", "ClassCastException",
        "UnsupportedOperationException", "ConcurrentModificationException",
        "NoSuchElementException", "IllegalStateException",
        "Scanner", "BufferedReader", "BufferedWriter", "PrintWriter",
        "InputStreamReader", "OutputStreamWriter",
        "FileReader", "FileWriter", "FileInputStream", "FileOutputStream",
        "File", "Path", "Paths", "Files",
        "LocalDate", "LocalTime", "LocalDateTime", "ZonedDateTime",
        "DateTimeFormatter", "Duration", "Period", "Instant",
        "Locale", "ResourceBundle", "MessageFormat", "NumberFormat",
        "DateTimeParseException",
        "CompletableFuture", "Future", "Callable",
        "ExecutorService", "Executors", "ThreadPoolExecutor",
        "AtomicInteger", "AtomicLong", "AtomicReference",
        "ReentrantLock", "Semaphore", "CountDownLatch", "CyclicBarrier",
        "Connection", "Statement", "PreparedStatement", "ResultSet",
        "DriverManager", "DataSource",
        "Consumer", "Supplier", "Function", "Predicate",
        "BiFunction", "BiConsumer", "BiPredicate",
        "UnaryOperator", "BinaryOperator",
        "Comparator", "Serializable", "Cloneable", "AutoCloseable",
        "Closeable", "Readable", "Appendable", "CharSequence",
        "Void", "Class", "Enum", "Record", "Annotation",
        "Override", "Deprecated", "SuppressWarnings", "FunctionalInterface"
    ]

    // MARK: - Pre-compiled Regex

    /// 複数行コメント: /* ... */
    private static let multiLineCommentRegex = try! NSRegularExpression(
        pattern: "/\\*[\\s\\S]*?\\*/",
        options: .dotMatchesLineSeparators
    )
    /// 単一行コメント: // ...
    private static let singleLineCommentRegex = try! NSRegularExpression(
        pattern: "//[^\n]*"
    )
    /// ダブルクォート文字列: "..."
    private static let doubleQuoteStringRegex = try! NSRegularExpression(
        pattern: "\"(?:[^\"\\\\]|\\\\.)*\""
    )
    /// シングルクォート文字: '...'
    private static let singleQuoteCharRegex = try! NSRegularExpression(
        pattern: "'(?:[^'\\\\]|\\\\.)*'"
    )
    /// アノテーション: @Word
    private static let annotationRegex = try! NSRegularExpression(
        pattern: "@[A-Za-z_]\\w*"
    )
    /// 数値リテラル: 42, 3.14, 100L, 0xFF 等
    private static let numberRegex = try! NSRegularExpression(
        pattern: "\\b(?:0[xX][0-9a-fA-F]+|\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?)[LlFfDd]?\\b"
    )
    /// キーワード（動的生成・キャッシュ）
    private static let keywordRegex: NSRegularExpression = {
        let pattern = "\\b(" + keywords.sorted().joined(separator: "|") + ")\\b"
        return try! NSRegularExpression(pattern: pattern)
    }()
    /// 型名（動的生成・キャッシュ）
    private static let typeRegex: NSRegularExpression = {
        let pattern = "\\b(" + types.sorted().joined(separator: "|") + ")\\b"
        return try! NSRegularExpression(pattern: pattern)
    }()

    // MARK: - Highlight

    /// Java コードにシンタックスハイライトを適用し、AttributedString を返す。
    /// - Parameter code: Java ソースコード文字列
    /// - Returns: 色分けされた AttributedString（SwiftUI Text で直接使用可能）
    static func highlight(_ code: String) -> AttributedString {
        let nsString = code as NSString
        let fullRange = NSRange(location: 0, length: nsString.length)

        // NSMutableAttributedString で色を設定し、最後に AttributedString へ変換
        let attrStr = NSMutableAttributedString(string: code)
        attrStr.addAttribute(.foregroundColor, value: defaultColor, range: fullRange)

        // 占有済みレンジ（先にマッチした領域は後のパターンで上書きしない）
        var occupied: [NSRange] = []

        /// 正規表現にマッチした範囲に色を適用する。占有済み範囲とは重複しない。
        func apply(_ regex: NSRegularExpression, color: UIColor) {
            let matches = regex.matches(in: code, range: fullRange)
            for match in matches {
                let range = match.range
                guard range.location != NSNotFound else { continue }
                // 占有済み範囲との重複チェック
                let overlaps = occupied.contains { NSIntersectionRange($0, range).length > 0 }
                guard !overlaps else { continue }
                attrStr.addAttribute(.foregroundColor, value: color, range: range)
                occupied.append(range)
            }
        }

        // 優先度順に適用（コメント→文字列→アノテーション→キーワード→型→数値）
        apply(multiLineCommentRegex, color: commentColor)
        apply(singleLineCommentRegex, color: commentColor)
        apply(doubleQuoteStringRegex, color: stringColor)
        apply(singleQuoteCharRegex, color: stringColor)
        apply(annotationRegex, color: annotationColor)
        apply(keywordRegex, color: keywordColor)
        apply(typeRegex, color: typeColor)
        apply(numberRegex, color: numberColor)

        return AttributedString(attrStr)
    }

    /// コードがJavaらしい内容かどうかを簡易判定する。
    /// シェルコマンド等の場合はハイライトを控えめにするために使用。
    static func looksLikeJava(_ code: String) -> Bool {
        let javaIndicators = ["class ", "public ", "private ", "System.", "import ", "void ", "String ", "int "]
        return javaIndicators.contains { code.contains($0) }
    }
}
