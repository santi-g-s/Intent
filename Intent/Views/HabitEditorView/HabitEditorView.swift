//
//  HabitEditorView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 25/12/2022.
//

import CoreData
import SwiftUI

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
                        HStack {
                            Text("Pick an icon")
                            Spacer()
                            Image(systemName: config.data.iconName)
                        }
                        .foregroundColor(.primary)
                    }

                    ColorPicker("Pick a color", selection: $config.data.accentColor, supportsOpacity: false)
                }

                Section("Scheduling") {
                    VStack {
                        Picker("How often", selection: $config.data.timePeriod) {
                            Text("Daily").tag(TimePeriod.daily)
                            Text("Weekly").tag(TimePeriod.weekly)
                            Text("Monthly").tag(TimePeriod.monthly)
                        }
                        .pickerStyle(.segmented)

                        Picker("How many times a \(config.data.timePeriod.unitName)", selection: $config.data.requiredCount) {
                            ForEach(1 ... 10, id: \.self) { index in
                                Text("\(index)")
                            }
                        }
                        .pickerStyle(.automatic)
                    }
                }

                Section("Messages") {
                    VStack(alignment: .leading) {
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
                            HStack {
                                Spacer()
                                Text("Add")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .disabled(config.isAddMessageDisabled)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            0
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

                Section("Notifications") {
                    Button {
                        config.showNotificationEditor()
                    } label: {
                        Label("Add a notification", systemImage: "bell")
                            .foregroundColor(config.data.accentColor)
                    }
                    .tint(config.data.accentColor)
                    .sheet(isPresented: $config.isNotificationEditorShown) {
                        NotificationEditorView(habit: config.data, onCompletion: { content, triggerDate, notificationIdentifier in
                            config.isNotificationEditorShown = false
                            config.notifications.append((content, triggerDate, notificationIdentifier))
                        })
                        .presentationDetents([.medium])
                    }
                    ForEach(config.notifications, id: \.id) { value in
                        Text(UserNotificationsManager.notificationScheduleDescription(from: value.triggerDate))
                    }
                    .onDelete { offsets in
                        config.deleteNotification(at: offsets)
                    }
                }
            }
            .navigationTitle(config.isEditing ? "Edit habit" : "Add habit")
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if config.isEditing {
                        Spacer()
                        Button {
                            Habit.deleteHabit(with: config.data, context: context)
                            config.didDeleteHabit = true
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
                        config.scheduleNotifications(context: context)

                        if config.isEditing {
                            Habit.updateHabit(with: config.data, context: context)
                        } else {
                            let newHabit = Habit.createHabit(with: config.data, context: context)
                            config.createdHabitId = newHabit.id
                        }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label(config.isEditing ? "Update Habit" : "Create Habit", systemImage: config.isEditing ? "checkmark" : "plus")
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
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .sheet(isPresented: $config.isSymbolPickerShown) {
            SymbolPicker(symbol: $config.data.iconName)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .task {
            await config.populateNotificationsData()
        }
    }

    @State var notificatiomEditorViewSize = CGSize.zero
}

struct AddHabitView_Previews: PreviewProvider {
    struct ContentView: View {
        @State var config = HabitEditorConfig()

        var body: some View {
            HabitEditorView(config: $config)
                .environment(\.managedObjectContext, DataManager.preview.container.viewContext)
                .onAppear {
                    config.isEditing = true
                    config.data.title = "Test"
                }
        }
    }

    static var previews: some View {
        ContentView()
    }
}
