//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit

final class CoreDataManager: CoreDataAPI {
    // MARK: - Core Data Stack
    static let shared = CoreDataManager()
    private let stack = CoreDataStack.sharedStack
    var frcPredicate: NSPredicate?
    private lazy var persistentContainer = stack.persistentContainer
    lazy var mainThreadContext = stack.mainThreadContext
//    private lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "Mraz")
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("CoreDataManager = Unresolved error \(error), \(error.userInfo)")
//            }
//            print("Successfully created store: \(storeDescription.url!)")
//        }
//        return container
//    }()
//
//    /// Managed Object Context
//    lazy var mainThreadContext: NSManagedObjectContext = {
//        let context = persistentContainer.viewContext
//        context.automaticallyMergesChangesFromParent = true
//        return context
//    }()
//
//    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
//        let context = persistentContainer.newBackgroundContext()
//        return context
//    }()
    
    // MARK: - Life Cycle
    init(predicate: NSPredicate? = NSPredicate(value: true)) {
        self.frcPredicate = predicate
    }
    
    // MARK: - Write To Core Data Methods
    
    // MARK: - Saving
    /// Generic save function to save the specified ManagedObject to the context.
    /// - Parameter object: NSManagedObject value
    /// - Parameter beerModel: 'BeerModel' object used to save a beer NSManagedObject.
    /// - Parameter modifiedDate: ModifiedDate property to set the modified date on the NSManagedObject.
    func saveObject<T: NSManagedObject>(object: T, model: BeerModel, modifiedDate: Date, in context: NSManagedObjectContext) {
        if let beerObject = object as? Beers {
            createManagedObject(from: model, beer: beerObject, in: context)
        } else if let modDateObject = object as? ModifiedRecords {
            modDateObject.modifiedDate = modifiedDate
        }
        save(context: mainThreadContext)
    }
    
    /// Check that the context has changes, if true it saves.
    func save(context: NSManagedObjectContext) {
        if mainThreadContext.hasChanges {
            mainThreadContext.performAndWait {
                do {
                    try self.mainThreadContext.save()
                } catch {
                    fatalError("CoreDataManager -- Error saving to core data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Takes a model object and saves it to Core Data
    func saveBeerObjectToCoreData(from modelObj: BeerModel) {
        let beer = Beers(context: mainThreadContext)
        saveObject(object: beer, model: modelObj, modifiedDate: Date(), in: mainThreadContext)
    }
    
    func delete<T>(_ managedObject: T) where T: NSManagedObject {
        if let beerObject = managedObject as? Beers {
            mainThreadContext.delete(beerObject)
        } else if let modDateObject = managedObject as? ModifiedRecords {
            mainThreadContext.delete(modDateObject)
        }
        save(context: mainThreadContext)
    }
    
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
    
    // MARK: - Read From Core Data Methods
    
    // MARK: - Fetching
    func configureFetchedResultsController(for entity: EntityName, key: String?, searchText: String, ascending: Bool) -> MrazFetchedResultsController {
        let fetchRequest = CoreDataFetchRequestFor(entityName: entity.rawValue)
        let sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = frcPredicate
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: mainThreadContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching Core Data: \(error.localizedDescription)")
        }
        return fetchedResultsController
    }
    
    func getObjectBy<T: NSManagedObject>(_ objectID: NSManagedObjectID) -> T? {
        guard let fetchedObject = mainThreadContext.object(with: objectID) as? T else {
            return nil
        }
        return fetchedObject
    }
    
    /// Fetch updated record from cloudkit by filtering Core Data fetch by recordName
    func fetchUpdatedRecord(by recordName: String) -> Beers? {
        let changedRecordRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        changedRecordRequest.predicate = NSPredicate(format: "id == %@", recordName)
        do {
            let beers = try self.mainThreadContext.fetch(changedRecordRequest) as? [Beers]
            guard let safeBeers = beers, safeBeers.count > 0 else { return nil }
            return safeBeers.first
        } catch {
            return nil
        }
    }
    
    // MARK: - Helpers
    func createManagedObject(from model: BeerModel, beer: Beers, in context: NSManagedObjectContext? = nil) {
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
    }
    
    /// Update the 'isFavorite' value on the NSManagedObject. This is only a local change not updating CloudKit with this change.
    /// - Parameter beer: The NSManagedObject value to update the 'isFavorite' property on.
    func updateLocalFavoriteStatus(_ beer: Beers) {
        persistentContainer.performBackgroundTask { (privateContext) in
            guard let queueSafeBeer = privateContext.object(with: beer.objectID) as? Beers else { return }
            queueSafeBeer.isFavorite = !queueSafeBeer.isFavorite
            queueSafeBeer.ckModifiedDate = Date()
            self.save(context: self.mainThreadContext)
        }
    }
}
