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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate_)]) var habits: FetchedResults<Habit>
    
    @State private var selectedId = UUID()
    var addNewId = UUID()

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                ForEach(habits, id: \.id) { habit in
                    Image(systemName: habit.iconName)
                        .foregroundColor(selectedId == habit.id ? Color.primary : Color.gray.opacity(1/3))
                        .onTapGesture {
                            withAnimation {
                                selectedId = habit.id!
                            }
                        }
                }
                Image(systemName: "plus")
                    .foregroundColor(selectedId == addNewId ? Color.primary : Color.gray.opacity(1/3))
                    .onTapGesture {
                        selectedId = addNewId
                    }
            }
            TabView(selection: $selectedId) {
                ForEach(habits, id: \.id) { habit in
                    HabitView(habit: habit)
                        .tag(habit.id!)
                }
                
                Text("Add new")
                    .tag(addNewId)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.vertical)
            .onAppear {
                selectedId = habits.first?.id ?? UUID()
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
    }
}
