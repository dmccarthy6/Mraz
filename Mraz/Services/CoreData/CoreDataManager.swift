//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import os.log

final class CoreDataManager: NSObject, CoreDataAPI {
    // MARK: - Properties
    let coreDataLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: SyncContainer.self))

    let context: NSManagedObjectContext
    
    static var entityName: String {
        return EntityName.beers.rawValue
    }

    private lazy var syncContainer = {
        return SyncContainer()
    }()
    
    // MARK: - Lifecycle
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        #warning("TODO: - Fix")
        syncContainer.syncDelegate = self
    }
    
    // MARK: - Saving
    public func saveContext() {
        do {
            try context.save()
        } catch {
            os_log("Err %@", log: coreDataLog, type: .debug, error.localizedDescription)
            fatalError("CoreDataStack -- Error saving to main context")
        }
    }
    
    /// Generic save function to save the specified ManagedObject to the context.
    /// - Parameter object: NSManagedObject value
    /// - Parameter beerModel: 'BeerModel' object used to save a beer NSManagedObject.
    func saveObject<T: NSManagedObject>(object: T, model: BeerModel, in context: NSManagedObjectContext) {
        guard let beerObject = object as? Beers else { return }
        Beers.updateOrCreate(beerObject, from: model)
        saveContext()
    }

    /// Takes in a 'BeerModel' object and converts that into a 'Beers' NSManagedObject.
    func saveNewBeerToDatabase(from modelObj: BeerModel) {
        let predicate = NSPredicate(format: "id == %@", modelObj.id)
        let beers = fetchManagedObject(by: predicate)
        if beers.isEmpty {
            let beer = Beers(context: context)
            saveObject(object: beer, model: modelObj, in: context)
        }
    }
    
    func saveModifiedBeerToDatabase(beer: Beers, model: BeerModel, context: NSManagedObjectContext) {
        Beers.updateOrCreate(beer, from: model)
        
        saveContext()
    }
    
    // MARK: - Delete Methods
    func delete<T>(_ managedObject: T) where T: NSManagedObject {
        context.delete(managedObject)
        saveContext()
    }
    
    // MARK: - Core Data Fetching
    func findOrFetchObject(matching predicate: NSPredicate) -> Beers? {
        return Beers.findOrFetch(in: context, matching: predicate)
    }
    
    ///Fetch the Core Data objects that match the predicate passed in.
    /// - Parameter predicate: NSPredicate value to pass into the FetchRequest.
    /// - Returns: Array of Beers Managed Objects matching predicate
    func fetchManagedObject(by predicate: NSPredicate) -> [Beers] {
        let beers =  Beers.fetch(in: context) { (request) in
            request.predicate = predicate
            request.fetchBatchSize = 25
            request.returnsObjectsAsFaults = false
            request.sortDescriptors = Beers.defaultSortDescriptors
        }
        
        return beers
    }
 
    // MARK: - Local Status Updates
    // MARK: - Update
    
    /// Update the favrotie status for beer locally.
    /// - Parameter beer: The Beers object having it's isFavorite status updated.
    func updateFavoriteStatusOf(beer object: Beers) {
        let predicate = NSPredicate(format: "objectID == %@", object.objectID)
        guard let beer = Beers.findOrFetch(in: context, matching: predicate) else { return }
        let beerModel = BeerModel.createBeerModel(from: beer)
        Beers.updateOrCreate(beer, from: beerModel)
        saveContext()
    }
    
    // Update Beer From CK (Remote Push)
    /// Takes in a CK record object and checks if there's an existing managed object with that ID.
    /// If the beer object exists, update it if it doesn't it creates the new beer.
    /// - Parameter record: CKRecord obtained from the Push Notification
    func updateOrCreateBeerObject(from record: CKRecord) {
        let predicate = NSPredicate(format: "id == %@", record.recordID.recordName)
        
        guard let existingBeer = Beers.findOrFetch(in: context, matching: predicate) else {
            let newBeerObject = Beers(context: context)
            let newBeerModel = BeerModel.createBeerModel(from: record, isFavorite: newBeerObject.isFavorite)
            Beers.updateOrCreate(newBeerObject, from: newBeerModel)
            return
        }
        
        let modelBeer1 = BeerModel.createBeerModel(from: existingBeer)
        Beers.updateOrCreate(existingBeer, from: modelBeer1)
        LocalNotificationManger().sendFavoriteBeerNotification(for: existingBeer)
    }
    
    func updateOrCreateBeer(from modelObject: BeerModel) {
        let predicate = NSPredicate(format: "id == %@", modelObject.id)
        
        guard let existingBeer = Beers.findOrFetch(in: context, matching: predicate) else {
            let beer = Beers(context: context)
            Beers.updateOrCreate(beer, from: modelObject)
            return
        }
        
        let modelBeer = BeerModel.createBeerModel(from: existingBeer)
        Beers.updateOrCreate(existingBeer, from: modelBeer)
        LocalNotificationManger().sendFavoriteBeerNotification(for: existingBeer)
    }
    
    func update(_ beer: Beers, from model: BeerModel) {
        Beers.updateOrCreate(beer, from: model)
        LocalNotificationManger().sendFavoriteBeerNotification(for: beer)
    }
    
    // MARK: - Create
    
    /// Create new managed objects and save the context. Used for initial fetch
    /// - Parameter beerModel: Array of model objects
    func createBeerObjects(from beerModel: [BeerModel]) {
        beerModel.forEach { (beer) in
            let createdBeer = Beers(context: context)
            Beers.updateOrCreate(createdBeer, from: beer)
        }
       saveContext()
    }
}

extension CoreDataManager: CKSyncDelegate {
    func saveBeersToDatabase(from model: [BeerModel]) {
        createBeerObjects(from: model)
    }
    
    func saveRemoteChange(using record: CKRecord) {
        updateOrCreateBeerObject(from: record)
    }
}
