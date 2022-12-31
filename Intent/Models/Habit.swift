//
//  Habit.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 12/11/2022.
//

import SwiftUI
import CoreData

extension Habit {
    
    /**
     The title of the habit.
     */
    var title: String {
        get {
            return title_ ?? "Unknown"
        }
        set {
            title_ = newValue
        }
    }
    
    /**
     The array of messages associated with this habit
     */
    var messages: [String] {
        get {
            return messages_ ?? [String]()
        }
        set {
            messages_ = newValue
        }
    }
    
    /**
     An array respresented the `Date` when a habit was succesfully completed. First index is the oldest date.
     
     Note that this can can contain multiple dates on the same day representing a task that must be completed multiple times in a day.
     */
    var completedDates: [Date] {
        get {
            return completedDates_ ?? [Date]()
        }
        set {
            completedDates_ = newValue
        }
    }
    
    /**
     The date when the habit was started.
     */
    var startDate: Date {
        get {
            return startDate_ ?? Date()
        }
        set {
            startDate_ = newValue
        }
    }
    
    var timePeriod: TimePeriod {
        get {
            return TimePeriod(rawValue: Int(period_)) ?? .daily
        }
        set {
            period_ = Int16(newValue.rawValue)
        }
    }
    
    /**
     The accent color associated with this habit
     */
    var accentColor: Color {
        get {
            if let data = accentColor_, let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data){
                return Color(uiColor: uiColor)
            }
            return Color.accentColor
        }
        set {
            accentColor_ = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(newValue), requiringSecureCoding: false)
        }
    }
    
    /**
     The number of completions needed in a day to "complete'" the habit
     */
    var requiredCount: Int {
        get {
            return Int(requiredCount_)
        }
        set {
            requiredCount_ = Int16(newValue)
        }
    }
    
    var iconName: String {
        get {
            return iconName_ ?? "circle"
        }
        set {
            iconName_ = newValue
        }
    }
    
    //MARK: - Convenience Variables
    
    /**
     Represents the current status of the habit. Can be either `complete` or `pending` with an associated int for the current count.
     */
    var status: HabitStatus {
        var count = 0
        var dates = completedDates
        
        guard !dates.isEmpty else { return .pending(0) }
        
        while count < requiredCount {
            
            guard let last = dates.last else { return .pending(count) }
            
            if !Calendar.current.isDate(last, inSame: timePeriod.component, as: Date()) {
                return .pending(count)
            }
            dates.removeLast()
            count += 1
        }
        
        return .complete
    }
    
    /**
     A string that describes how long ago the habit was started.
     */
    var dateStartedDescription: LocalizedStringKey? {
        
        let end = status == .complete ? Date() : Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let numDays = Calendar.current.numberOfInclusive(component: timePeriod.component, from: dateLastAtZero, and: end)
        
        let str: LocalizedStringKey = "**\(numDays)** \(timePeriod.unitName) streak"
        
        return str
    }
    
    var dateLastAtZero: Date {
        var lastDate = startDate
        var score = 0.0
        var trackerIndex: Int = 0
        for date in Calendar.current.dates(from: startDate, through: Date(), steppingBy: timePeriod.component) {
            
            // Reduce score for each date not in `completedDates`
            if trackerIndex < completedDates.count, Calendar.current.compare(date, to: completedDates[trackerIndex], toGranularity: timePeriod.component) == .orderedAscending {
                score = max(0, score - 0.2)
                if score < 0.1 {
                    lastDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
                }
                continue
            } else if trackerIndex >= completedDates.count && Calendar.current.compare(date, to: Date(), toGranularity: timePeriod.component) != .orderedSame {
                // If you reach the end of completedDates then reduce score until today.
                score = max(0, score - 0.2)
            }
            
            var count = 0
            
            // Once you reach a date that is in completed date, increase the count and move on to the next index for each date in the specified period
            while trackerIndex < completedDates.count, Calendar.current.compare(date, to: completedDates[trackerIndex], toGranularity: timePeriod.component) == .orderedSame {
                trackerIndex += 1
                count += 1
            }
            
            // Check if reached requirement and if so, increase score
            if count == requiredCount {
                score = min(1, score + 0.1)
            } else if Calendar.current.compare(date, to: Date(), toGranularity: timePeriod.component) == .orderedSame {
                // Otherwise if today, then add incremental score
                score = min(1, score + 0.1 / Double(requiredCount) * Double(count))
            }
            
            if score < 0.1 {
                lastDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            }
            
        }
        
        return lastDate
    }
    
    //MARK: - Object Methods
    
    /**
     Call this method to cycle through the completion of the habit.
     
     Note, this is the only place where `score` gets changed.
     */
    func complete() {
        switch status {
        case .complete:
            while let last = completedDates.last, Calendar.current.isDate(last, inSame: timePeriod.component, as: Date()) {
                completedDates.removeLast()
            }
        case .pending(_):
            completedDates.append(Date())
        }
    }
    
    /**
     Returns the score of the habit from `0.0` to `1.0`
     */
    func calculateScore() -> Double {
        var score = 0.0
        var trackerIndex: Int = 0
        for date in Calendar.current.dates(from: startDate, through: Date(), steppingBy: timePeriod.component) {
            
            // Reduce score for each date not in `completedDates`
            if trackerIndex < completedDates.count, Calendar.current.compare(date, to: completedDates[trackerIndex], toGranularity: timePeriod.component) == .orderedAscending {
                score = max(0, score - 0.2)
                continue
            } else if trackerIndex >= completedDates.count && Calendar.current.compare(date, to: Date(), toGranularity: timePeriod.component) != .orderedSame {
                // If you reach the end of completedDates then reduce score until today.
                score = max(0, score - 0.2)
            }
            
            var count = 0
            
            // Once you reach a date that is in completed date, increase the count and move on to the next index for each date in the specified period
            while trackerIndex < completedDates.count, Calendar.current.compare(date, to: completedDates[trackerIndex], toGranularity: timePeriod.component) == .orderedSame {
                trackerIndex += 1
                count += 1
            }
            
            // Check if reached requirement and if so, increase score
            if count >= requiredCount {
                score = min(1, score + 0.1)
            } else if Calendar.current.compare(date, to: Date(), toGranularity: timePeriod.component) == .orderedSame {
                // Otherwise if today, then add incremental score
                score = min(1, score + 0.1 / Double(requiredCount) * Double(count))
            }
            
        }
        
        return score
    }
    
    func calculateCompletionMap() -> [Date : Bool] {
        var completionMap = [Date: Bool]()
        var countMap = [Date: Int]()
        for date in Calendar.current.dates(from: startDate, through: Date(), steppingBy: .day) {
            countMap[Calendar.current.standardizedDate(date)] = 0
        }
        for date in completedDates {
            countMap[Calendar.current.standardizedDate(date)]! += 1
        }
        
        for entry in countMap {
            completionMap[entry.key] = entry.value >= requiredCount ? true : false
        }
        return completionMap
    }
    
    //MARK: - Static Methods
    
    /// A Habit for use with canvas previews.
    static func makePreview(context: NSManagedObjectContext) -> Habit {
        let habits = Habit.makePreviews(count: 1, includeAll: true, context: context)
        let habit = habits[0]
        return habit
    }
    
    /// Creates mock data for previews.
    @discardableResult
    static func makePreviews(count: Int, includeAll: Bool = false, context: NSManagedObjectContext) -> [Habit] {
        var habits = [Habit]()
        let viewContext = context
        for i in 0..<count {
            let habit = Habit(context: viewContext)
            habit.id = UUID()
            habit.title_ = "Example Habit \(i)"
            habit.completedDates_ = [
                Date().addingTimeInterval(-60*60*(24)*1*10),// 10 days ago
                Date().addingTimeInterval(-60*60*(24)*1*3),
                Date().addingTimeInterval(-60*60*(24)*1*3),
                Date().addingTimeInterval(-60*60*(24)*1*3),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*1),
                Date().addingTimeInterval(-60*60*(24)*1*1),
                Date().addingTimeInterval(-60*60*(24)*1*1)
            ]
            habit.startDate_ = Date().addingTimeInterval(-60*60*(24)*1*10)
            habit.requiredCount = 3
            habit.timePeriod = .daily
            habit.messages_ = ["Remember why you are doing this", "It's the foundation for your happiness"]
            habit.iconName_ = ["figure.run", "book", "star", "paintbrush.pointed", "tennis.racket", "powersleep", "drop", "lamp.table"].randomElement()
            habit.accentColor = Color.random()
            habits.append(habit)
        }
        return habits
    }
    
}

enum HabitStatus: Equatable {
    case complete
    case pending(Int)
    
    var description: String {
        switch self {
        case .complete:
            return "Complete"
        case .pending(let count):
            return "Pending: \(count)"
        }
    }
}

enum TimePeriod: Int {
    case daily = 0
    case weekly = 1
    case monthly = 2
    
    var unitName: String {
        switch self {
        case .daily:
            return "day"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        }
    }
    
    var component: Calendar.Component {
        switch self {
        case .daily:
            return .day
        case .weekly:
            return .weekOfYear
        case .monthly:
            return .month
        }
    }
}
