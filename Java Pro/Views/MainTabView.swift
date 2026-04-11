//
//  MainTabView.swift
//  Java Pro
//
//  メインの4タブナビゲーション。
//  iPhoneでは5タブ以下に抑え、折りたたみを防止する。
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabContent(tab)
                    .tabItem {
                        Label(tab.label, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(AppColor.primary)
    }

    @ViewBuilder
    private func tabContent(_ tab: Tab) -> some View {
        switch tab {
        case .home:     HomeView(switchToTab: { selectedTab = $0 })
        case .learn:    CourseListView()
        case .exam:     CertificationView()
        case .mypage:   ProfileView()
        }
    }
}

extension MainTabView {
    enum Tab: Hashable, CaseIterable {
        case home, learn, exam, mypage

        var label: String {
            switch self {
            case .home:   return "ホーム"
            case .learn:  return "学習"
            case .exam:   return "試験対策"
            case .mypage: return "マイページ"
            }
        }

        var icon: String {
            switch self {
            case .home:   return "house.fill"
            case .learn:  return "book.fill"
            case .exam:   return "graduationcap.fill"
            case .mypage: return "person.crop.circle.fill"
            }
        }
    }
}
