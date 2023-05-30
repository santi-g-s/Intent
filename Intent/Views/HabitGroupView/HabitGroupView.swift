//
//  HabitGroupView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 28/05/2023.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct HabitGroupView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.order_)]) private var fetchedHabits: FetchedResults<Habit>
    @State private var draggedHabit: Habit?
    @State private var habits: [Habit] = []
    
    @Binding var selectedID: UUID

    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                Text("Your habits")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                
                Text("Drag and drop to rearrange habits")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding([.top, .leading])
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(habits, id: \.self) { habit in
                        VStack {
                            if draggedHabit == habit {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .foregroundStyle(.regularMaterial)
                                    .overlay {
                                        Image(systemName: "plus")
                                    }
                            } else {
                                HabitGroupGridItem(habit: habit)
                                    .onTapGesture {
                                        if let id = habit.id {
                                            selectedID = id
                                        }
                                        dismiss()
                                    }
                            }
                        }
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))

                        .onDrag {
                            self.draggedHabit = habit
                            return NSItemProvider(object: String(describing: habit) as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: DropViewDelegate(destinationItem: habit, habits: $habits, draggedItem: $draggedHabit))
                    }
                }
                .padding()
            }
        }
        .onAppear {
            habits = fetchedHabits.map { $0 }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let destinationItem: Habit
    @Binding var habits: [Habit]
    @Binding var draggedItem: Habit?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        if let draggedItem = draggedItem {
            let fromIndex = habits.firstIndex(of: draggedItem)
            let toIndex = habits.firstIndex(of: destinationItem)

            if let fromIndex = fromIndex, let toIndex = toIndex, fromIndex != toIndex {
                withAnimation {
                    self.habits.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))

                    // update order_ property in CoreData
                    DispatchQueue.main.async {
                        let rangeStart = min(fromIndex, toIndex)
                        let rangeEnd = max(fromIndex, toIndex)
                        for index in rangeStart...rangeEnd {
                            self.habits[index].order_ = Int16(index)
                        }
                        
                        #if targetEnvironment(simulator)
                        let dataManager = DataManager.preview
                        #else
                        let dataManager = DataManager.shared
                        #endif
                        
                        dataManager.saveData()
                    }
                }
            }
        }
    }
}


struct HabitGroupView_Previews: PreviewProvider {
    static var previews: some View {
        HabitGroupView(selectedID: .constant(UUID()))
            .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
    }
}
