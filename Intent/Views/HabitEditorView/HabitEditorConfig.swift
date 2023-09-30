//
//  HabitEditorConfig.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 03/01/2023.
//

import Foundation
import UserNotifications

struct HabitEditorConfig {
    var data = HabitData()
    
    var isEditing = false
    var isSymbolPickerShown = false
    var messageText = ""
    
    var isGroupViewShown = false
    
    var createdHabitId: UUID? = nil
    var didDeleteHabit = false
    
    var isNotificationEditorShown = false
    
    var notifications: [(content: UNMutableNotificationContent, triggerDate: DateComponents, id: UUID)] = []
    
    mutating func showNotificationEditor() {
        isNotificationEditorShown = true
    }
    
    mutating func presentCreateHabit() {
        data = HabitData()
        isEditing = false
    }
    
    mutating func presentEditHabit(habit: Habit) {
        data = HabitData(from: habit)
        isEditing = true
    }
    
    mutating func presentSymbolPicker() {
        isSymbolPickerShown = true
    }
    
    mutating func addMessage() {
        data.messages.append(messageText.trimmingCharacters(in: .whitespacesAndNewlines))
        messageText = ""
    }
    
    mutating func deleteMessage(at offsets: IndexSet) {
        data.messages.remove(atOffsets: offsets)
    }
    
    mutating func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
    
    mutating func rearrangeMessages(from source: IndexSet, to destination: Int) {
        data.messages.move(fromOffsets: source, toOffset: destination)
    }
    
    var isAddMessageDisabled: Bool {
        messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isButtonDisabled: Bool {
        data.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
