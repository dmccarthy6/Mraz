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
    public lazy var mainThreadContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    public lazy var privateContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }()
    
    /// Create and return a new background context
    public func newDerivedContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Saving Contexts
    public func save(_ context: NSManagedObjectContext) {
        do {
            
            try mainThreadContext.save()
            
        } catch {
            os_log("Err %@", log: coreDataLog, type: .debug, error.localizedDescription)
            fatalError("CoreDataStack -- Error saving to main context")
        }
    }
}
