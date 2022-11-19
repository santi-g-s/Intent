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
            ContentView(habit: Habit.makePreview(context: dataManager.container.viewContext))
                .environment(\.managedObjectContext, dataManager.container.viewContext)
        }
    }
}
