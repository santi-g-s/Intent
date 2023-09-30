//
//  HabitEditorConfig.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 03/01/2023.
//

import CoreData
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
    
    var notifications: [(content: UNNotificationContent, triggerDate: DateComponents, id: UUID)] = []
    
    mutating func populateNotificationsData() async {
        for notificationIdentifier in data.notificationIdentifiers {
            guard let id = UUID(uuidString: notificationIdentifier) else { continue }
            do {
                let result = try await UserNotificationsManager.getNotification(for: id)
                notifications.append((content: result.content, triggerDate: result.triggerDate, id: id))
            } catch {
                // Handle errors appropriately, maybe print them or handle in some other manner
                print("Error fetching notification for identifier \(notificationIdentifier): \(error)")
            }
        }
    }
    
    mutating func showNotificationEditor() {
        isNotificationEditorShown = true
    }
    
    mutating func presentCreateHabit() {
        data = HabitData()
        isEditing = false
        notifications = []
    }
    
    mutating func presentEditHabit(habit: Habit) {
        data = HabitData(from: habit)
        isEditing = true
        notifications = []
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
    
    mutating func scheduleNotifications(context: NSManagedObjectContext) {
        // Get current notifications
        var currentNotificationIdentifiers = [String]()
        let predicate = NSPredicate(format: "id = %@", data.id as CVarArg)
        let result = DataManager.fetchFirst(Habit.self, predicate: predicate, context: context)
        switch result {
        case .success(let habit):
            if let habit = habit {
                currentNotificationIdentifiers = habit.notificationIdentifiers
            }
        case .failure:
            print("Couldn't fetch Habit for id: \(data.id)")
        }
        
        // Determine notifications to remove
        let newNotificationIdentifiers = notifications.map { $0.id.uuidString }
        let identifiersToRemove = currentNotificationIdentifiers.filter { !newNotificationIdentifiers.contains($0) }
        for identifierString in identifiersToRemove {
            guard let uuid = UUID(uuidString: identifierString) else { continue }
            UserNotificationsManager.deleteNotification(with: uuid)
        }
        
        // Remove the old identifiers
        data.notificationIdentifiers.removeAll { identifiersToRemove.contains($0) }
        
        // Schedule and add new notifications
        for notification in notifications {
            if !currentNotificationIdentifiers.contains(notification.id.uuidString) {
                UserNotificationsManager.scheduleNotification(content: notification.content, triggerDate: notification.triggerDate, notificationIdentifier: notification.id)
                data.notificationIdentifiers.append(notification.id.uuidString)
            }
        }
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
