//
//  PaywallView.swift
//  Java Pro
//
//  フルアクセス購入画面。¥480 の買い切りで全コンテンツを解放する。
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    private var lang: LanguageManager { LanguageManager.shared }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppLayout.paddingLG) {
                    // ヘッダー
                    headerSection
                        .staggeredAppear(index: 0)

                    // 無料で使える機能
                    freeSection
                        .staggeredAppear(index: 1)

                    // フルアクセスの特典
                    benefitsSection
                        .staggeredAppear(index: 2)

                    // 購入ボタン
                    purchaseSection
                        .staggeredAppear(index: 3)

                    // 復元リンク
                    restoreLink

                    // エラー表示
                    if let errorMsg = StoreService.shared.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppColor.error)
                            Text(errorMsg)
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.error)
                        }
                        .padding(AppLayout.paddingSM)
                        .background(AppColor.error.opacity(0.08), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadiusSmall))
                    }

                    // 注意事項
                    disclaimerSection
                }
                .padding(AppLayout.paddingMD)
            }
            .background(AppColor.background)
            .navigationTitle(lang.l("paywall.full_access"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.l("paywall.close")) { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppLayout.paddingSM) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(colors: [AppColor.xpGold, AppColor.accent],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .pulse(min: 0.92, max: 1.08, duration: 1.5)
                .shimmer(duration: 2.5)
                .accessibilityHidden(true)

            Text(lang.l("paywall.title"))
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text(lang.l("paywall.subtitle"))
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppLayout.paddingLG)
    }

    // MARK: - Free Section

    private var freeSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("paywall.free_title"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            featureRow(icon: "checkmark.circle.fill", color: AppColor.success, text: lang.l("paywall.free.lessons"))
            featureRow(icon: "checkmark.circle.fill", color: AppColor.success, text: lang.l("paywall.free.quiz"))
            featureRow(icon: "checkmark.circle.fill", color: AppColor.success, text: lang.l("paywall.free.exam"))
            featureRow(icon: "checkmark.circle.fill", color: AppColor.success, text: lang.l("paywall.free.review"))
            featureRow(icon: "checkmark.circle.fill", color: AppColor.success, text: lang.l("paywall.free.glossary"))
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.success.opacity(0.06), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingSM) {
            Text(lang.l("paywall.pro_title"))
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            featureRow(icon: "lock.open.fill", color: AppColor.primary, text: lang.l("paywall.pro.all_lessons", ContentService.shared.getAllCourses().count, ContentService.shared.totalLessonCount))
            featureRow(icon: "chevron.left.forwardslash.chevron.right", color: Color(hex: "#6366F1"), text: lang.l("paywall.pro.practice"))
            featureRow(icon: "doc.text.fill", color: AppColor.accent, text: lang.l("paywall.pro.all_exams", ExamService.totalExamQuestionCount))
            featureRow(icon: "chart.bar.fill", color: AppColor.levelPurple, text: lang.l("paywall.pro.analysis"))
            featureRow(icon: "arrow.clockwise", color: AppColor.success, text: lang.l("paywall.pro.unlimited_review"))
            featureRow(icon: "nosign", color: AppColor.error, text: lang.l("paywall.pro.no_ads"))
        }
        .padding(AppLayout.paddingMD)
        .background(AppColor.cardBackground, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: AppLayout.paddingSM) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28)
                .accessibilityHidden(true)
            Text(text)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    // MARK: - Purchase Section

    private var purchaseSection: some View {
        VStack(spacing: AppLayout.paddingSM) {
            if StoreService.shared.fullAccessUnlocked {
                // 購入済み表示
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppColor.success)
                    Text(lang.l("paywall.purchased"))
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.success)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColor.success.opacity(0.1), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            } else if let product = StoreService.shared.product(for: .fullAccess) {
                // 価格表示カード
                VStack(spacing: 4) {
                    Text(lang.l("paywall.one_time"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(product.displayPrice)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(AppColor.primary)
                        .shimmer(duration: 3.0)
                    Text(lang.l("paywall.one_time_desc"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppLayout.paddingMD)
                .background(AppColor.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColor.primary.opacity(0.3), lineWidth: 2)
                )

                // 購入ボタン
                Button {
                    Task {
                        let success = await StoreService.shared.purchase(product)
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    if StoreService.shared.isPurchasing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        Text(lang.l("paywall.buy_button", product.displayPrice))
                            .font(AppFont.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                .buttonStyle(.pressable)
                .disabled(StoreService.shared.isPurchasing)
            } else {
                // 商品読み込み中 / エラー時
                VStack(spacing: 8) {
                    ProgressView()
                    Text(lang.l("paywall.loading"))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .onAppear {
                    Task { await StoreService.shared.loadProducts() }
                }
            }
        }
    }

    // MARK: - Restore

    private var restoreLink: some View {
        Button(lang.l("paywall.restore")) {
            Task { await StoreService.shared.restorePurchases() }
        }
        .font(AppFont.callout)
        .foregroundStyle(AppColor.textSecondary)
    }

    // MARK: - Disclaimer

    /// プライバシーポリシーURL
    private static let privacyPolicyURL = URL(string: "https://msy-toyama.github.io/java-pro/privacy.html")
    /// 利用規約URL
    private static let termsOfUseURL    = URL(string: "https://msy-toyama.github.io/java-pro/terms.html")

    private var disclaimerSection: some View {
        VStack(spacing: 6) {
            Text(lang.l("paywall.disclaimer"))
                .font(.system(size: 11))
                .foregroundStyle(AppColor.textTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                if let url = Self.privacyPolicyURL {
                    Link(lang.l("paywall.privacy"), destination: url)
                }
                if let url = Self.termsOfUseURL {
                    Link(lang.l("paywall.terms"), destination: url)
                }
            }
            .font(.system(size: 11))
            .foregroundStyle(AppColor.textTertiary)
        }
        .padding(.horizontal, AppLayout.paddingMD)
    }
}
