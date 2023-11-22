//
//  DataManager.swift
//  Gentle
//
//  Created by Santiago Garcia Santos on 12/11/2022.
//

import CoreData
import WidgetKit

enum StorageType {
    case persistent, inMemory
}

// I'm using a subclass so the persistent container will look for the data model in the framework bundle rather than the app bundle
public class PersistentContainer: NSPersistentContainer {}

class DataManager {
    static let shared: DataManager = .init()

    static let preview: DataManager = {
        let manager = DataManager(.inMemory)
        let habits = Habit.makeRichPreviews(count: 5, context: manager.container.viewContext)
        return manager
    }()

    static let testing: DataManager = .init(.inMemory)

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

        // Check if the migration is necessary or has been done
        if !UserDefaults.standard.bool(forKey: "isDBLocationMigrated") && storeType != .inMemory {
            print("Migrating CoreData store...")
            migrateCoreDataIfNeeded()
        }

        // Set the store URL to either in-memory or App Group
        if storeType == .inMemory {
            print("Using in-memory store")
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            print("Using App Group store")
            let storeURL = AppGroup.group.containerURL.appendingPathComponent("CoreDataModel.sqlite")
            container.persistentStoreDescriptions.first!.url = storeURL
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        }
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
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func getAllHabits() -> [Habit] {
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("can't fetch")
            return []
        }
    }
}

enum AppGroup: String {
  case group = "group.come.sumone.Intent"

  public var containerURL: URL {
    switch self {
    case .group:
      return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: self.rawValue)!
    }
  }
}

extension DataManager {
    func migrateCoreDataIfNeeded() {
        // Define the old and new store URLs
        let oldStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("CoreDataModel.sqlite")
        let newStoreURL = AppGroup.group.containerURL.appendingPathComponent("CoreDataModel.sqlite")

        if !UserDefaults.standard.bool(forKey: "isDBLocationMigrated") {
            do {
                // Perform migration
                let coordinator = container.persistentStoreCoordinator
                if let oldStore = coordinator.persistentStore(for: oldStoreURL) {
                    try coordinator.migratePersistentStore(oldStore, to: newStoreURL, options: nil, withType: NSSQLiteStoreType)
                }
                UserDefaults.standard.set(true, forKey: "isDBLocationMigrated") // Mark as migrated
            } catch {
                print("Migration error: \(error)")
            }
        }

    }
}
