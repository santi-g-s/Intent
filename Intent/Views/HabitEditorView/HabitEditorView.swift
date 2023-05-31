//
//  HabitEditorView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 25/12/2022.
//

import SwiftUI
import CoreData

struct HabitEditorView: View {
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    enum Field: Hashable {
        case title
        case message
    }
    
    @Binding var config: HabitEditorConfig
    
    @FocusState var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    
                    TextField("Title", text: $config.data.title)
                        .focused($focusedField, equals: .title)
                    
                    Button {
                        focusedField = nil
                        config.presentSymbolPicker()
                    } label: {
                        HStack{
                            Text("Pick an icon")
                            Spacer()
                            Image(systemName: config.data.iconName)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    ColorPicker("Pick a color", selection: $config.data.accentColor, supportsOpacity: false)
                }

                Section("Scheduling") {
                    Picker("How often", selection: $config.data.timePeriod) {
                        Text("Daily").tag(TimePeriod.daily)
                        Text("Weekly").tag(TimePeriod.weekly)
                        Text("Monthly").tag(TimePeriod.monthly)
                    }
                    .pickerStyle(.segmented)
                    
//                    Picker("Completion Type", selection: $config.data.completionType) {
//                        Text("=").tag(CompletionType.equalTo)
//                        Text(">").tag(CompletionType.greaterThan)
//                    }
//                    .pickerStyle(.segmented)
                    
                    Picker("How many times a \(config.data.timePeriod.unitName)", selection: $config.data.requiredCount) {
                        ForEach(1...10, id: \.self) { index in
                            Text("\(index)")
                        }
                    }
                    .pickerStyle(.automatic)
                }
                
                Section("Messages") {
                    VStack(alignment: .leading){
                        TextField("Add a motivational message", text: $config.messageText, axis: .vertical)
                            .focused($focusedField, equals: .message)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()

                                    Button("Done") {
                                        focusedField = nil
                                    }
                                }
                            }
                        Button {
                            config.addMessage()
                        } label: {
                            HStack{
                                Spacer()
                                Text("Add")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .disabled(config.isAddMessageDisabled)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            return 0
                        }
                    }
                    ForEach(config.data.messages, id: \.self) { message in
                        Text(message)
                    }
                    .onDelete { offsets in
                        config.deleteMessage(at: offsets)
                    }
                    .onMove { source, destination in
                        config.rearrangeMessages(from: source, to: destination)
                    }
                }
            }
            .navigationTitle(config.isEditing ? "Edit habit" : "Add habit")
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Spacer()
                HStack {
                    if config.isEditing {
                        Spacer()
                        Button {
                            Habit.deleteHabit(with: config.data, context: context)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label("Delete Habit", systemImage: "trash")
                                .bold()
                                .foregroundColor(.red)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundStyle(.regularMaterial)
                                }
                        }
                    }
                    Spacer()
                    Button {
                        if config.isEditing {
                            Habit.updateHabit(with: config.data, context: context)
                        } else {
                            Habit.createHabit(with: config.data, context: context)
                        }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label(config.isEditing ? "Update habit" : "Create Habit", systemImage: config.isEditing ? "checkmark" : "plus")
                            .bold()
                            .foregroundColor(config.data.accentColor.isDarkBackground() ? .white : .black)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundStyle(config.data.accentColor)
                            }
                    }
                    .disabled(config.isButtonDisabled)
                    
                    Spacer()
                    
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $config.isSymbolPickerShown) {
            SymbolPicker(symbol: $config.data.iconName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    struct ContentView: View {
        
        @State var config = HabitEditorConfig()
        
        var body: some View {
            HabitEditorView(config: $config)
                .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
                .onAppear{
                    config.isEditing = true
                    config.data.title = "Test"
                }
        }
    }
    static var previews: some View {
        ContentView()
    }
}
