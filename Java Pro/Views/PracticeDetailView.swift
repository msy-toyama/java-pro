//
//  PracticeDetailView.swift
//  Java Pro
//
//  実践演習の詳細表示画面。
//  チャプター内の演習問題を一覧し、各問題の説明・期待出力・ヒント・
//  解答コード・.javaダウンロードを提供する。
//

import SwiftUI

struct PracticeDetailView: View {
    let chapter: PracticeChapter
    @State private var expandedExercise: String?
    @State private var showSolutionFor: String?
    @State private var generatedFileURLs: [String: URL?] = [:]
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppLayout.paddingMD) {
                chapterHeader

                ForEach(chapter.exercises) { exercise in
                    exerciseCard(exercise)
                }
            }
            .padding(AppLayout.paddingMD)
        }
        .background(AppColor.background)
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Chapter Header

    private var chapterHeader: some View {
        VStack(spacing: AppLayout.paddingSM) {
            Text(chapter.subtitle)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
            HStack(spacing: AppLayout.paddingMD) {
                statBadge(icon: "doc.text", label: lang.l("common.quiz_count", chapter.exercises.count))
                statBadge(icon: "chart.bar.fill", label: levelLabel)
            }
        }
        .padding(AppLayout.paddingMD)
        .frame(maxWidth: .infinity)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var levelLabel: String {
        switch chapter.certificationLevel {
        case .beginner: lang.l("practice_detail.free")
        case .silver: "Silver"
        case .gold: "Gold"
        }
    }

    private func statBadge(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(AppColor.primary)
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.horizontal, AppLayout.paddingSM)
        .padding(.vertical, 4)
        .background(AppColor.primary.opacity(0.08))
        .clipShape(Capsule())
    }

    // MARK: - Exercise Card

    private func exerciseCard(_ exercise: PracticeExercise) -> some View {
        let isExpanded = expandedExercise == exercise.id

        return VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        showSolutionFor = nil
                    }
                    expandedExercise = isExpanded ? nil : exercise.id
                }
            } label: {
                HStack(spacing: AppLayout.paddingSM) {
                    difficultyIcon(exercise.difficulty)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.title)
                            .font(AppFont.headline)
                            .foregroundStyle(AppColor.textPrimary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColor.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(AppLayout.paddingMD)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(exercise.title)、\(difficultyLabel(exercise.difficulty))")
            .accessibilityHint(isExpanded ? lang.l("practice_detail.accessibility_close") : lang.l("practice_detail.accessibility_open"))

            // Expanded Content
            if isExpanded {
                Divider()
                    .padding(.horizontal, AppLayout.paddingMD)

                VStack(alignment: .leading, spacing: AppLayout.paddingMD) {
                    // 問題文
                    sectionLabel(lang.l("practice_detail.problem"), icon: "doc.text.fill", color: AppColor.primary)
                    RichBodyView(text: exercise.description)

                    // 期待出力（プログラムの出力結果なのでハイライト不要）
                    sectionLabel(lang.l("practice_detail.expected_output"), icon: "terminal.fill", color: AppColor.terminalGreen)
                    codeBlock(exercise.expectedOutput, background: AppColor.codeBackground, applyHighlight: false)

                    // ヒント
                    if let hint = exercise.hint, !hint.isEmpty {
                        hintSection(hint)
                    }

                    // 解答表示
                    solutionSection(exercise)
                }
                .padding(AppLayout.paddingMD)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Components

    private func difficultyLabel(_ level: Int) -> String {
        switch level {
        case 1: lang.l("practice.difficulty.beginner")
        case 2: lang.l("practice.difficulty.intermediate")
        default: lang.l("practice.difficulty.advanced")
        }
    }

    private func difficultyIcon(_ level: Int) -> some View {
        let color: Color = switch level {
        case 1: AppColor.success
        case 2: AppColor.primary
        default: AppColor.error
        }
        let label = switch level {
        case 1: lang.l("practice.difficulty.beginner")
        case 2: lang.l("practice.difficulty.intermediate")
        default: lang.l("practice.difficulty.advanced")
        }

        return VStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(width: 36, height: 36)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
    }

    private func sectionLabel(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(text)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    private func codeBlock(_ code: String, background: Color, applyHighlight: Bool = true) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Group {
                if applyHighlight {
                    Text(JavaSyntaxHighlighter.highlight(code))
                } else {
                    Text(code)
                        .foregroundStyle(AppColor.codeText)
                }
            }
            .font(AppFont.code)
            .textSelection(.enabled)
            .padding(AppLayout.paddingSM)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
    }

    // MARK: - Hint

    private func hintSection(_ hint: String) -> some View {
        DisclosureGroup {
            Text(hint)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(AppColor.accent)
                    .accessibilityHidden(true)
                Text(lang.l("practice_detail.show_hint"))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.accent)
            }
        }
        .tint(AppColor.accent)
    }

    // MARK: - Solution

    private func solutionSection(_ exercise: PracticeExercise) -> some View {
        let showSolution = showSolutionFor == exercise.id

        return VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Button {
                // ファイルURLを事前生成（初回のみ）— アニメーションブロック外で実行
                if !showSolution && !generatedFileURLs.keys.contains(exercise.id) {
                    generatedFileURLs[exercise.id] = PracticeService.shared.generateJavaFileURL(for: exercise)
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSolutionFor = showSolution ? nil : exercise.id
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: showSolution ? "eye.slash.fill" : "eye.fill")
                        .font(.caption)
                    Text(showSolution ? lang.l("practice_detail.hide_solution") : lang.l("practice_detail.show_solution"))
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.primary)
                .padding(.horizontal, AppLayout.paddingSM)
                .padding(.vertical, 6)
                .background(AppColor.primary.opacity(0.1))
                .clipShape(Capsule())
            }
            .accessibilityLabel(showSolution ? lang.l("practice_detail.hide_solution") : lang.l("practice_detail.show_solution_accessibility"))

            if showSolution {
                sectionLabel(lang.l("practice_detail.solution_code"), icon: "chevron.left.forwardslash.chevron.right", color: AppColor.primary)
                codeBlock(exercise.solutionCode, background: AppColor.codeBackground)

                // 解答コードの詳細解説
                if let explanation = exercise.solutionExplanation, !explanation.isEmpty {
                    solutionExplanationView(explanation)
                }

                // .java ダウンロードボタン
                if let fileURL = generatedFileURLs[exercise.id] ?? nil {
                    ShareLink(
                        item: fileURL,
                        subject: Text(exercise.solutionFileName),
                        message: Text(lang.l("practice_detail.share_message", exercise.title))
                    ) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.caption)
                            Text(lang.l("practice_detail.download_file", exercise.solutionFileName))
                                .font(AppFont.caption)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppLayout.paddingMD)
                        .padding(.vertical, AppLayout.paddingSM)
                        .background(AppColor.primary)
                        .clipShape(Capsule())
                    }
                    .accessibilityLabel(lang.l("practice_detail.download_accessibility", exercise.solutionFileName))
                } else if !generatedFileURLs.keys.contains(exercise.id) {
                    // generateがまだ呼ばれていない場合は表示しない
                    EmptyView()
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(AppColor.warning)
                        Text(lang.l("practice_detail.file_error"))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Solution Explanation

    private func solutionExplanationView(_ explanation: String) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.practiceViolet)
                    .accessibilityHidden(true)
                Text(lang.l("practice_detail.solution_explanation"))
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.practiceViolet)
            }

            // 解説テキストを行ごとに処理（■見出し行をボールド表示、【】ヘッダー行は除外）
            let lines = explanation.components(separatedBy: "\n")
                .filter { !$0.hasPrefix("【") }
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                if line.hasPrefix("■") {
                    Text(line)
                        .font(AppFont.callout)
                        .foregroundStyle(AppColor.textPrimary)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                } else if !line.isEmpty {
                    Text(line)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.practiceViolet.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }
}

