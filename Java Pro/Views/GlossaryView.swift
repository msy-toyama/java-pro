//
//  GlossaryView.swift
//  Java Pro
//
//  用語集画面。Java用語の検索・閲覧機能を提供する。
//  カード形式の表示とインクリメンタルサーチでプロ品質のUIを実現。
//

import SwiftUI
import SwiftData

struct GlossaryView: View {
    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    @State private var entries: [GlossaryEntry] = []
    @State private var selectedEntry: GlossaryEntry?
    @State private var searchTask: Task<Void, Never>?
    @State private var appearedEntries: Set<String> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var lang: LanguageManager { LanguageManager.shared }

    private var filteredEntries: [GlossaryEntry] {
        if debouncedSearchText.isEmpty {
            return entries
        }
        return ContentService.shared.searchGlossary(query: debouncedSearchText)
    }

    /// 頭文字でグループ化
    private var groupedEntries: [(String, [GlossaryEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            String(entry.term.prefix(1)).uppercased()
        }
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppLayout.paddingMD) {
                // ヘッダー統計
                glossaryHeader
                    .staggeredAppear(index: 0)

                // 検索バー
                searchBar
                    .staggeredAppear(index: 1)

                // 用語一覧
                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    glossaryList
                }
            }
            .padding(AppLayout.paddingMD)
            .frame(maxWidth: horizontalSizeClass == .regular ? 720 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppColor.background)
        .navigationTitle(lang.l("glossary.nav_title"))
        .sheet(item: $selectedEntry) { entry in
            GlossaryDetailSheet(entry: entry)
        }
        .onAppear {
            entries = ContentService.shared.getAllGlossary()
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .onChange(of: searchText) { _, newValue in
            // 検索のデバウンス: キーストロークごとの重い処理を防止
            searchTask?.cancel()
            if newValue.isEmpty {
                debouncedSearchText = ""
            } else {
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(250))
                    guard !Task.isCancelled else { return }
                    debouncedSearchText = newValue
                }
            }
        }
    }

    // MARK: - ヘッダー

    private var glossaryHeader: some View {
        HStack(spacing: AppLayout.paddingMD) {
            VStack(alignment: .leading, spacing: 4) {
                Text(lang.l("glossary.title"))
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                Text(lang.l("glossary.count", entries.count))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(AppColor.primary.opacity(0.1))
                    .frame(width: 52, height: 52)
                Image(systemName: "character.book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(AppColor.primary)
            }
            .accessibilityHidden(true)
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
    }

    // MARK: - 検索バー

    private var searchBar: some View {
        HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textTertiary)
            TextField(lang.l("glossary.search"), text: $searchText)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.textTertiary)
                }
                .accessibilityLabel(lang.l("glossary.clear_search"))
            }
        }
        .padding(AppLayout.paddingSM + 2)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(AppColor.textTertiary.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - 空の状態

    private var emptyState: some View {
        VStack(spacing: AppLayout.paddingMD) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.textTertiary)
                .symbolEffect(.pulse, options: .repeating)
            Text(lang.l("glossary.no_results", searchText))
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, AppLayout.paddingXL * 2)
        .frame(maxWidth: .infinity)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - 用語一覧

    private var glossaryList: some View {
        LazyVStack(spacing: AppLayout.paddingSM, pinnedViews: [.sectionHeaders]) {
            ForEach(groupedEntries, id: \.0) { initial, terms in
                Section {
                    ForEach(Array(terms.enumerated()), id: \.element.id) { index, entry in
                        glossaryCard(entry)
                            .opacity(appearedEntries.contains(entry.id) ? 1 : 0)
                            .offset(y: appearedEntries.contains(entry.id) ? 0 : (reduceMotion ? 0 : 12))
                            .animation(
                                reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82)
                                .delay(Double(index) * 0.03),
                                value: appearedEntries.contains(entry.id)
                            )
                            .onAppear {
                                appearedEntries.insert(entry.id)
                            }
                    }
                } header: {
                    HStack {
                        Text(initial)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppColor.primary.opacity(0.1), in: Capsule())
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .background(AppColor.background)
                }
            }
        }
    }

    // MARK: - 用語カード

    private func glossaryCard(_ entry: GlossaryEntry) -> some View {
        Button {
            selectedEntry = entry
        } label: {
            HStack(spacing: AppLayout.paddingSM) {
                // 先頭文字アイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.primary.opacity(0.12), AppColor.primary.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Text(String(entry.term.prefix(1)))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.primary)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.term)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(entry.definition)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColor.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(AppLayout.paddingSM + 2)
            .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(lang.l("glossary.entry_accessibility", entry.term, entry.definition))
        .accessibilityHint(lang.l("common.show_detail_hint"))
    }
}

// MARK: - 用語詳細シート

private struct GlossaryDetailSheet: View {
    let entry: GlossaryEntry
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
                    // 用語名
                    Text(entry.term)
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColor.textPrimary)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)

                    // 読み
                    Text(entry.reading)
                        .font(AppFont.callout)
                        .foregroundStyle(AppColor.textTertiary)
                        .opacity(appeared ? 1 : 0)

                    Divider()

                    // 定義
                    Text(entry.definition)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineSpacing(6)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)

                    // 関連レッスン
                    if !entry.relatedLessonIds.isEmpty {
                        relatedLessonsSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 8)
                    }
                }
                .padding(AppLayout.paddingLG)
            }
            .navigationTitle(lang.l("glossary.detail_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.l("glossary.close")) { dismiss() }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
    }

    private var relatedLessonsSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("glossary.related_lessons"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textSecondary)

            ForEach(entry.relatedLessonIds, id: \.self) { lessonId in
                if let lesson = ContentService.shared.getLesson(id: lessonId) {
                    NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(AppColor.primary)
                                .accessibilityHidden(true)
                            Text(lesson.title)
                                .font(AppFont.body)
                                .foregroundStyle(AppColor.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppColor.textTertiary)
                                .accessibilityHidden(true)
                        }
                        .padding(AppLayout.paddingSM)
                        .background(AppColor.primaryLight.opacity(0.08), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                    }
                    .buttonStyle(.pressable(scale: 0.97))
                    .accessibilityLabel(lang.l("glossary.open_lesson", lesson.title))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GlossaryView()
    }
    .modelContainer(PreviewContainer.shared)
}
