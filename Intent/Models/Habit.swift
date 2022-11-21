//
//  Habit.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 12/11/2022.
//

import Foundation
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
    
    /**
     The score of the habit from `0.0` to `1.0`
     */
    var score: Double {
        get {
            return score_
        }
        set {
            score_ = newValue
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
            
            if !Calendar.current.isDate(last, inSameDayAs: Date()) {
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
    var dateStartedDescription: String? {
        
        let numDays = Calendar.current.numberOfDaysBetween(startDate, and: Date())
        
        guard numDays != 0 else { return "Started today" }
        
        var str = "Started \(numDays) day"
        
        if numDays != 1 {
            str += "s"
        }
        
        str += " ago"
        
        return str
    }
    
    //MARK: - Object Methods
    
    /**
     Call this method to cycle through the completion of the habit.
     
     Note, this is the only place where `score` gets changed.
     */
    func complete() {
        switch status {
        case .complete:
            while let last = completedDates.last, Calendar.current.isDate(last, inSameDayAs: Date()) {
                completedDates.removeLast()
            }
            score = max(0, score - 0.1)
        case .pending(let count):
            completedDates.append(Date())
            if count + 1 == requiredCount {
                score = min(1, score + 0.1/Double(requiredCount)).rounded(toPlaces: 1)
            } else {
                score = min(1, score + 0.1/Double(requiredCount))
            }
            
        }
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
                Date().addingTimeInterval(-60*60*(24)*1*1),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*3)
            ]
            habit.startDate_ = Date().addingTimeInterval(-60*60*(24)*1*10)
            habit.score_ = 0.3
            habit.requiredCount_ = 3
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
