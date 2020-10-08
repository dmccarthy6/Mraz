//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit

final class CoreDataManager: CoreDataAPI {
    // MARK: - Properties
    static let shared = CoreDataManager()
    private let stack = CoreDataStack.sharedStack
    private lazy var persistentContainer = stack.persistentContainer
    internal lazy var mainThreadContext = stack.mainThreadContext
    var frcPredicate: NSPredicate?

    // MARK: - Lifecycle
    init(predicate: NSPredicate? = NSPredicate(value: true)) {
        self.frcPredicate = predicate
    }
    
    // MARK: - Saving
    /// Generic save function to save the specified ManagedObject to the context.
    /// - Parameter object: NSManagedObject value
    /// - Parameter beerModel: 'BeerModel' object used to save a beer NSManagedObject.
    /// - Parameter modifiedDate: ModifiedDate property to set the modified date on the NSManagedObject.
    func saveObject<T: NSManagedObject>(object: T, model: BeerModel, modifiedDate: Date, in context: NSManagedObjectContext) {
        guard let beerObject = object as? Beers else { return }
        createOrUpdateBeerObject(from: model, beer: beerObject, in: context)
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
    
    /// Takes in a 'BeerModel' object and converts that into a 'Beers' NSManagedObject.
    func saveNewBeerToDatabase(from modelObj: BeerModel) {
        let predicate = NSPredicate(format: "id == %@", modelObj.id)
        let beers = fetchManagedObject(by: predicate)
        if beers.isEmpty {
            let beer = Beers(context: mainThreadContext)
            saveObject(object: beer, model: modelObj, modifiedDate: Date(), in: mainThreadContext)
        }
    }
    
    func saveModifiedBeerToDatabase(beer: Beers, model: BeerModel, context: NSManagedObjectContext) {
        createOrUpdateBeerObject(from: model, beer: beer, in: context)
        save(context: context)
    }
    
    // MARK: - Delete Methods
    func delete<T>(_ managedObject: T) where T: NSManagedObject {
        mainThreadContext.delete(managedObject)
        save(context: mainThreadContext)
    }
    
    /// Delete all managedObjects from context.
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
    
    // MARK: - FetchedResultsController
    func configureFetchedResultsController(for entity: EntityName, key: String?, ascending: Bool) -> MrazFetchedResultsController {
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
    
    // MARK: - Core Data Fetching
    /// Search CoreData for an object by searching for the objectID:
    /// - Parameter objectID: NSManagedObjectID used to search context for an object
    func getObjectBy<T: NSManagedObject>(_ objectID: NSManagedObjectID) -> T? {
        guard let fetchedObject = mainThreadContext.object(with: objectID) as? T else {
            return nil
        }
        return fetchedObject
    }
    
    ///Fetch the Core Data objects that match the predicate passed in.
    /// - Parameter predicate: NSPredicate value to pass into the FetchRequest.
    func fetchManagedObject(by predicate: NSPredicate) -> [Beers] {
        let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        fetchRequest.predicate = predicate
        do {
            let beers = try self.mainThreadContext.fetch(fetchRequest) as? [Beers]
            guard let safeBeers = beers, safeBeers.count > 0 else { return [] }
            return safeBeers
        } catch {
            return []
        }
    }
    
    /// Fetch a single Beer object by id
    func fetchCoreDataObject(by recordName: String) -> Beers? {
        let fetchPredicate = NSPredicate(format: "id == %@", recordName)
        let results = fetchManagedObject(by: fetchPredicate)
        if results.isEmpty {
            return nil
        }
        return results[0]
    }
 
    // MARK: - Local Status Updates
    /// Change the local Core Data onTap status for a beer
    func changeLocalOnTapStatus(for objectID: NSManagedObjectID) {
        let object = getObjectBy(objectID) as? Beers
        guard let beerObject = object else { return }
        beerObject.isOnTap = !beerObject.isOnTap
        save(context: mainThreadContext)
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
    
    // MARK: - Helpers
    /// Set 'Beers' value using a 'BeerModel' object to set data.
    func createOrUpdateBeerObject(from model: BeerModel, beer: Beers, in context: NSManagedObjectContext) {
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
    
    func validateBeerFieldsFrom(record: CKRecord, beer: Beers) -> Bool {
        let beerModel = CloudKitManager.shared.generateLocalModelFrom(record: record, isFav: beer.isFavorite)
        return beer.name == beerModel.name &&
        beer.beerDescription == beerModel.beerDescription && beer.abv == beerModel.abv
    }
}
