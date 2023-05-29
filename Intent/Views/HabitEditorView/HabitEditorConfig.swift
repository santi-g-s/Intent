//
//  HabitEditorConfig.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 03/01/2023.
//

import Foundation

struct HabitEditorConfig {
    
    var data = HabitData()
    
    var isEditing = false
    var isSymbolPickerShown = false
    var messageText = ""
    
    var isGroupViewShown = false
    
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
