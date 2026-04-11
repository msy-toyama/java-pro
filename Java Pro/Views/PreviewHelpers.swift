//
//  PreviewHelpers.swift
//  Java Pro
//
//  Xcode Preview 用の共通ヘルパー。
//  インメモリSwiftDataコンテナとコンテンツ初期化を提供する。
//

#if DEBUG
import SwiftUI
import SwiftData

/// Preview 用のインメモリ ModelContainer を生成する。
@MainActor
enum PreviewContainer {
    /// 全モデルを含むインメモリコンテナ。
    static var shared: ModelContainer = {
        let schema = Schema([
            UserLessonProgress.self,
            UserQuizHistory.self,
            UserDailyRecord.self,
            AppSettings.self,
            UserXPRecord.self,
            UserBadge.self,
            UserLevel.self,
            UserExamResult.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])

        // コンテンツを同期読み込み（Preview 用）
        ContentService.shared.loadAllContent()

        return container
    }()
}
#endif
