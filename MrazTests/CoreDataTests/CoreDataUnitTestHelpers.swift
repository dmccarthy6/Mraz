//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreData

class CoreDataUnitTestHelpers {
    // MARK: - Types
    enum CoreDataError: Error {
        case missingContext
        case errorWhileDeleting
        case couldNotCreateFetchReq
        case errorFetchingData
    }
    
    /// Create our in memory Managed Object Context for testing.
    class func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                              configurationName: nil,
                                                              at: nil,
                                                              options: nil)
        } catch {
            fatalError("CoreDataUnitTestHelpers = Adding in-memory persistent store failed")
        }
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
//        //
//        let textObject = ExampleObject(context: context)
//        context.delete(textObject)
//
//        do {
//            try context.save()
//        } catch {
//            fatalError(CoreDataError.missingContext.localizedDescription)
//        }
        return context
    }
    
    /// Delete Objects from the in memory context passed in.
    class func deleteAllObjects<T: NSManagedObject>(objectType: T.Type, with context: NSManagedObjectContext) throws {
        guard let deleteObjectsFetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else {
            throw CoreDataError.couldNotCreateFetchReq
        }
        
        do {
            let fetchResults = try context.fetch(deleteObjectsFetchRequest)
            print("Found \(fetchResults.count) objects of type \(T.description())")
            fetchResults.forEach { (managedObject) in
                context.delete(managedObject)
            }
            try context.save()
        } catch {
            throw CoreDataError.couldNotCreateFetchReq
        }
    }
    
    class func fetchObjects<T: NSManagedObject>(in context: NSManagedObjectContext, sortedBy: String?, ascending: Bool?) throws -> [T] {
        guard let fetchObjectsRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else {
            throw CoreDataError.couldNotCreateFetchReq
        }
        if let sortedBy = sortedBy, let ascending = ascending {
            let sortDescriptor = [NSSortDescriptor(key: sortedBy, ascending: ascending)]
            fetchObjectsRequest.sortDescriptors = sortDescriptor
        }
        do {
            let results = try context.fetch(fetchObjectsRequest)
            return results
        } catch {
            throw CoreDataError.errorFetchingData
        }
    }
    
    class func createTestObject() throws {
        
    }
}
