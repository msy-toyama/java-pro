//
//  Java_StepApp.swift
//  Java Step
//
//  Created by 小林将也 on 2026/04/05.
//

import SwiftUI
import CoreData

@main
struct Java_StepApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
