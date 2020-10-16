//  Created by Dylan  on 9/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import os.log

enum StorageType {
    case persistent, inMemory
}

final class CoreDataStore {
    // MARK: - Properties
    let coreDataLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: SyncContainer.self))
    let persistentContainer: NSPersistentContainer
    
    // MARK: - Lifecycle
    init(_ storageType: StorageType = .persistent) {
        self.persistentContainer = NSPersistentContainer(name: "Mraz")
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        self.persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                os_log("Error loading persistent stores %@, %@", log: self.coreDataLog, type: .error, error, error.userInfo)
                fatalError("Unresolved error loading persistent store \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Managed Object Contexts
    lazy var mainThreadContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.parent = mainThreadContext
        return context
    }()
}
