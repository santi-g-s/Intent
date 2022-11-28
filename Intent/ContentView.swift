//
//  ContentView.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 11/11/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    var body: some View {
        HabitView(habit: Habit.makePreview(context: context))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
