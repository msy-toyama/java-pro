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
                }
            }
        }
    }

    // MARK: - インライン強調テキストレンダリング

    /// `**太字**` マークアップをパースし、強調スタイル付きのTextを生成する。
    static func styledText(_ content: String) -> Text {
        let pattern = /\*\*(.+?)\*\*/
        var result = Text("")
        var remaining = content[...]

        while let match = remaining.firstMatch(of: pattern) {
            // マッチ前の通常テキスト
            let before = remaining[remaining.startIndex..<match.range.lowerBound]
            if !before.isEmpty {
                result = result + Text(String(before))
            }
            // 強調テキスト（太字 + アクセントカラー）
            let emphasized = String(match.output.1)
            result = result + Text(emphasized)
                .bold()
                .foregroundColor(AppColor.primary)
            remaining = remaining[match.range.upperBound...]
        }
        // 残りの通常テキスト
        if !remaining.isEmpty {
            result = result + Text(String(remaining))
        }
        return result
    }

    enum Segment {
        case text(String)
        case table(ParsedTable)
        case bulletList([String])
    }

    struct ParsedTable {
        let headers: [String]
        let rows: [[String]]
    }

    /// テキストをテーブル・箇条書き・通常テキストのセグメントに分割する。
    static func parseSegments(_ text: String) -> [Segment] {
        let lines = text.components(separatedBy: "\n")
        var segments: [Segment] = []
        var textBuffer: [String] = []
        var tableBuffer: [String] = []
        var bulletBuffer: [String] = []
        var inTable = false
        var inBullet = false

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

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let isTableLine = trimmed.hasPrefix("|") && trimmed.hasSuffix("|") && trimmed.filter({ $0 == "|" }).count >= 2
            let isBulletLine = trimmed.hasPrefix("\u{30FB}") // ・

            if isTableLine {
                if inBullet { flushBullet(); inBullet = false }
                if !inTable {
                    flushText()
                    inTable = true
                }
                tableBuffer.append(trimmed)
            } else if isBulletLine {
                if inTable { flushTable(); inTable = false }
                if !inBullet {
                    flushText()
                    inBullet = true
                }
                // 「・」を除去してテキスト部分のみ格納
                let content = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                bulletBuffer.append(content)
            } else {
                if inTable { flushTable(); inTable = false }
                if inBullet { flushBullet(); inBullet = false }
                textBuffer.append(line)
            }
        }

        if inTable { flushTable() }
        else if inBullet { flushBullet() }
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
