//
//  IntentHandler.swift
//  HabitProgressIntentExtension
//
//  Created by Santiago Garcia Santos on 21/12/2023.
//

import Intents

class IntentHandler: INExtension, HabitProgressIntentHandling {
    var dataManager = DataManager.shared
    
    func provideHabitOptionsCollection(for intent: HabitProgressIntent, with completion: @escaping (INObjectCollection<HabitObject>?, Error?) -> Void) {
        let habits = dataManager.getAllHabits().map { h in
            HabitObject(identifier: h.id?.uuidString, display: h.title)
        }
        
        let collection = INObjectCollection(items: habits)
        completion(collection, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
}
