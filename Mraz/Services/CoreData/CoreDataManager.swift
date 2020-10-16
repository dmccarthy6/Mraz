//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit
import os.log

final class CoreDataManager: NSObject, CoreDataAPI {
    // MARK: - Properties
    let coreDataLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: SyncContainer.self))

    private lazy var persistentContainer = CoreDataStack.coreDataStore.persistentContainer
    
    internal lazy var mainContext = CoreDataStack.mainContext
    
    var frcPredicate: NSPredicate?
    
    static var entityName: String {
        return EntityName.beers.rawValue
    }

    // MARK: - Lifecycle
    init(predicate: NSPredicate? = NSPredicate(value: true)) {
        self.frcPredicate = predicate
        super.init()
    }
    
    // MARK: - Saving
    /// Generic save function to save the specified ManagedObject to the context.
    /// - Parameter object: NSManagedObject value
    /// - Parameter beerModel: 'BeerModel' object used to save a beer NSManagedObject.
    func saveObject<T: NSManagedObject>(object: T, model: BeerModel, in context: NSManagedObjectContext) {
        guard let beerObject = object as? Beers else { return }
        Beers.updateOrCreate(beerObject, from: model)
        CoreDataStack.save(mainContext)
    }

    /// Takes in a 'BeerModel' object and converts that into a 'Beers' NSManagedObject.
    func saveNewBeerToDatabase(from modelObj: BeerModel) {
        let predicate = NSPredicate(format: "id == %@", modelObj.id)
        let beers = fetchManagedObject(by: predicate)
        if beers.isEmpty {
            let beer = Beers(context: mainContext)
            saveObject(object: beer, model: modelObj, in: mainContext)
        }
    }
    
    func saveModifiedBeerToDatabase(beer: Beers, model: BeerModel, context: NSManagedObjectContext) {
        Beers.updateOrCreate(beer, from: model)
        CoreDataStack.save(mainContext)
    }
    
    // MARK: - Delete Methods
    func delete<T>(_ managedObject: T) where T: NSManagedObject {
        mainContext.delete(managedObject)
        CoreDataStack.save(mainContext)
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
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.mainContext])
            } catch {
                fatalError("WriteToCD -- Failed to batch delete: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Core Data Fetching
    func findOrFetchObject(matching predicate: NSPredicate) -> Beers? {
        return Beers.findOrFetch(in: mainContext, matching: predicate)
    }
    
    ///Fetch the Core Data objects that match the predicate passed in.
    /// - Parameter predicate: NSPredicate value to pass into the FetchRequest.
    func fetchManagedObject(by predicate: NSPredicate) -> [Beers] {
        let beers =  Beers.fetch(in: mainContext) { (request) in
            request.predicate = predicate
            request.fetchBatchSize = 25
            request.returnsObjectsAsFaults = false
            request.sortDescriptors = Beers.defaultSortDescriptors
        }
        
        return beers
    }
 
    // MARK: - Local Status Updates
    func update(beer object: Beers) {
        let predicate = NSPredicate(format: "objectID == %@", object.objectID)
        guard let beer = Beers.findOrFetch(in: mainContext, matching: predicate) else { return }
        let beerModel = BeerModel.createBeerModel(from: beer)
        Beers.updateOrCreate(beer, from: beerModel)
        CoreDataStack.save(mainContext)
    }
}
