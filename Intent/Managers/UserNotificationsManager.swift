//
//  UserNotificationsManager.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 16/07/2023.
//

import Foundation
import UserNotifications

struct UserNotificationsManager {
    
    static let center = UNUserNotificationCenter.current()
    
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Authorization request error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if granted {
                print("Authorization granted")
                completion(true)
            } else {
                print("Authorization denied")
                completion(false)
            }
        }
    }
    
    static func createNotification(for habit: Habit) {}
    
    
    
}
