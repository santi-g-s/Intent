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
            ContentView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        print("Active")
                    case .inactive:
                        print("Inactive")
                        dataManager.saveData()
                    case .background:
                        print("background")
                        dataManager.saveData()
                    default:
                        print("unknown")
                    }
                }
        }
    }
}
