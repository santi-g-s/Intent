//
//  DataManager.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 12/11/2022.
//

import CoreData

enum StorageType {
  case persistent, inMemory
}

// I'm using a subclass so the persistent container will look for the data model in the framework bundle rather than the app bundle
public class PersistentContainer: NSPersistentContainer {}

class DataManager {
    
    static let shared: DataManager = DataManager()
    
    static let preview: DataManager = {
        let manager = DataManager(.inMemory)
        let people = Habit.makePreviews(count: 10, context: manager.container.viewContext)
        return manager
    }()
    
    static let testing: DataManager = DataManager(.inMemory)
    
    static var managedObjectModel: NSManagedObjectModel = {
      let bundle = Bundle(for: DataManager.self)

      guard let url = bundle.url(forResource: "CoreDataModel", withExtension: "momd") else {
        fatalError("Failed to locate momd file for CoreDataModel")
      }

      guard let model = NSManagedObjectModel(contentsOf: url) else {
        fatalError("Failed to load momd file for CoreDataModel")
      }

      return model
    }()

    public let container: PersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    public init(_ storeType: StorageType = .persistent) {
      container = PersistentContainer(name: "CoreDataModel", managedObjectModel: Self.managedObjectModel)

      if storeType == .inMemory {
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
      }

      container.loadPersistentStores(completionHandler: { description, error in

        if let error = error {
          fatalError("Core Data store failed to load with error: \(error)")
        }
      })
    }
}
