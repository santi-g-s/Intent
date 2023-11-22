//
//  Habit.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 12/11/2022.
//

import CoreData
import SwiftUI
import WidgetKit


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
     Identifiers pertaining to scheduled notifications associated with this habit
     */
    var notificationIdentifiers: [String] {
        get {
            return notificationIdentifiers_ ?? [String]()
        }
        set {
            notificationIdentifiers_ = newValue
        }
    }
    
    /**
     The accent color associated with this habit
     */
    var accentColor: Color {
        get {
            if let data = accentColor_, let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
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
    
    var order: Int {
        get {
            return Int(order_)
        }
        set {
            order_ = Int16(newValue)
        }
    }
    
    var completionType: CompletionType {
        get {
            return CompletionType(rawValue: Int(completionType_)) ?? .equalTo
        }
        set {
            completionType_ = Int16(newValue.rawValue)
        }
    }
    
    // MARK: - Convenience Variables
    
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
    
    var completionsInPeriod: Int {
        var count = 0
        
        var dates = completedDates
        
        while let lastDate = dates.last, Calendar.current.isDate(lastDate, inSame: timePeriod.component, as: Date()) {
            count += 1
            dates.removeLast()
        }
        
        return count
    }
    
    /**
     A string that describes how long ago the habit streak was kept alive.
     */
    var streakDescription: AttributedString? {
        let end = status == .complete ? Date() : Calendar.current.date(byAdding: timePeriod.component, value: -1, to: Date())!
        
        let numDays = max(0, Calendar.current.numberOfInclusive(component: timePeriod.component, from: startOfMostRecentStreak, and: end))
        
        let str: AttributedString? = try? AttributedString(markdown: "**\(numDays)** \(timePeriod.unitName) streak")
        
        return str
    }
    
    var leadingStreakDescription: String? {
        return "You're on a"
    }
    
    var streakDescriptionsNumDays: Int? {
        let end = status == .complete ? Date() : Calendar.current.date(byAdding: timePeriod.component, value: -1, to: Date())!
        
        let numDays = max(0, Calendar.current.numberOfInclusive(component: timePeriod.component, from: startOfMostRecentStreak, and: end))
        
        return numDays
    }
    
    var trailingStreakDescription: String? {
        return "\(timePeriod.unitName) streak"
    }
    
    var scheduleDescription: AttributedString {
        var count = ""
        
        switch requiredCount {
        case 1:
            count = "Once"
        case 2:
            count = "Twice"
        default:
            count = "\(requiredCount) times"
        }
        
        let str: AttributedString = try! AttributedString(markdown: "Schedule: **\(count) a \(timePeriod.unitName)**")
        
        return str
    }
    
    /**
     Calculates the last date when the habit's score most recently went from 0 to a value greater than 0, incdicating the start of the most recent streak
     
     - Returns: The first date (corresponding to a completion of a task) of the most recent streak
     */
    var startOfMostRecentStreak: Date {
        var lastDate = startDate
        var score = 0.0
        var prevScore = 0.0
        var trackerIndex = 0
        
        // Iterate through each date from the startDate to today
        for date in Calendar.current.dates(from: startDate, through: Date(), steppingBy: timePeriod.component) {
            // Count how many times the habit was completed on the current date
            var count = 0
            while trackerIndex < completedDates.count, Calendar.current.compare(date, to: completedDates[trackerIndex], toGranularity: timePeriod.component) == .orderedSame {
                trackerIndex += 1
                count += 1
            }
            
            // Check if the habit was completed enough times on the current date
            if count >= requiredCount {
                // The habit was completed, so increment the score (up to a maximum of 1)
                score = min(1, score + 0.1)
            } else if Calendar.current.compare(date, to: Date(), toGranularity: timePeriod.component) == .orderedSame {
                // For today, add incremental score proportional to the fraction of requiredCount that was met
                score = min(1, score + 0.1 / Double(requiredCount)*Double(count))
            } else {
                // The habit was not completed, so decrement the score (down to a minimum of 0)
                score = max(0, score - 0.2)
            }
            
            // Check if the score was 0 before and is now greater than 0
            if prevScore == 0.0 && score > 0.0 {
                lastDate = date
            }
            
            // Store the previous score
            prevScore = score
        }
        
        // If the score is 0 at the end of the loop (or less than 0.1 for Date()), return the current date
        if score < 0.1 {
            return Date()
        }
        
        return lastDate
    }

    // MARK: - Object Methods
    
    /**
     Call this method to cycle through the completion of the habit.
     
     Note, this is the only place where `score` gets changed.
     */
    func complete() {
        completedDates.append(Date())
    }
    
    func addCompletion(on date: Date) {
        if date < startDate {
            startDate = date
        }
        completedDates.insertInOrder(date)
    }
    
    func removeCompletion(on date: Date) {
        if let targetIndex = completedDates.firstIndex(where: { d in
            Calendar.current.isDate(d, inSameDayAs: date)
        }) {
            completedDates.remove(at: targetIndex)
        }
    }
    
    func hasCompletion(on date: Date) -> Bool {
        return completedDates.firstIndex { d in
            Calendar.current.isDate(d, inSameDayAs: date)
        } != nil
    }
    
    func revertCompletion() {
        if let last = completedDates.last, Calendar.current.isDate(last, inSame: timePeriod.component, as: Date()) {
            completedDates.removeLast()
        }
    }
    
    /**
     Returns the score of the habit from `0.0` to `1.0`
     */
    func calculateScore() -> Double {
        var score = 0.0
        var trackerIndex = 0
        
        let allDates = Calendar.current.dates(from: startDate,
                                              through: Date(),
                                              steppingBy: timePeriod.component)
        
        for date in allDates {
            // Extracted the comparison into a variable for clarity
            let isDateEarlierThanCompleted = trackerIndex < completedDates.count &&
                Calendar.current.compare(date,
                                         to: completedDates[trackerIndex],
                                         toGranularity: timePeriod.component) == .orderedAscending
            
            let isBeyondCompletedDates = trackerIndex >= completedDates.count &&
                Calendar.current.compare(date,
                                         to: Date(),
                                         toGranularity: timePeriod.component) != .orderedSame

            // Handle scenarios where score should be reduced
            if isDateEarlierThanCompleted || isBeyondCompletedDates {
                score = max(0, score - 0.2)
                continue
            }
            
            // Count completed dates
            var count = 0
            while trackerIndex < completedDates.count,
                  Calendar.current.compare(date,
                                           to: completedDates[trackerIndex],
                                           toGranularity: timePeriod.component) == .orderedSame
            {
                trackerIndex += 1
                count += 1
            }
            
            // Handle scenarios where score should be increased
            let isToday = Calendar.current.compare(date, to: Date(), toGranularity: timePeriod.component) == .orderedSame
            let requirementReached = count >= requiredCount
            
            if requirementReached {
                score = min(1, score + 0.1)
            } else if isToday {
                score = min(1, score + (0.1 / Double(requiredCount))*Double(count))
            } else {
                score = max(0, score - 0.2)
            }
        }
        
        return score
    }

    func calculateCompletionMap() -> [Date: Int] {
        var countMap = [Date: Int]()
        for date in Calendar.current.dates(from: startDate, through: Date(), steppingBy: .day) {
            countMap[Calendar.current.standardizedDate(date)] = 0
        }
        for date in completedDates {
            countMap[Calendar.current.standardizedDate(date)]! += 1
        }
        
        return countMap
    }
    
    private func update(with data: HabitData) {
        title = data.title
        startDate = data.startDate
        timePeriod = data.timePeriod
        requiredCount = data.requiredCount
        accentColor = data.accentColor
        iconName = data.iconName
        messages = data.messages
        completionType = data.completionType
        notificationIdentifiers = data.notificationIdentifiers
    }
    
    // MARK: - Static Methods
    
    @discardableResult
    static func createHabit(with data: HabitData, context: NSManagedObjectContext) -> Habit {
        let habit = Habit(context: context)
        habit.id = data.id
        
        let result = DataManager.count(Habit.self, context: context)
        
        switch result {
        case .success(let count):
            habit.order = count ?? 0
        case .failure:
            habit.order = 0
        }
        
        habit.update(with: data)
        
        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Couldn't save context", error.localizedDescription)
        }
        
        return habit
    }
    
    static func updateHabit(with data: HabitData, context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id = %@", data.id as CVarArg)
        let result = DataManager.fetchFirst(Habit.self, predicate: predicate, context: context)
        switch result {
        case .success(let habit):
            if let habit = habit {
                habit.update(with: data)
            } else {
                createHabit(with: data, context: context)
            }
        case .failure:
            print("Couldn't fetch Habit to save")
        }
        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Couldn't save context", error.localizedDescription)
        }
    }
    
    static func deleteHabit(with data: HabitData, context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id = %@", data.id as CVarArg)
        let result = DataManager.fetchFirst(Habit.self, predicate: predicate, context: context)
        switch result {
        case .success(let habit):
            if let habit = habit {
                for notificationIdentifier in habit.notificationIdentifiers {
                    if let id = UUID(uuidString: notificationIdentifier) {
                        UserNotificationsManager.deleteNotification(with: id)
                    }
                }
                context.delete(habit)
            } else {
                print("Couldn't find Habit to delete")
            }
        case .failure:
            print("Couldn't fetch Habit to save")
        }
        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Couldn't save context", error.localizedDescription)
        }
    }
    
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
                Date().addingTimeInterval(-60*60*24*1*10), // 10 days ago
                Date().addingTimeInterval(-60*60*24*1*3),
                Date().addingTimeInterval(-60*60*24*1*3),
                Date().addingTimeInterval(-60*60*24*1*3),
                Date().addingTimeInterval(-60*60*24*1*2),
                Date().addingTimeInterval(-60*60*24*1*2),
                Date().addingTimeInterval(-60*60*24*1*2),
                Date().addingTimeInterval(-60*60*24*1*1),
                Date().addingTimeInterval(-60*60*24*1*1),
                Date().addingTimeInterval(-60*60*24*1*1)
            ]
            habit.startDate_ = Date().addingTimeInterval(-60*60*24*1*10)
            habit.requiredCount = 3
            habit.timePeriod = .daily
            habit.order = i
            habit.completionType = .equalTo
            habit.messages_ = ["Remember why you are doing this", "It's the foundation for your happiness"]
            habit.iconName_ = ["figure.run", "book", "star", "paintbrush.pointed", "tennis.racket", "powersleep", "drop", "lamp.table"].randomElement()
            habit.accentColor = Color.random()
            habits.append(habit)
        }
        return habits
    }
    
    @discardableResult
    static func makeRichPreviews(count: Int, includeAll: Bool = false, context: NSManagedObjectContext) -> [Habit] {
        var habits = [Habit]()
        let viewContext = context

        let habitDetails = [
            ("Reading", "book"),
            ("Staying Hydrated", "drop"),
            ("Meditation", "figure.mind.and.body"),
            ("Cold Showers", "shower"),
            ("Strength Training", "figure.strengthtraining.traditional"),
            ("Playing Piano", "music.note"),
            ("Running", "figure.run"),
            ("Swimming", "figure.pool.swim"),
            ("Studying", "lamp.table"),
            ("Cooking", "flame"),
            ("Cycling", "bicycle"),
            ("Sleeping Well", "powersleep"),
            ("Drawing", "paintbrush.pointed"),
            ("Playing Tennis", "tennis.racket"),
            ("Walking", "figure.walk"),
            ("Writing", "pencil"),
            ("Yoga", "person.position")
        ]
        
        let timePeriods: [TimePeriod] = [.daily, .weekly, .monthly]
        let completionTypes: [CompletionType] = [.equalTo, .greaterThan]

        let habitMessages = [
            "Keep pushing",
            "Stay consistent",
            "Remember your goal",
            "You are making progress",
            "Just a little bit every day",
            "Persistence is key",
            "Every little bit counts",
            "Stay focused, stay sharp",
            "The journey is the destination",
            "Make every day count"
        ]

        for i in 0..<count {
            let habit = Habit(context: viewContext)
            habit.id = UUID()
            let habitDetail = habitDetails[i % habitDetails.count]
            habit.title = habitDetail.0
            habit.iconName = habitDetail.1
            
            // Random start date up to 180 days ago
            let startDate = Date().addingTimeInterval(-60*60*24*Double.random(in: 0...180))
            habit.startDate = startDate

            // Generate a random percentage (70-100%) of days between start date and now to be marked as completed
            let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day!
            let numCompletedDates = Int(Double(totalDays)*Double.random(in: 0.7...1.0))
            
            var completedDates: [Date] = []
            for _ in 0..<numCompletedDates {
                // Randomly select a date between start date and now
                let randomTimeInterval = Double.random(in: 0...Double(totalDays))*60*60*24
                let randomDate = startDate.addingTimeInterval(randomTimeInterval)
                
                // Ensure that the same date is not added multiple times
                if !completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: randomDate) }) {
                    completedDates.append(randomDate)
                }
            }
            
            // Sort the completedDates array
            completedDates.sort()
            habit.completedDates = completedDates

            habit.requiredCount = Int.random(in: 1...3)
            habit.timePeriod = timePeriods[i % timePeriods.count]
            habit.order = i
            habit.completionType = completionTypes[i % completionTypes.count]
            habit.messages = Array((0...2).map { _ in habitMessages.randomElement()! })
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

enum CompletionType: Int {
    case equalTo = 1
    case greaterThan = 2
    
    var description: String {
        switch self {
        case .equalTo:
            return "Exactly"
        case .greaterThan:
            return "More than"
        }
    }
}

struct HabitData: Identifiable {
    var id: UUID
    var startDate: Date = .init()
    var title: String = ""
    var timePeriod: TimePeriod = .daily
    var requiredCount: Int = 1
    var accentColor: Color = .accentColor
    var iconName: String = "star"
    var messages = [String]()
    var completionType: CompletionType = .equalTo
    var notificationIdentifiers: [String] = []
    
    init() {
        self.id = UUID()
    }
    
    init(from habit: Habit) {
        self.id = habit.id ?? UUID()
        self.startDate = habit.startDate
        self.title = habit.title
        self.timePeriod = habit.timePeriod
        self.requiredCount = habit.requiredCount
        self.accentColor = habit.accentColor
        self.iconName = habit.iconName
        self.messages = habit.messages
        self.completionType = habit.completionType
        self.notificationIdentifiers = habit.notificationIdentifiers
    }
}
