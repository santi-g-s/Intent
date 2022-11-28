//
//  IntentApp.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 18/11/2022.
//

import SwiftUI

@main
struct IntentApp: App {
    
    var dataManager = DataManager.preview
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
        }
    }
}
