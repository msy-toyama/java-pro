//
//  BadgeListView.swift
//  Java Pro
//
//  全32種のバッジコレクションを表示するビュー。
//  獲得済みバッジはカラー表示、未獲得はロック表示。
//  ProfileView から遷移する。
//

import SwiftUI
import SwiftData

struct BadgeListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var earnedBadges: [UserBadge] = []

    private static let badgeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    @State private var selectedBadge: BadgeDetail?

    private let columns = [
        GridItem(.flexible(), spacing: AppLayout.paddingSM),
        GridItem(.flexible(), spacing: AppLayout.paddingSM),
        GridItem(.flexible(), spacing: AppLayout.paddingSM),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.paddingLG) {
                // サマリー
                summaryHeader
                    .staggeredAppear(index: 0)

                // 獲得済み
                if !earnedBadges.isEmpty {
                    sectionTitle("獲得済み (\(earnedBadges.count))")
                    LazyVGrid(columns: columns, spacing: AppLayout.paddingMD) {
                        ForEach(Array(earnedBadges.enumerated()), id: \.element.badgeId) { index, badge in
                            badgeCell(
                                id: badge.badgeId,
                                name: badge.name,
                                icon: badge.iconName,
                                colorHex: badge.colorHex,
                                earned: true,
                                earnedAt: badge.earnedAt
                            )
                            .staggeredAppear(index: min(index + 1, 12))
                        }
                    }
                }

                // 未獲得
                let lockedDefs = GamificationService.badgeDefinitions.filter { def in
                    !earnedBadges.contains(where: { $0.badgeId == def.id })
                }
                if !lockedDefs.isEmpty {
                    sectionTitle("未獲得 (\(lockedDefs.count))")
                    LazyVGrid(columns: columns, spacing: AppLayout.paddingMD) {
                        ForEach(lockedDefs, id: \.id) { def in
                            badgeCell(
                                id: def.id,
                                name: def.name,
                                icon: def.icon,
                                colorHex: def.color,
                                earned: false,
                                earnedAt: nil
                            )
                        }
                    }
                }
            }
            .padding(AppLayout.paddingMD)
        }
        .background(AppColor.background)
        .navigationTitle("バッジコレクション")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadBadges)
        .sheet(item: $selectedBadge) { detail in
            badgeDetailSheet(detail)
        }
    }

    // MARK: - Summary

    private var summaryHeader: some View {
        let total = GamificationService.badgeDefinitions.count
        let earned = earnedBadges.count
        let rate = total > 0 ? Double(earned) / Double(total) : 0

        return HStack(spacing: AppLayout.paddingMD) {
            ZStack {
                Circle()
                    .stroke(AppColor.textTertiary.opacity(0.2), lineWidth: 6)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: rate)
                    .stroke(AppColor.xpGold, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                Text("\(earned)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.xpGold)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(earned) / \(total) バッジ獲得")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text("コンプリート率 \(Int(rate * 100))%")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
        }
        .padding(AppLayout.paddingMD)
        .modifier(CardStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(earned)/\(total)バッジ獲得、コンプリート率\(Int(rate * 100))%")
    }

    // MARK: - Section Title

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(AppFont.headline)
            .foregroundStyle(AppColor.textPrimary)
    }

    // MARK: - Badge Cell

    private func badgeCell(id: String, name: String, icon: String, colorHex: String, earned: Bool, earnedAt: Date?) -> some View {
        let color = Color(hex: colorHex)

        return Button {
            if let def = GamificationService.badgeDefinitions.first(where: { $0.id == id }) {
                selectedBadge = BadgeDetail(
                    id: def.id,
                    name: def.name,
                    description: def.description,
                    icon: def.icon,
                    colorHex: def.color,
                    earned: earned,
                    earnedAt: earnedAt
                )
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(earned ? color.opacity(0.15) : AppColor.textTertiary.opacity(0.08))
                        .frame(width: 56, height: 56)
                    if earned {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(color)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundStyle(AppColor.textTertiary.opacity(0.4))
                    }
                }

                Text(name)
                    .font(AppFont.caption)
                    .foregroundStyle(earned ? AppColor.textPrimary : AppColor.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.paddingSM)
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("\(name)バッジ、\(earned ? "獲得済み" : "未獲得")")
        .accessibilityHint("詳細を表示します")
    }

    // MARK: - Detail Sheet

    private func badgeDetailSheet(_ detail: BadgeDetail) -> some View {
        let color = Color(hex: detail.colorHex)
        return VStack(spacing: AppLayout.paddingMD) {
            Spacer()

            ZStack {
                Circle()
                    .fill(detail.earned ? color.opacity(0.15) : AppColor.textTertiary.opacity(0.08))
                    .frame(width: 100, height: 100)
                if detail.earned {
                    Image(systemName: detail.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }

            Text(detail.name)
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            Text(detail.description)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            if detail.earned, let date = detail.earnedAt {
                Text("\(Self.badgeDateFormatter.string(from: date)) に獲得")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textTertiary)
            } else {
                Text("未獲得")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textTertiary)
            }

            Spacer()

            Button("閉じる") {
                selectedBadge = nil
            }
            .font(AppFont.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
        }
        .padding(AppLayout.paddingLG)
        .presentationDetents([.medium, .large])
    }

    // MARK: - Load

    private func loadBadges() {
        let service = GamificationService(modelContext: modelContext)
        earnedBadges = service.getEarnedBadges()
    }
}

// MARK: - Badge Detail Model

private struct BadgeDetail: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let colorHex: String
    let earned: Bool
    let earnedAt: Date?
}
