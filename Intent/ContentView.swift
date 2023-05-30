//
//  ContentView.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 11/11/2022.
//

import SwiftUI
import CoreData
import SwiftUIKit

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.order_)]) var habits: FetchedResults<Habit>
    
    @State private var selectedId = UUID()
    
    var addNewId = UUID()
    var settingsId = UUID()
    var emptyId = UUID()
    
    @State var sheetType: SheetType? = nil
    
    @State var indicatorViewSize = CGSize.zero
    @State var buttonSize = CGSize.zero
    
    @State var habitEditorConfig = HabitEditorConfig()
    
    @ScaledMetric var scale: CGFloat = 1
    
    var availableWidth: CGFloat {
        return UIScreen.main.bounds.width - 2*buttonSize.width - 2*16 - 20
    }
    
    var isScrollEnabled: Bool {
        return indicatorViewSize.width > availableWidth
    }

    var body: some View {
        VStack(spacing: 0){
            toolbar
                .onChange(of: habitEditorConfig.isGroupViewShown) { isShown in
                    if (isShown) {
                        sheetType = .habitGroup
                        habitEditorConfig.isGroupViewShown = false
                    }
                }
            
            TabView(selection: $selectedId) {
                Image(systemName: "gearshape")
                    .padding()
                    .background(Circle().foregroundStyle(.regularMaterial))
                    .tag(settingsId)
                
                if !habits.isEmpty {
                    ForEach(habits, id: \.id) { habit in
                        HabitView(habit: habit, habitEditorConfig: $habitEditorConfig)
                            .tag(habit.id!)
                    }
                } else {
                    PlaceholderHabitView()
                        .tag(emptyId)
                }
                
                Image(systemName: "plus")
                    .padding()
                    .background(Circle().foregroundStyle(.regularMaterial))
                    .tag(addNewId)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.vertical)
            .onAppear {
                selectedId = habits.first?.id ?? emptyId
            }
            .onChange(of: selectedId) { newValue in
                switch newValue {
                case addNewId:
                    withAnimation {
                        selectedId = habits.last?.id ?? emptyId
                        habitEditorConfig.presentCreateHabit()
                        sheetType = .addHabit
                    }
                case settingsId:
                    withAnimation {
                        selectedId = habits.first?.id ?? emptyId
                        sheetType = .settings
                    }
                default:
                    return
                }
            }
            .sheet(item: $sheetType) { value in
                Group {
                    if value == .addHabit {
                        HabitEditorView(config: $habitEditorConfig)
                            .onDisappear {
                                withAnimation {
                                    selectedId = habits.last?.id ?? emptyId
                                }
                            }
                    } else if value == .settings {
                        SettingsView()
                    } else if value == .habitGroup {
                        HabitGroupView(selectedID: $selectedId)
                    }
                }
            }
            .onChange(of: habits.count) { _ in
                withAnimation {
                    selectedId = habits.last?.id ?? emptyId
                }
            }
        }
    }
    
    var toolbar: some View {
        HStack {
            Button {
                sheetType = .settings
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .foregroundColor(.primary)
                    .padding(6)
                    .background(Circle().foregroundStyle(.regularMaterial))
            }
            .readSize { size in
                buttonSize = size
            }
            
            GeometryReader { geometry in
                HStack {
                    Spacer(minLength: 0)
                    
                    ScrollViewReader { proxy in
                        
                        HStack {
                            if isScrollEnabled {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(habits, id: \.id) { habit in
                                            Button {
                                                withAnimation {
                                                    selectedId = habit.id!
                                                }
                                            } label: {
                                                Image(systemName: habit.iconName)
                                                    .foregroundColor(selectedId == habit.id ? Color.primary : Color(uiColor: UIColor.tertiaryLabel))
                                                    .padding(6)
                                                    .padding(.horizontal, 2)
                                                    .contentShape(Rectangle())
                                            }
                                            .id(habit.id!)
                                        }
                                    }
                                    .readSize { size in
                                        indicatorViewSize = size
                                    }
                                }
                                    
                            } else {
                                HStack(spacing: 0) {
                                    ForEach(habits, id: \.id) { habit in
                                        Button {
                                            withAnimation {
                                                selectedId = habit.id!
                                            }
                                        } label: {
                                            Image(systemName: habit.iconName)
                                                .foregroundColor(selectedId == habit.id ? Color.primary : Color(uiColor: UIColor.tertiaryLabel))
                                                .padding(6)
                                                .padding(.horizontal, 2)
                                                .contentShape(Rectangle())
                                        }
                                        .id(habit.id!)
                                    }
                                }
                                .readSize { size in
                                    indicatorViewSize = size
                                }
                                
                            }
                        }
                        .frame(width: min(indicatorViewSize.width, availableWidth))
                        .onChange(of: selectedId) { newValue in
                            withAnimation {
                                proxy.scrollTo(newValue)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .background(Capsule().foregroundStyle(.regularMaterial))
                    
                    Spacer(minLength: 0)
                }
            }
            .frame(height: indicatorViewSize.height, alignment: .center)
            
            Button {
                sheetType = .addHabit
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(.primary)
                    .padding(6)
                    .background(Circle().foregroundStyle(.regularMaterial))
            }
        }
        .padding(.horizontal)
    }
    
    enum SheetType: Identifiable {
        case addHabit
        case settings
        case habitGroup
        
        var id: Self {
           return self
       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
    }
}
