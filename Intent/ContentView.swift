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
    
    @State var showAddHabit = false

    var body: some View {
        VStack(spacing: 0){
            HStack {
                Button {
                    //
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.primary)
                        .padding(6)
                        .background(Circle().foregroundStyle(.regularMaterial))
                }
                
                Spacer()
                HStack(spacing: 16){
                    ForEach(habits, id: \.id) { habit in
                        Button {
                            withAnimation {
                                selectedId = habit.id!
                            }
                        } label: {
                            Image(systemName: habit.iconName)
                                .foregroundColor(selectedId == habit.id ? Color.primary : Color(uiColor: UIColor.tertiaryLabel))
                        }
                    }
                }

                Spacer()
                
                Button {
                    selectedId = addNewId
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                        .padding(6)
                        .background(Circle().foregroundStyle(.regularMaterial))
                }
            }
            .padding(.horizontal)
            
            TabView(selection: $selectedId) {
                ForEach(habits, id: \.id) { habit in
                    HabitView(habit: habit)
                        .tag(habit.id!)
                }
                
                Image(systemName: "plus")
                    .padding()
                    .background(Circle().foregroundColor(Color.gray.opacity(0.15)))
                    .tag(addNewId)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.vertical)
            .onAppear {
                selectedId = habits.first?.id ?? addNewId
            }
            .onChange(of: selectedId) { newValue in
                if newValue == addNewId {
                    withAnimation {
                        selectedId = habits.last?.id ?? addNewId
                    }
                    showAddHabit = true
                }
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
    }
}