#Preview {
    NavigationStack {
        PracticeDetailView(
            chapter: PracticeChapter(
                id: "ch02",
                title: "出力・変数",
                subtitle: "データ型と変数宣言を実践しよう",
                certificationLevel: .beginner,
                category: "basics",
                exercises: [
                    PracticeExercise(
                        id: "prac_ch02_01",
                        title: "自己紹介を出力しよう",
                        difficulty: 1,
                        relatedLessonId: "ch02_01",
                        description: "自分の名前と年齢を変数に格納し、出力するプログラムを作成してください。",
                        expectedOutput: "名前: 太郎\n年齢: 20歳",
                        hint: "String型の変数とint型の変数を宣言し、System.out.printlnで出力します。",
                        solutionCode: "public class SelfIntroduction {\n    public static void main(String[] args) {\n        String name = \"太郎\";\n        int age = 20;\n        System.out.println(\"名前: \" + name);\n        System.out.println(\"年齢: \" + age + \"歳\");\n    }\n}",
                        solutionFileName: "SelfIntroduction.java",
                        solutionExplanation: "■ String型: 文字列を格納する参照型です。\n■ int型: 整数値を格納するプリミティブ型です。\n■ System.out.println(): 標準出力に1行出力するメソッドです。"
                    )
                ]
            )
        )
    }
}
