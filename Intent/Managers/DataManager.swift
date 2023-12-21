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

enum AppGroup: String {
    case group = "group.com.sumone.Intent"

    public var containerURL: URL {
        switch self {
        case .group:
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: rawValue)!
        }
    }
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

        if storeType == .inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            print("📓 Using in-memory Core Data Store")
        } else {
            let storeURL = AppGroup.group.containerURL.appendingPathComponent("CoreDataModel.sqlite")
            container.persistentStoreDescriptions.first!.url = storeURL
            print("🤝 Using Shared App Group Core Data Store")
        }

        container.loadPersistentStores(completionHandler: { _, error in

            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })

        migrateCoreDataIfNecessary()
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

extension DataManager {
    private func migrateCoreDataIfNecessary() {
        do {
            guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last, let backupURL = URL(string: "DataBackup.sqlite", relativeTo: dirURL) else {
                return
            }

            let newStoreURL = AppGroup.group.containerURL.appendingPathComponent("CoreDataModel.sqlite")

            if !UserDefaults.standard.bool(forKey: "didMigrateStoreURL") {
                try container.copyPersistentStores(to: backupURL, overwriting: true)
                try container.restorePersistentStore(from: backupURL, migrateTo: newStoreURL)
                print("🧳 Core Data Store URL Migration: Successful")
                UserDefaults.standard.set(true, forKey: "didMigrateStoreURL")
            }
        } catch {
            print(error)
        }
    }
}
