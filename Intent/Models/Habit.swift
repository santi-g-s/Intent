//
//  Habit.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 12/11/2022.
//

import Foundation
import CoreData

extension Habit {
    
    var title: String {
        return title_ ?? "Unknown"
    }
    
    var completedDates: [Date] {
        get {
            return completedDates_ ?? [Date]()
        }
        set {
            return completedDates_ = newValue
        }
    }
    
    var startDate: Date {
        return startDate_ ?? Date()
    }
    
    //MARK: - Convenience Variables
    
    var isComplete: Bool {
        completed[0]
    }
    
    var dateStartedDescription: String? {
        
        let numDays = Calendar.current.numberOfDaysBetween(startDate, and: Date())
        
        var str = "Started \(numDays) day" // Progressing for
        
        if numDays != 1 {
            str += "s"
        }
        
        str += " ago"
        
        return str
    }
    
    func complete() {
        if !isComplete {
            completedDates.append(Date())
        }  else {
            completedDates.removeLast()
        }
    }
    
    var score: CGFloat {
        
        var score = 0.0
        
        for i in stride(from: completed.count-1, through: 0, by: -1) {
            if i == 0 {
                score = completed[i] ? min(score + 0.1, 1.0): score
            } else {
                score = completed[i] ? min(score + 0.1, 1.0): max(0, score - 0.2)
            }
            
        }
        
        return score
    }
    
    /**
     Array that contains a boolean value whether habit was completed on that day starting from that day (0) and going to 19 days earlier at most.
     
     If habit has
     */
    var completed: [Bool] {
        var arr = [Bool]()
        
        let days = Calendar.current.numberOfDaysInclusive(startDate, and: Date())
        
        let upperLimit = days > 20 ? 19 : days - 1
        
        for i in 0...upperLimit {
            let double: Double = Double(i)
            if completedDates.contains(where: { date in
                Calendar.current.compare(date, to: Calendar.current.startOfDay(for: Date()).addingTimeInterval(-60*60*24*(double)), toGranularity: .day) == .orderedSame
            }) {
                arr.append(true)
            } else {
                arr.append(false)
            }
        }
        
        return arr
    }
    
    //MARK: - Static Methods
    
    /// A Moment for use with canvas previews.
    static var preview: Habit {
        let habits = Habit.makePreviews(count: 1, includeAll: true)
        let habit = habits[0]
        return habit
    }
    
    /// Creates mock data for previews.
    @discardableResult
    static func makePreviews(count: Int, includeAll: Bool = false, context: NSManagedObjectContext? = nil) -> [Habit] {
        var habits = [Habit]()
        let viewContext = context ?? DataManager.preview.container.viewContext
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
            habits.append(habit)
        }
        return habits
    }
    
}
