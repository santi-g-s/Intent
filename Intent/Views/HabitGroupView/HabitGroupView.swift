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
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate_)]) private var fetchedHabits: FetchedResults<Habit>
    @State private var draggedHabit: Habit?
    @State private var habits: [Habit] = []

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
            if let fromIndex = fromIndex {
                let toIndex = habits.firstIndex(of: destinationItem)
                if let toIndex = toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.habits.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}


struct TestView: View {
    @State private var isLongPress = false

    var body: some View {
        ScrollView {
            VStack {
                Button(action: {
                    print("Button 1 Tapped")
                }) {
                    Text("Button 1")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }

                Button(action: {
                    print("Button 2 Tapped")
                }) {
                    Text("Button 2")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isLongPress ? Color.green : Color.gray)
            .onLongPressGesture(minimumDuration: 1.0, maximumDistance: 1.0, perform: {
                print("Long Press Detected")
            }, onPressingChanged: { newValue in
                isLongPress = newValue
            })
//            .simultaneousGesture(
//                LongPressGesture(minimumDuration: 1.0)
//                    .updating($isLongPress) { currentState, gestureState, transaction in
//                        gestureState = currentState
//                    }
//                    .onEnded { _ in
//                        print("Long Press Detected")
//                    }
//            )

            ForEach(0..<100, id: \.self ) { idx in
                Text("\(idx)")
            }
        }
    }
}


struct HabitGroupView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
    }
}
