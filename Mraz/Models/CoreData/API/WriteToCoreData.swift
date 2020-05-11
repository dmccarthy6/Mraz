//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

protocol WriteToCoreData: ReadFromCoreData {
    
}

extension WriteToCoreData {
    // MARK: - Core Data Stack
    var mainThreadContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.managedObjectContext
    }
    
    var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.privateContext
    }
    
    var persistentContainer: NSPersistentContainer {
        return CoreDataManager.sharedDatabase.beersContainer
    }
    
    // MARK: - Saving Methods
    /// Core Data Save. This method checks if the Main Thread Context Or Private Context has changes
    /// If yes, it performs the 'save()' method on the context.
    func saveContext() {
        if mainThreadContext.hasChanges {
            mainThreadContext.performAndWait {
                do {
                    try self.mainThreadContext.save()
                } catch {
                    fatalError("WriteToCD - Error saving CD: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Perform 'save()' on the background context.
    func savePrivateBackgroundContext() {
        privateContext.performAndWait {
            do {
                try privateContext.save()
            } catch {
                fatalError("WriteToCD - Error saving CD: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Insert Objects
    /// Takes in a 'BeerModel'
    /// - Parameter beerModel: The model object used to save 
    func saveBeerObjectToCoreData(from beerModel: BeerModel) {
        let beer = Beers(context: mainThreadContext)
        saveObject(object: beer, beerModel: beerModel, inContext: mainThreadContext)
    }
    
    /// Create the ModifiedRecords object that will be used to persist the 'modifiedDate' property
    /// for keeping track of fetches performed on updated CloudKit records. Initially set to nil.
    func setModifiedDate(_ date: Date?) {
        let modifiedDateObject = ModifiedRecords(context: mainThreadContext)
        saveObject(object: modifiedDateObject, modifiedDate: date, inContext: mainThreadContext)
    }
    
    /// Generic save function to save the specified ManagedObject to the context.
    /// - Parameter object: NSManagedObject value 
    /// - Parameter beerModel: 'BeerModel' object used to save a beer NSManagedObject.
    /// - Parameter modifiedDate: ModifiedDate property to set the modified date on the NSManagedObject.
    /// - Parameter inContext: ManagedObjectContext used to save the Core Data object.
    func saveObject<T: NSManagedObject>(object: T, beerModel: BeerModel? = nil, modifiedDate: Date? = nil,
                                    inContext: NSManagedObjectContext) {
        if let beerObject = object as? Beers, let model = beerModel {
            saveBeer(from: model, beer: beerObject)
        }
        if let modDateObject = object as? ModifiedRecords {
            /// Set the modified date parameter to today's date.
            modDateObject.modifiedDate = Date()
            saveContext()
        }
    }
    
    /// Create and save a beer object from a local 'BeerModel'
    /// - Parameter model: 'BeerModel' object that contains the data needd to save the 'Beers' object.
    /// - Parameter beer: The 'Beers' managed object being created.
    func saveBeer(from model: BeerModel, beer: Beers, context: NSManagedObjectContext? = nil) {
        beer.id =                 model.id
        beer.changeTag =           model.changeTag
        beer.name =               model.name
        beer.beerDescription =     model.beerDescription
        beer.abv =                 model.abv
        beer.beerType =            model.type
        beer.ckCreatedDate =       model.createdDate
        beer.ckModifiedDate =      model.modifiedDate
        beer.isFavorite =          model.isFavorite
        beer.isOnTap =             model.isOnTap
        beer.section =             model.section
        saveContext()
    }

    // MARK: - Update Objects
    /// Update the 'isFavorite' value on the NSManagedObject. This is only a local change not updating CloudKit with this change.
    /// - Parameter beer: The NSManagedObject value to update the 'isFavorite' property on.
    func updateLocalFavoriteStatus(_ beer: Beers) {
        persistentContainer.performBackgroundTask { (privateContext) in
            guard let queueSafeBeer = privateContext.object(with: beer.objectID) as? Beers else { return }
            queueSafeBeer.isFavorite = !queueSafeBeer.isFavorite
            queueSafeBeer.ckModifiedDate = Date()
            self.saveContext()
        }
    }
    
    /// Method that takes in the 'BeerModel' object created from the updated CKRecord. Use that object to update the ManagedObject.
    /// - Parameter beer: 'Beers' object corresponding to the updated CKRecord. This is the object being updated.
    /// - Parameter from: 'BeerModel' object created from updated CKRecord. Use these values to update ManagedObject.
    /// - Parameter context: NSManagedObjectContext
    func updateCurrentBeersObject(beer: Beers, from: BeerModel, in context: NSManagedObjectContext) {
        // Values that won't change: id / isFavorite / createdDate
        // Values that shouldn't change:
        beer.changeTag = from.changeTag
        beer.ckModifiedDate = from.modifiedDate
        beer.name = from.name
        beer.abv = from.abv
        beer.beerDescription = from.beerDescription
        beer.isOnTap = from.isOnTap
        print("WriteToCoreData -- UpdatedBeer: \(beer)")
        saveContext()
    }
    
    /// Set the 'ModifiedRecords' modified date to today's date.
    func setModifiedDate() {
        guard let modifiedDateEntity = fetchModifiedDate() else { return }
        modifiedDateEntity.modifiedDate = Date()
        saveContext()
    }
    
    // MARK: - Search Methods
    /// Use a NSManagedObjectID value to search the managed object context for the 'Beers' object.
    /// - Parameter objectID: The NSManagedObjectID value used to search for
    /// - Returns: A 'Beers' NSManagedObject object. This is the value that needs to be updated.
    func getBeerObjectFrom(objectID: NSManagedObjectID) -> Beers {
        return mainThreadContext.object(with: objectID) as! Beers
    }
    
    /// Use the updated CKRecordID to fetch the database and return the 'Beers' NSManagedObjectID for that record.
    /// - Parameter ckRecordID: CKRecordID of the updated value.
    /// - Returns: the NSManagedObjectID for the managedObject value located.
    func getManagedObjectIDFrom(_ ckRecordID: String) -> NSManagedObjectID? {
        let filterPredicate = NSPredicate(format: "id == %@", ckRecordID)
        let request = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        request.predicate = filterPredicate
        
        do {
            let filteredObjects = try mainThreadContext.fetch(request) as! [Beers]
            return filteredObjects[0].objectID
        } catch {
            print("WriteToCoreData -- Error filtering Core Data: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Deleting Methods
    /// Uses the background context to perform the delete method on that context.
    /// - Parameter beer: The 'Beers' NSManagedObject to be deleted
    func delete(_ beer: Beers) {
        persistentContainer.performBackgroundTask { (privateManagedContext) in
            do {
                ///Delete the object
                privateManagedContext.delete(beer)
                ///Save in the private context
                try privateManagedContext.save()
            } catch {
                fatalError("WriteToCD -- Failure to save context -- delete: \(error.localizedDescription)")
            }
        }
    }
    
    /**
        This method batch deletes all objects from the managedObject context.
     
        This method uses the background context to fetch all managedObjects and delete
        all of the objects.
     */
    func batchDelete() {
        persistentContainer.performBackgroundTask { (privateMOC) in
            let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
            let predicate = NSPredicate(value: true)
            fetchRequest.predicate = predicate
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let result = try privateMOC.execute(deleteRequest) as? NSBatchDeleteResult
                guard let deletedIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: deletedIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainThreadContext])
            } catch {
                fatalError("WriteToCD -- Failed to batch delete: \(error.localizedDescription)")
            }
        }
    }
}

/* BATCH UPDATE METHOD -- NOT CURRENTLY USING, MAY USE LATER.
 /// Batch  Update Method.
 func batchUpdate(predicate: NSPredicate) {
     persistentContainer.performBackgroundTask { (privateContext) in
         let updateRequest = NSBatchUpdateRequest(entityName: EntityName.beers.rawValue)
         let predicate = predicate
         updateRequest.predicate = predicate
         updateRequest.propertiesToUpdate = ["isFavorite": false]
         updateRequest.resultType = .updatedObjectIDsResultType
         
         do {
             //Execute batch
             let result = try privateContext.execute(updateRequest) as? NSBatchUpdateResult
             //Get the updated ID's
             guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
             //Update the main context
             let changes = [NSUpdatedObjectsKey: objectIDs]
             NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainThreadContext])
             
         } catch {
             fatalError("WriteToCD -- Failed to execute request: \(error)")
         }
     }
 }
 */
