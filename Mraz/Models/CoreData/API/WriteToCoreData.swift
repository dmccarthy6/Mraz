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
    func updateLastModifiedDate( id: NSManagedObjectID) {
        guard let modifiedDateObject = getModifiedDateBy(objectID: id) else { return }
        saveObject(object: modifiedDateObject, inContext: mainThreadContext)
    }
    
    /// Creates the single instance of the ManagedObject used for tracking the modified date. This method is called
    /// when the application first loads to trigger notifications for any updates to CloudKit database after the initial fetch.
    func createLastModifiedDate() {
        let modifiedDate = ModifiedRecords(context: mainThreadContext)
        saveObject(object: modifiedDate, inContext: mainThreadContext)
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
            /// Setting modified date to the current date each time we call this to get the date the last changes were obtained.
            modDateObject.modifiedDate = modifiedDate ?? Date()
            print(Date())
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
//        print("WriteToCoreData -- UpdatedBeer: \(beer)")
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
            guard let filteredObjects = try mainThreadContext.fetch(request) as? [Beers] else { return nil }
            guard let objID = filteredObjects.first?.objectID else { return nil }
            return objID
        } catch {
            print("WriteToCoreData -- Error filtering Core Data: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Deleting Methods
    /// Uses the background context to perform the delete method on that context.
    /// - Parameter beer: The 'Beers' NSManagedObject to be deleted
    func delete<T: NSManagedObject>(_ managedObject: T) {
        if let beerObject = managedObject as? Beers {
            self.mainThreadManagedObjectContext.delete(beerObject)
        }
        if let modDateObject = managedObject as? ModifiedRecords {
            self.mainThreadManagedObjectContext.delete(modDateObject)
        }
        self.saveContext()
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

/*
  func delete<T: NSManagedObject>(_ managedObject: T) {
         if let beerObject = managedObject as? Beers {
             self.mainThreadManagedObjectContext.delete(beerObject)
         } else {
             if let modDateObject = managedObject as? ModifiedRecords {
             self.mainThreadManagedObjectContext.delete(modDateObject)
         }
         }
         self.saveContext()
 //        persistentContainer.performBackgroundTask { (privateManagedContext) in
 //            do {
 //                if let object = managedObject as? Beers {
 //                    self.mainThreadManagedObjectContext.delete(object)
 //                }
 //                if let object = managedObject as? ModifiedRecords {
 //                    self.mainThreadManagedObjectContext.delete(object)
 //                }
 //                self.saveContext()
 //            } catch {
 //                fatalError("WriteToCD -- Failure to save context -- delete: \(error.localizedDescription)")
 //            }
 //        }
     }
 */