//
//  ModelContextExtensions.swift
//  Java Pro
//
//  SwiftData の fetch / fetchCount を安全に実行し、
//  エラー時にログを出力するヘルパー。
//  全サービスで try? を使った無言のエラー握りつぶしを排除する。
//

import Foundation
import SwiftData
import os

extension ModelContext {

    /// fetch を実行し、失敗時にログ出力して空配列を返す。
    func fetchLogged<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>,
        caller: String = #function
    ) -> [T] {
        do {
            return try fetch(descriptor)
        } catch {
            AppLogger.swiftData.warning("fetch failed [\(caller)]: \(error.localizedDescription)")
            return []
        }
    }

    /// fetch して先頭要素を返す。失敗時はログ出力して nil を返す。
    /// 呼び出し元が fetchLimit を設定していない場合、自動で 1 に制限して
    /// 不要な全件取得を防止する。
    func fetchFirstLogged<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>,
        caller: String = #function
    ) -> T? {
        do {
            var limited = descriptor
            if limited.fetchLimit == nil {
                limited.fetchLimit = 1
            }
            return try fetch(limited).first
        } catch {
            AppLogger.swiftData.warning("fetch failed [\(caller)]: \(error.localizedDescription)")
            return nil
        }
    }

    /// fetchCount を実行し、失敗時にログ出力して 0 を返す。
    func fetchCountLogged<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>,
        caller: String = #function
    ) -> Int {
        do {
            return try fetchCount(descriptor)
        } catch {
            AppLogger.swiftData.warning("fetchCount failed [\(caller)]: \(error.localizedDescription)")
            return 0
        }
    }
}
