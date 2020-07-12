//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit
/// Core Data Stack - This class holds the Persistent Container and the Managed Object Context for the Core Data Model.
/// The save context functionality is also in this class.

typealias CoreDataAPI = ReadFromCoreData & WriteToCoreData
typealias CoreDataFetchRequestFor = NSFetchRequest<NSFetchRequestResult>

final class CoreDataManager: CoreDataAPI {
    // MARK: - Core Data Stack
    static let sharedDatabase = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Mraz")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("CoreDataManager = Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
   // @available(iOS 14.0, *)
//    private lazy var syncPersistentContainer: NSPersistentCloudKitContainer = {
//        let container = NSPersistentCloudKitContainer(name: "Mraz")
//
//        guard let description = container.persistentStoreDescriptions.first else {
//            fatalError("Error - CK")
//        }
//        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//        description.cloudKitContainerOptions!.databaseScope = .public
//        container.persistentStoreDescriptions.append(description)
//
////        let description = NSPersistentStoreDescription()
////        let publicStoreURL = description.url!.deletingLastPathComponent()
////            .appendingPathComponent("Mraz.sqlite")
////        let identifier = description.cloudKitContainerOptions!.containerIdentifier
////
////        let publicDescription = NSPersistentStoreDescription(url: publicStoreURL)
////        publicDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
////        publicDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
////
////        var publicOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
////        publicOptions.databaseScope = .public
////
////        publicDescription.cloudKitContainerOptions = publicOptions
////        container.persistentStoreDescriptions.append(publicDescription)
////
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("CoreDataManager = Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
    
    /// Managed Object Context
    private lazy var mainThreadContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        return context
    }()
    
}

extension CoreDataManager {
    /// Accessable Main Thread Context
    var managedObjectContext: NSManagedObjectContext {
        return mainThreadContext
    }
    
    /// Accessible Private Context
    var privateContext: NSManagedObjectContext {
        return privateManagedObjectContext
    }
    
    var beersContainer: NSPersistentContainer {
        return persistentContainer
    }
}
