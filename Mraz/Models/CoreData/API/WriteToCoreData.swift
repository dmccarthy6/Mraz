//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit

protocol WriteToCoreData {
    
}

extension WriteToCoreData {
    //MARK: - Core Data Stack
    var mainThreadContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.managedObjectContext
    }
    
    var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.privateContext
    }
    
    var persistentContainer: NSPersistentContainer {
        return CoreDataManager.sharedDatabase.beersContainer
    }
    
    
    
    
    
    
    
    //MARK: - Saving Methods
    func saveContext() {
        if mainThreadContext.hasChanges || privateContext.hasChanges {
            mainThreadContext.perform {
                do {
                    try self.mainThreadContext.save()
                    self.savePrivateBackgroundContext()
                }
                catch {
                    fatalError("WriteToCD - Error saving CD: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Saving background context
    func savePrivateBackgroundContext() {
        privateContext.performAndWait {
            do {
                try privateContext.save()
            }
            catch {
               fatalError("WriteToCD - Error saving CD: \(error.localizedDescription)")
            }
        }
    }
    
   
    //MARK: - Insert Objects
    func saveBeerObject(id: CKRecord.ID, section: String, tag: String, name: String, description: String, abv: String, type: String, createdDate: Date, modDate: Date, isFav: Bool, isTap: Bool) {
        persistentContainer.performBackgroundTask { (privateContext) in
            //Create new Beer Entity Object
            let beer = Beers(context: privateContext)
            
            beer.id = id
            beer.section = section
            beer.changeTag = tag
            beer.name = name
            beer.beerDescription = description
            beer.abv = abv
            beer.ckCreatedDate = createdDate
            beer.ckModifiedDate = modDate
            beer.isFavorite = isFav
            beer.isOnTap = isTap
            beer.beerType = type
            
            do {
                try privateContext.save()
            }
            catch {
                fatalError("WriteToCD -- Failure to save Objects: \(error.localizedDescription)")
            }
        }
    }
       
    
    
    
    //MARK: - Update Objects
    /// Update 'Favorite' status
    func updateFavoriteStatusOn(_ beer: Beers) {
        persistentContainer.performBackgroundTask { (privateContext) in
            guard let queueSafeBeer = privateContext.object(with: beer.objectID) as? Beers else { return }
            queueSafeBeer.isFavorite = !queueSafeBeer.isFavorite
            queueSafeBeer.ckModifiedDate = Date()
            
            do {
                try privateContext.save()
            }
            catch {
                fatalError("WriteToCD -- Failure to save context: \(error.localizedDescription)")
            }
        }
    }
    
    /// Update the 'On Tap' status of beer object passed in.
    /// This method uses the background context to save this. This is thread safe.
    func updateOnTapStatusOn(_ beer: Beers) {
        persistentContainer.performBackgroundTask { (privateContext) in
            guard let queueSafeBeer = privateContext.object(with: beer.objectID) as? Beers else { return }
            queueSafeBeer.isOnTap = !queueSafeBeer.isOnTap
            queueSafeBeer.ckModifiedDate = Date()
            
            do {
                try privateContext.save()
            }
            catch {
                fatalError("WriteToCD -- Failure to save context: \(error.localizedDescription)")
            }
        }
    }
    
    ///
    func batchUpdate(predicate: NSPredicate) {
        persistentContainer.performBackgroundTask { (privateContext) in
            let updateRequest = NSBatchUpdateRequest(entityName: EntityName.beers.rawValue)
            let predicate = predicate
            updateRequest.predicate = predicate
            updateRequest.propertiesToUpdate = ["isFavorite" : false]
            updateRequest.resultType = .updatedObjectIDsResultType
            
            do {
                //Execute batch
                let result = try privateContext.execute(updateRequest) as? NSBatchUpdateResult
                //Get the updated ID's
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                //Update the main context
                let changes = [NSUpdatedObjectsKey : objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainThreadContext])
                
            }
            catch {
                fatalError("WriteToCD -- Failed to execute request: \(error)")
            }
        }
    }
    
    
    //MARK: - Deleting Methods
    
    /// Deletes the NSManagedObject passed in.
    func delete(_ beer: Beers) {
        persistentContainer.performBackgroundTask { (privateManagedContext) in
            do {
                ///Delete the object
                privateManagedContext.delete(beer)
                
                ///Save in the private context
                try privateManagedContext.save()
            }
            catch {
                fatalError("WriteToCD -- Failure to save context -- delete: \(error.localizedDescription)")
            }
        }
    }
    
    /// Batch Delete. This removes ALL NSManagedObjects.
    /// This is being used for Debug purposess. Not currently used within the code.
    func batchDelete() {
        persistentContainer.performBackgroundTask { (privateMOC) in
            let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
            let predicate = NSPredicate(value: true)
            fetchRequest.predicate = predicate
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            //
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try privateMOC.execute(deleteRequest) as? NSBatchDeleteResult
                guard let deletedIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey : deletedIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainThreadContext])
            }
            catch {
                fatalError("WriteToCD -- Failed to batch delete: \(error.localizedDescription)")
            }
        }
    }
}
