//  Created by Dylan  on 9/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import os.log

enum StorageType {
    case persistent, inMemory
}

final class CoreDataStore {
    // MARK: - Properties
    let coreDataLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: CoreDataStore.self))
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        return NSPersistentContainer(name: "Mraz")
    }()
    
    let storageType: StorageType
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    // MARK: - Lifecycle
    init(_ storageType: StorageType = .persistent) {
        self.storageType = storageType
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundContextDidSave(notification:)), name: .NSManagedObjectContextDidSave, object: nil)
        
        prepare()
    }
    
    public func prepare() {
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                os_log("Error loading persistent stores %@, %@", log: self.coreDataLog, type: .error, error, error.userInfo)
                fatalError("Unresolved error loading persistent store \(error), \(error.userInfo)")
            }
            os_log("Successfully created Persistent Container %@", log: self.coreDataLog, type: .debug, self.persistentContainer)
        }
        context.automaticallyMergesChangesFromParent = true
    }
    
    func performBackgroundTask(block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    @objc func backgroundContextDidSave(notification: Notification) {
        guard let notificationContext = notification.object as? NSManagedObjectContext else { return }
        
        guard notificationContext !== context else {
            return
        }
        
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }

    /// Create and return a new background context
    public func newDerivedContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
 
    // MARK: - Deleting
    func batchDelete() {
        persistentContainer.performBackgroundTask {[weak self] (privateMOC) in
            guard let self = self else { return }
            
            let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
            let predicate = NSPredicate(value: true)
            fetchRequest.predicate = predicate
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let result = try privateMOC.execute(deleteRequest) as? NSBatchDeleteResult
                guard let deletedIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: deletedIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.context])
            } catch {
                fatalError("WriteToCD -- Failed to batch delete: \(error.localizedDescription)")
            }
        }
    }
}
