//
//  RichBodyView.swift
//  Java Pro
//
//  本文テキストを解析し、通常テキストとMarkdownテーブルを適切にレンダリングするView。
//  LessonDetailViewから抽出。
//

import SwiftUI

/// 本文テキストを解析し、通常テキストとMarkdownテーブルを適切にレンダリングする。
struct RichBodyView: View {
    let text: String

    var body: some View {
        let segments = Self.parseSegments(text)
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                switch segment {
                case .text(let content):
                    Self.styledText(content)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineSpacing(6)
                case .table(let table):
                    MarkdownTableView(table: table)
                case .bulletList(let items):
                    BulletListView(items: items)
                case .numberedList(let items):
                    NumberedListView(items: items)
                }
            }
        }
    }

    // MARK: - インライン強調テキストレンダリング

    /// 用語リンクのURLスキーム。
    static let glossaryScheme = "prpro-glossary"

    /// 用語リンク URL のホスト部分に使用する許可文字セット。
    /// `.urlPathAllowed` だと `/`, `:`, `@` がエンコードされず URL パースが破綻するため、
    /// 英数字とハイフン・アンダースコアのみ許可する安全なセットを使用する。
    private static let glossaryURLAllowed: CharacterSet = {
        var cs = CharacterSet.alphanumerics
        cs.insert(charactersIn: "-_")
        return cs
    }()

    /// `**太字**` と `[[用語]]` マークアップをパースし、
    /// 強調スタイルおよび用語リンク付きの `Text` を生成する。
    /// - `**text**` → 太字 + アクセントカラー
    /// - `[[term]]` → タップ可能な用語リンク（下線 + リンクカラー）
    static func styledText(_ content: String) -> Text {
        let attributed = buildAttributedString(content)
        return Text(attributed)
    }

    /// マークアップ付き文字列を `AttributedString` に変換する。
    private static func buildAttributedString(_ content: String) -> AttributedString {
        var result = AttributedString()
        var buffer = ""
        let chars = Array(content)
        var i = 0

        func flushBuffer() {
            if !buffer.isEmpty {
                result += AttributedString(buffer)
                buffer = ""
            }
        }

        while i < chars.count {
            // **太字** パターンの検出
            if i + 1 < chars.count && chars[i] == "*" && chars[i + 1] == "*" {
                if let endIdx = findClosingMarker(chars, from: i + 2, marker: "**") {
                    flushBuffer()
                    let boldText = String(chars[(i + 2)..<endIdx])
                    var attr = AttributedString(boldText)
                    attr.inlinePresentationIntent = .stronglyEmphasized
                    attr.foregroundColor = AppColor.primary
                    result += attr
                    i = endIdx + 2
                    continue
                }
            }

            // [[用語]] パターンの検出
            if i + 1 < chars.count && chars[i] == "[" && chars[i + 1] == "[" {
                if let endIdx = findClosingMarker(chars, from: i + 2, marker: "]]") {
                    flushBuffer()
                    let term = String(chars[(i + 2)..<endIdx])
                    var attr = AttributedString(term)
                    let encoded = term.addingPercentEncoding(withAllowedCharacters: Self.glossaryURLAllowed) ?? term
                    attr.link = URL(string: "\(glossaryScheme)://\(encoded)")
                    attr.underlineStyle = .single
                    result += attr
                    i = endIdx + 2
                    continue
                }
            }

            buffer.append(chars[i])
            i += 1
        }

        flushBuffer()
        return result
    }

    /// 指定位置以降で閉じマーカーの開始位置を返す（見つからなければ nil）。
    private static func findClosingMarker(_ chars: [Character], from start: Int, marker: String) -> Int? {
        let markerChars = Array(marker)
        guard markerChars.count > 0 else { return nil }
        var j = start
        while j + markerChars.count - 1 < chars.count {
            var matched = true
            for k in 0..<markerChars.count {
                if chars[j + k] != markerChars[k] {
                    matched = false
                    break
                }
            }
            if matched { return j }
            j += 1
        }
        return nil
    }

    enum Segment {
        case text(String)
        case table(ParsedTable)
        case bulletList([String])
        case numberedList([String])
    }

    struct ParsedTable {
        let headers: [String]
        let rows: [[String]]
    }

    /// テキストをテーブル・箇条書き・番号リスト・通常テキストのセグメントに分割する。
    static func parseSegments(_ text: String) -> [Segment] {
        let lines = text.components(separatedBy: "\n")
        var segments: [Segment] = []
        var textBuffer: [String] = []
        var tableBuffer: [String] = []
        var bulletBuffer: [String] = []
        var numberedBuffer: [String] = []
        var inTable = false
        var inBullet = false
        var inNumbered = false

        /// 番号リスト行の判定（"1. テキスト" 形式）
        func isNumberedLine(_ s: String) -> Bool {
            guard let dotIndex = s.firstIndex(of: ".") else { return false }
            let prefix = s[s.startIndex..<dotIndex]
            guard !prefix.isEmpty, prefix.allSatisfy(\.isNumber) else { return false }
            let afterDot = s[s.index(after: dotIndex)...]
            return afterDot.first == " " || afterDot.first == "\u{3000}"
        }

        /// 番号リスト行からテキスト部分を取得
        func numberedContent(_ s: String) -> String {
            guard let dotIndex = s.firstIndex(of: ".") else { return s }
            let afterDot = s[s.index(after: dotIndex)...]
            return String(afterDot).trimmingCharacters(in: .whitespaces)
        }

        /// 番号リストの継続行（字下げされた補足行）判定
        func isNumberedContinuation(_ s: String, original: String, lineIndex: Int) -> Bool {
            guard inNumbered else { return false }
            // 空行でない、テーブルでない、箇条書きでない、番号行でない、
            // かつ先頭がスペースで始まるか「→」「○」「×」で始まる場合は継続行
            let trimmed = s.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { return false }
            if trimmed.hasPrefix("|") { return false }
            if trimmed.hasPrefix("\u{30FB}") || trimmed.hasPrefix("\u{2022}") { return false }
            if isNumberedLine(trimmed) { return false }
            // 元の行が先頭スペースを持つ（字下げ）場合は継続行
            let leadingSpaces = original.prefix(while: { $0 == " " || $0 == "\u{3000}" })
            if leadingSpaces.count >= 2 || trimmed.hasPrefix("→") || trimmed.hasPrefix("○") || trimmed.hasPrefix("×") {
                return true
            }
            // 字下げなしでも、後続に番号行がある場合は継続行として扱う
            return hasUpcomingNumberedLine(after: lineIndex)
        }

        func flushText() {
            let joined = textBuffer.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !joined.isEmpty {
                segments.append(.text(joined))
            }
            textBuffer.removeAll()
        }

        func flushTable() {
            if let table = parseTable(tableBuffer) {
                segments.append(.table(table))
            }
            tableBuffer.removeAll()
        }

        func flushBullet() {
            if !bulletBuffer.isEmpty {
                segments.append(.bulletList(bulletBuffer))
            }
            bulletBuffer.removeAll()
        }

        func flushNumbered() {
            if !numberedBuffer.isEmpty {
                segments.append(.numberedList(numberedBuffer))
            }
            numberedBuffer.removeAll()
        }

        /// 番号リスト中の空行で、後続に番号行が続く場合はリストを分断しない。
        /// 先読みして次の非空行が番号行か継続行かを判定する。
        func nextNonEmptyLineIsNumbered(after idx: Int) -> Bool {
            for j in (idx + 1)..<lines.count {
                let t = lines[j].trimmingCharacters(in: .whitespaces)
                if t.isEmpty { continue }
                return isNumberedLine(t)
            }
            return false
        }

        /// 後続行に番号行が存在するかを先読みする（テキスト・テーブル・空行を跨ぐ）。
        func hasUpcomingNumberedLine(after idx: Int) -> Bool {
            for j in (idx + 1)..<lines.count {
                let t = lines[j].trimmingCharacters(in: .whitespaces)
                if t.isEmpty { continue }
                if isNumberedLine(t) { return true }
                // テーブル行やその他のテキスト行は跨いで探す
                // ただし箇条書き開始は番号リスト外とみなす
                if t.hasPrefix("\u{30FB}") || t.hasPrefix("\u{2022}") { continue }
                if t.hasPrefix("|") { continue }  // テーブル行をスキップ
                continue
            }
            return false
        }

        for (lineIndex, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let isTableLine = trimmed.hasPrefix("|") && trimmed.hasSuffix("|") && trimmed.filter({ $0 == "|" }).count >= 2
            // ・(U+30FB) と •(U+2022) の両方を箇条書きとして認識
            let isBulletLine = trimmed.hasPrefix("\u{30FB}") || trimmed.hasPrefix("\u{2022}")
            let isNumLine = isNumberedLine(trimmed)
            let isContinuation = isNumberedContinuation(trimmed, original: line, lineIndex: lineIndex)

            if isTableLine {
                if inBullet { flushBullet(); inBullet = false }
                if inNumbered { flushNumbered(); inNumbered = false }
                if !inTable {
                    flushText()
                    inTable = true
                }
                tableBuffer.append(trimmed)
            } else if isBulletLine {
                if inTable { flushTable(); inTable = false }
                if inNumbered {
                    // 番号リスト項目の子箇条書き → 直前の項目に結合
                    if !numberedBuffer.isEmpty {
                        let content = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                        numberedBuffer[numberedBuffer.count - 1] += "\n・" + content
                    }
                } else {
                    if !inBullet {
                        flushText()
                        inBullet = true
                    }
                    // 「・」または「•」を除去してテキスト部分のみ格納
                    let content = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                    bulletBuffer.append(content)
                }
            } else if isNumLine {
                if inTable { flushTable(); inTable = false }
                if inBullet { flushBullet(); inBullet = false }
                if !inNumbered {
                    flushText()
                    inNumbered = true
                }
                numberedBuffer.append(numberedContent(trimmed))
            } else if isContinuation {
                // 番号リスト内の継続行（字下げ補足）→ 直前の項目に結合
                if !numberedBuffer.isEmpty {
                    numberedBuffer[numberedBuffer.count - 1] += "\n" + trimmed
                }
            } else if trimmed.isEmpty && inNumbered && nextNonEmptyLineIsNumbered(after: lineIndex) {
                // 番号リスト中の空行だが後続に番号行がある → リストを分断しない
                continue
            } else {
                if inTable { flushTable(); inTable = false }
                if inBullet { flushBullet(); inBullet = false }
                if inNumbered { flushNumbered(); inNumbered = false }
                textBuffer.append(line)
            }
        }

        if inTable { flushTable() }
        else if inBullet { flushBullet() }
        else if inNumbered { flushNumbered() }
        else { flushText() }

        return segments
    }

    /// テーブル行群を解析してParsedTableを生成する。
    private static func parseTable(_ lines: [String]) -> ParsedTable? {
        let dataLines = lines.filter { line in
            let cells = parseCells(line)
            // セパレータ行（---のみ）を除外
            return !cells.allSatisfy { $0.trimmingCharacters(in: .whitespaces).allSatisfy { c in c == "-" || c == ":" } }
        }
        guard dataLines.count >= 2 else {
            // 2行未満なら1行目をヘッダ、残りをデータ行とする
            if let first = dataLines.first {
                return ParsedTable(headers: parseCells(first), rows: [])
            }
            return nil
        }
        let headers = parseCells(dataLines[0])
        let rows = dataLines.dropFirst().map { parseCells($0) }
        return ParsedTable(headers: headers, rows: rows)
    }

    /// パイプ区切りの1行をセル配列に分割する（`\|` はエスケープとして保護）。
    private static func parseCells(_ line: String) -> [String] {
        // エスケープされたパイプをプレースホルダに退避
        let placeholder = "\u{FFFC}"
        let escaped = line.replacingOccurrences(of: "\\|", with: placeholder)
        var result = escaped.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.replacingOccurrences(of: placeholder, with: "|")
                      .trimmingCharacters(in: .whitespaces) }
        // 先頭・末尾の空要素を除去
        if result.first?.isEmpty == true { result.removeFirst() }
        if result.last?.isEmpty == true { result.removeLast() }
        return result
    }
}

