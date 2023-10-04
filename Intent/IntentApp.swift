//
//  IntentApp.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 18/11/2022.
//

import SwiftUI

@main
struct IntentApp: App {
    @Environment(\.scenePhase) private var scenePhase

    #if targetEnvironment(simulator)
    var dataManager = DataManager.preview
    #else
    var dataManager = DataManager.shared
    #endif

    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        return
                    case .inactive:
                        dataManager.saveData()
                    case .background:
                        dataManager.saveData()
                    default:
                        return
                    }
                }
        }
    }
}
