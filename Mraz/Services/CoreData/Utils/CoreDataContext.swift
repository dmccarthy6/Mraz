//  Created by Dylan  on 10/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import os.log

//final class CoreDataStack {
//    // MARK: - Properties
//    static let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: CoreDataStack.self))
//    
//    static var coreDataStore: CoreDataStore = {
//        return CoreDataStore()
//    }()
//    
//    /// Main thread ManagedObjectContext
//    static var mainContext: NSManagedObjectContext = {
//        let mainContext = coreDataStore.persistentContainer.viewContext
//        mainContext.automaticallyMergesChangesFromParent = true
//        return mainContext
//    }()
//    
//    /// Private ManagedObjectContext (background thread)
//    static var privateContext: NSManagedObjectContext = {
//        let privContext = coreDataStore.persistentContainer.newBackgroundContext()
//        privContext.parent = mainContext
//        return privContext
//    }()
//    
//    // MARK: -
//    static func save(_ context: NSManagedObjectContext) {
//        if mainContext.hasChanges {
//            do {
//                try mainContext.save()
//            } catch {
//                os_log("Err %@", log: mrazLog, type: .debug, error.localizedDescription)
//                fatalError("CoreDataStack -- Error saving to main context")
//            }
//        }
//    }
//}
