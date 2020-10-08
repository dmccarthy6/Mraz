//  Created by Dylan  on 9/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

final class CoreDataStack {
    // MARK: - Properties
    static var sharedStack = CoreDataStack()
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Mraz")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("CoreDataManager = Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Managed Object Contexts
    lazy var mainThreadContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        return context
    }()
}
