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
            let lang = LanguageManager.shared
            switch self {
            case .home:   return lang.l("tab.home")
            case .learn:  return lang.l("tab.learn")
            case .exam:   return lang.l("tab.exam")
            case .mypage: return lang.l("tab.profile")
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