/// 「・」箇条書きをスタイリッシュなリストとして描画するView。
struct BulletListView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(AppColor.primary.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    RichBodyView.styledText(item)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.leading, 4)
    }
}

/// 番号付きリスト（1. 2. 3.）をスタイリッシュに描画するView。
struct NumberedListView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let lines = item.components(separatedBy: "\n")
                let mainText = lines.first ?? item
                let subLines = lines.dropFirst()

                HStack(alignment: .top, spacing: 10) {
                    // 番号バッジ
                    Text("\(index + 1)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(AppColor.primary.opacity(0.75), in: Circle())
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 3) {
                        RichBodyView.styledText(mainText)
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        // 継続行（字下げ補足）の表示
                        ForEach(Array(subLines.enumerated()), id: \.offset) { _, subLine in
                            RichBodyView.styledText(subLine)
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 2)
                        }
                    }
                }
            }
        }
        .padding(.leading, 4)
    }
}

/// Markdownテーブルをネイティブなカード形式で美しく描画するView。
struct MarkdownTableView: View {
    let table: RichBodyView.ParsedTable

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダー行
            HStack(spacing: 0) {
                ForEach(Array(table.headers.enumerated()), id: \.offset) { colIndex, header in
                    cellView(text: header, isHeader: true, colIndex: colIndex)
                    if colIndex < table.headers.count - 1 {
                        Divider()
                            .frame(height: 36)
                            .overlay(AppColor.textTertiary.opacity(0.15))
                    }
                }
            }
            .background(AppColor.primary.opacity(0.08))

