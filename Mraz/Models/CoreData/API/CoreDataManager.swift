//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
/// Core Data Stack - This class holds the Persistent Container and the Managed Object Context for the Core Data Model.
/// The save context functionality is also in this class.

typealias CoreDataAPI = ReadFromCoreData & WriteToCoreData
typealias CoreDataFetchRequestFor = NSFetchRequest<NSFetchRequestResult>

final class CoreDataManager: CoreDataAPI {
    //MARK: - Core Data Stack
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
        get { return mainThreadContext }
    }
    
    /// Accessible Private Context
    var privateContext: NSManagedObjectContext {
        get { return privateManagedObjectContext }
    }
    
    var beersContainer: NSPersistentContainer {
        get { return persistentContainer }
    }
}

