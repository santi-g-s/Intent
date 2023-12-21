//
//  IntentHandler.swift
//  HabitProgressIntentExtension
//
//  Created by Santiago Garcia Santos on 21/12/2023.
//

import Intents

class IntentHandler: INExtension, HabitProgressIntentHandling {
    
    var dataManager = DataManager.shared
    
    
    func provideHabitIDOptionsCollection(for intent: HabitProgressIntent, with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
        
        let habits = dataManager.getAllHabits().compactMap { h in
            if let idString = h.id?.uuidString {
                return idString as NSString
            }
            return nil
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
