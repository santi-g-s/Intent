//
//  IntentHandler.swift
//  HabitIntentExtension
//
//  Created by Santiago Garcia Santos on 20/11/2023.
//

import Intents

class IntentHandler: INExtension, HabitProgressIntentHandling {
    #if targetEnvironment(simulator)
    var dataManager = DataManager.shared
    #else
    var dataManager = DataManager.shared
    #endif
    
    func provideHabitOptionsCollection(for intent: HabitProgressIntent, with completion: @escaping (INObjectCollection<HabitObject>?, Error?) -> Void) {
        let habits = dataManager.getAllHabits().map { habit in
            let habitObject = HabitObject(identifier: habit.id?.uuidString, display: habit.title)
            habitObject.score = (habit.calculateScore()) as NSNumber
            habitObject.streak = (habit.streakDescriptionsNumDays ?? 0) as NSNumber
            habitObject.timePeriod = habit.timePeriod.rawValue as NSNumber
            habitObject.accentColor = habit.accentColor.toHex() ?? ""
            return habitObject
            
        }
        let collection = INObjectCollection(items: habits)
        completion(collection, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