            Divider().overlay(AppColor.primary.opacity(0.3))

            // データ行
            ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                let clippedRow = Array(row.prefix(table.headers.count))
                HStack(spacing: 0) {
                    ForEach(Array(clippedRow.enumerated()), id: \.offset) { colIndex, cell in
                        cellView(text: cell, isHeader: false, colIndex: colIndex)
                        if colIndex < clippedRow.count - 1 {
                            Divider()
                                .frame(height: 32)
                                .overlay(AppColor.textTertiary.opacity(0.1))
                        }
                    }
                }
                .background(rowIndex % 2 == 0 ? Color.clear : AppColor.textTertiary.opacity(0.04))

                if rowIndex < table.rows.count - 1 {
                    Divider().overlay(AppColor.textTertiary.opacity(0.1))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                .stroke(AppColor.textTertiary.opacity(0.15), lineWidth: 1)
        )
    }

    private func cellView(text: String, isHeader: Bool, colIndex: Int) -> some View {
        let displayText = text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "`", with: "")
        let isFirstCol = colIndex == 0

        return Text(displayText)
            .font(isHeader ? .system(size: 12, weight: .bold) : .system(size: 12, weight: isFirstCol ? .semibold : .regular))
            .foregroundStyle(isHeader ? AppColor.primary : (isFirstCol ? AppColor.textPrimary : AppColor.textSecondary))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, isHeader ? 10 : 8)
    }
}
