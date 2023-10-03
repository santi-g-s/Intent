//
//  UserNotificationsManager.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 16/07/2023.
//

import Foundation
import UserNotifications

struct UserNotificationsManager {
    /// The user notification center object for the app.
    static let center = UNUserNotificationCenter.current()

    /// Requests the user's permission to deliver notifications.
    ///
    /// - Parameter completion: A closure that will receive a boolean value indicating whether the user granted permission.
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

    /// Schedules a notification for a given habit.
    ///
    /// - Parameters:
    ///   - habit: The habit for which the notification is to be created.
    ///   - timeOfDay: The desired notification time.
    ///   - interval: The notification repetition interval.
    ///   - intervalFrequency: How often the notification should repeat within the given interval.
    ///   - weekdays: The specific weekdays for notification if the interval is set to weekly.
    ///   - monthlyPickerType: Specifies how to handle monthly notifications.
    ///   - selectedDay: The day of the month to notify if monthlyPickerType is set to dayOfMonth.
    ///   - selectedOffsetValue: Specifies which week of the month to notify if monthlyPickerType is set to offset.
    ///   - selectedOffsetWeekday: Specifies the weekday for notification if monthlyPickerType is set to offset.
    ///   - completion: A closure that will receive a boolean value indicating whether the notification was scheduled successfully.
    static func createNotificationData(for habit: HabitData, on timeOfDay: Date, interval: NotificationInterval, weekdays: [Int], monthlyPickerType: MonthlyPickerType, selectedDay: Int, selectedOffsetValue: OffsetValue, selectedOffsetWeekday: Int, completion: @escaping (_ content: UNMutableNotificationContent?, _ triggerDate: DateComponents?, _ notificationIdentifier: UUID?) -> Void) {
        requestAuthorization { granted in
            guard granted else {
                completion(nil, nil, nil)
                return
            }

            let content = UNMutableNotificationContent()
            content.title = habit.title
            content.body = habit.messages.first ?? "The journey of a thousand miles begins with one step."
            content.sound = .default

            let triggerHour = Calendar.current.component(.hour, from: timeOfDay)
            let triggerMinute = Calendar.current.component(.minute, from: timeOfDay)

            switch interval {
            case .daily:
                var dateComponents = DateComponents()
                dateComponents.hour = triggerHour
                dateComponents.minute = triggerMinute
                completion(content, dateComponents, UUID())

            case .weekly:
                for weekday in weekdays {
                    var dateComponents = DateComponents()
                    dateComponents.weekday = weekday
                    dateComponents.hour = triggerHour
                    dateComponents.minute = triggerMinute
                    completion(content, dateComponents, UUID())
                }

            case .monthly:
                if monthlyPickerType == .dayOfMonth {
                    var dateComponents = DateComponents()
                    dateComponents.day = selectedDay
                    dateComponents.hour = triggerHour
                    dateComponents.minute = triggerMinute
                    completion(content, dateComponents, UUID())
                } else if monthlyPickerType == .offset {
                    var dateComponents = DateComponents()
                    dateComponents.weekday = selectedOffsetWeekday
                    switch selectedOffsetValue {
                    case .first:
                        dateComponents.weekdayOrdinal = 1
                    case .second:
                        dateComponents.weekdayOrdinal = 2
                    case .third:
                        dateComponents.weekdayOrdinal = 3
                    case .fourth:
                        dateComponents.weekdayOrdinal = 4
                    case .fifth:
                        dateComponents.weekdayOrdinal = 5
                    case .last:
                        dateComponents.weekdayOrdinal = -1
                    }
                    dateComponents.hour = triggerHour
                    dateComponents.minute = triggerMinute
                    completion(content, dateComponents, UUID())
                }
            }
        }
    }

    /// Schedules a notification using the provided content and trigger date.
    ///
    /// - Parameters:
    ///   - content: The content of the notification.
    ///   - triggerDate: The date components specifying when the notification should be delivered.
    static func scheduleNotification(content: UNNotificationContent, triggerDate: DateComponents, notificationIdentifier: UUID) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    static func getNotification(for identifier: UUID) async throws -> (content: UNNotificationContent, triggerDate: DateComponents) {
        // Get the current notification center
        let center = UNUserNotificationCenter.current()

        // Fetch all pending notification requests
        let requests = await center.pendingNotificationRequests()

        for request in requests {
            if request.identifier == identifier.uuidString {
                let content = request.content
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let triggerDate = trigger.dateComponents
                    return (content: content, triggerDate: triggerDate)
                } else {
                    print("Trigger is not of type UNCalendarNotificationTrigger: \(String(describing: request.trigger))")
                }

                throw NotificationError.invalidData
            }
        }
        throw NotificationError.notFound
    }

    static func deleteNotification(with identifier: UUID) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier.uuidString])
    }

    static func notificationScheduleDescription(from triggerDate: DateComponents) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        // Create a dummy date for time formatting
        let dummyDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: triggerDate.hour, minute: triggerDate.minute))!
        let formattedTime = timeFormatter.string(from: dummyDate)

        // For daily schedules
        if triggerDate.weekday == nil, triggerDate.day == nil, triggerDate.weekdayOrdinal == nil {
            return "Daily at \(formattedTime)"
        }

        // For weekly schedules
        if let weekday = triggerDate.weekday, triggerDate.day == nil, triggerDate.weekdayOrdinal == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let weekdayName = formatter.weekdaySymbols[weekday - 1]
            return "Every \(weekdayName) at \(formattedTime)"
        }

        // For monthly schedules by day-of-month
        if let day = triggerDate.day, triggerDate.weekday == nil {
            let daySuffix: String
            switch day {
            case 1, 21, 31: daySuffix = "st"
            case 2, 22: daySuffix = "nd"
            case 3, 23: daySuffix = "rd"
            default: daySuffix = "th"
            }
            return "On the \(day)\(daySuffix) day of the month at \(formattedTime)"
        }

        // For monthly schedules by weekday ordinal
        if let weekdayOrdinal = triggerDate.weekdayOrdinal, let weekday = triggerDate.weekday {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let weekdayName = formatter.weekdaySymbols[weekday - 1]

            let ordinalStrings = ["first", "second", "third", "fourth", "fifth", "last"]
            let ordinalDescription = ordinalStrings[abs(weekdayOrdinal) - 1]

            return "On the \(ordinalDescription) \(weekdayName) of the month at \(formattedTime)"
        }

        return "Unrecognized schedule"
    }

    enum NotificationError: Error {
        case notFound
        case invalidData
    }
}
