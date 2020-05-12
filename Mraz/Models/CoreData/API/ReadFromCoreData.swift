//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit

protocol ReadFromCoreData {
    func configureAllBeersFetchedResultsController(for entity: EntityName, key: String?, searchText: String, ascending: Bool) -> NSFetchedResultsController<NSFetchRequestResult>
}

extension ReadFromCoreData {
    /// Context value from 'ReadFromCoreData'
    var mainThreadManagedObjectContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.managedObjectContext
    }
    
    var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.privateContext
    }
    
    var beerFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return configureAllBeersFetchedResultsController(for: .beers, key: "name", searchText: "")
    }
    var onTapFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return configureOnTapFetchedResultsController(for: .beers)
    }
    
    // MARK: - Configure Fetched Results Controller
    /// Default implementation of the FRC. Will implement this in the ViewController in order to update my snapshot.
    func configureAllBeersFetchedResultsController(for entity: EntityName, key: String?, searchText: String, ascending: Bool = true) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = CoreDataFetchRequestFor(entityName: entity.rawValue)
        let sortDescriptor = [NSSortDescriptor(key: key, ascending: ascending)]
        fetchRequest.sortDescriptors = sortDescriptor
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        }
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: mainThreadManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching Core Data: \(error.localizedDescription)")
        }
        return fetchedResultsController
    }
    
    /// Configure the onTap FRC.
    /// - Parameter entity: Entity performing the fetch on.
    func configureOnTapFetchedResultsController(for entity: EntityName) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = CoreDataFetchRequestFor(entityName: entity.rawValue)
        let predicate = NSPredicate(format: "isOnTap == %d", true)
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                managedObjectContext: mainThreadManagedObjectContext,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("ReadFromCoreData -- Could not configure onTapFetchedResultsController - \(error.localizedDescription)")
        }
        return fetchResultsController
    }
  
    // MARK: - Fetch Functions
    /// This method takes in an NSManagedObjectID value and returns the last modified date set.
    /// - Parameter objectID: NSManagedObjectID of the ModifiedRecords date value that was created.
    /// - Returns: Optional Date value containing the last fetched date
    func getLastModifiedFetchDate() -> Date? {
        guard let createdObjectID = modifiedDateObjectID() else { return nil }
        guard let lastModifiedEntity = getModifiedDateBy(objectID: createdObjectID) else { return nil }
        return lastModifiedEntity.modifiedDate
    }

    /// Uses the
    /// - Parameter objectID: NSManagedObjectID of the Modified Record object created.
    func getModifiedDateBy(objectID: NSManagedObjectID) -> ModifiedRecords? {
        guard let modifiedDateObj = mainThreadManagedObjectContext.object(with: objectID) as? ModifiedRecords else {
            return nil
        }
        return modifiedDateObj
    }
    
    /// Obtain the ObjectID
    /// - Returns: NSManagedObjectID for the modified date entity.
    func modifiedDateObjectID() -> NSManagedObjectID? {
        let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.modifiedDate.rawValue)
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "modifiedDate", ascending: true)]
        do {
            let modifiedEntity = try mainThreadManagedObjectContext.fetch(fetchRequest) as? [ModifiedRecords]
            guard let safeModifiedEntity = modifiedEntity, let rec = safeModifiedEntity.first else {
                fatalError("Could Not Find")
            }
            return rec.objectID
        } catch {
            print("ReadFromCoreData == Error Fetching Modified Recprd: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Background Fetch
    /// Background fetch method to perform fetch on the background context, if needed.
    func backgroundFetch() {
        let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asyncFetchResult) in
        guard let result = asyncFetchResult.finalResult as? [Beers] else { return }
            
            //Dipatch to main queue
            DispatchQueue.main.async {
                //Create queue safe array of beers
                var beers: [Beers] = result.lazy
                    /// Get all the object ID's.
                    .compactMap({ $0.objectID})
                    ///Create a new Beer entity queue-safe for each objectID.
                    .compactMap({ self.mainThreadManagedObjectContext.object(with: $0) as? Beers })
                //Do Something with that queue safe array - beers
            }
        }
        do {
            try privateContext.execute(asyncFetchRequest)
            
        } catch {
            print("READ FROM COREDATA --  error: \(error)")
        }
    }
}
