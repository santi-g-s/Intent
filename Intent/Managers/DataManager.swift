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
        let habits = Habit.makePreviews(count: 16, context: manager.container.viewContext)
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
    
    static func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?, context: NSManagedObjectContext) -> Result<T?, Error> {
        let request = objectType.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request) as? [T]
            return .success(result?.first)
        } catch {
            return .failure(error)
        }
    }
    
    static func count<T: NSManagedObject>(_ objectType: T.Type, context: NSManagedObjectContext) -> Result<Int?, Error> {
        let request = objectType.fetchRequest()
        do {
            let result = try context.fetch(request) as? [T]
            return .success(result?.count)
        } catch {
            return .failure(error)
        }
    }
    
    func saveData() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
            }
        }
    }
}
