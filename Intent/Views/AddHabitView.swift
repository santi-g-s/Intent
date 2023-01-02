//
//  AddHabitView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 25/12/2022.
//

import SwiftUI
import CoreData

struct AddHabitView: View {
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    enum Field: Hashable {
        case title
        case message
    }
    
    @State var title = ""
    @State var timePeriod = TimePeriod.daily
    @State var requiredCount = 1
    @State var color = Color.accentColor
    @State var symbolName = "star"
    @State var messageText = ""
    @State var messages = [String]()
    
    @State var showSymbolPicker = false
    @FocusState var focusedField: Field?
    
    var addButtonDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                    Button {
                        showSymbolPicker = true
                    } label: {
                        HStack{
                            Text("Pick an icon")
                            Spacer()
                            Image(systemName: symbolName)
                        }
                        .foregroundColor(.primary)
                    }

                    ColorPicker("Pick a color", selection: $color, supportsOpacity: false)
                }

                Section("Scheduling") {
                    Picker("How often", selection: $timePeriod) {
                        Text("Daily").tag(TimePeriod.daily)
                        Text("Weekly").tag(TimePeriod.weekly)
                        Text("Monthly").tag(TimePeriod.monthly)
                    }
                    .pickerStyle(.segmented)
                    Picker("How many times a \(timePeriod.unitName)", selection: $requiredCount) {
                        ForEach(0...10, id: \.self) { index in
                            Text("\(index)")
                        }
                    }
                }

                Section("Messages") {
                    VStack(alignment: .leading){
                        TextField("Add a motivational message", text: $messageText, axis: .vertical)
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
                            messages.append(messageText.trimmingCharacters(in: .whitespacesAndNewlines))
                            messageText = ""
                        } label: {
                            HStack{
                                Spacer()
                                Text("Add")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            return 0
                        }
                    }
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                    }
                    .onDelete { indexSet in
                        messages.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Add a habit")
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Spacer()
                Button {
                    Habit.makeHabit(title: title.trimmingCharacters(in: .whitespacesAndNewlines), timePeriod: timePeriod, requiredCount: requiredCount, accentColor: color, symbolName: symbolName, messages: messages, context: context)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Create Habit", systemImage: "plus")
                        .bold()
                        .foregroundColor(.white)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundStyle(color)
                        }
                }
                .padding(.top)
                .disabled(addButtonDisabled)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $showSymbolPicker) {
            SymbolPicker(symbol: $symbolName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView()
    }
}
