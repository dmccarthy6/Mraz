//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import CloudKit

protocol ReadFromCoreData {
    func configureFetchedResultsController(for entity: EntityName, key: String?, searchText: String, ascending: Bool) -> NSFetchedResultsController<NSFetchRequestResult>
}

extension ReadFromCoreData {
    /// Context value from 'ReadFromCoreData'
    var mainThreadManagedObjectContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.managedObjectContext
    }
    
    var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.privateContext
    }
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return configureFetchedResultsController(for: .beers, key: "name", searchText: "")
    }
    
    // MARK: - Configure Fetched Results Controller
    /// Default implementation of the FRC. Will implement this in the ViewController in order to update my snapshot.
    func configureFetchedResultsController(for entity: EntityName, key: String?, searchText: String, ascending: Bool = true) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = CoreDataFetchRequestFor(entityName: entity.rawValue)
        let sortDescriptor = [NSSortDescriptor(key: key, ascending: ascending)]
        fetchRequest.sortDescriptors = sortDescriptor
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
        }
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainThreadManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching Core Data: \(error.localizedDescription)")
        }
        return fetchedResultsController
    }
    
    // MARK: - Fetch Functions
    /// This method takes in an NSManagedObjectID value and returns the last modified date set.
    /// - Parameter objectID: NSManagedObjectID of the ModifiedRecords date value that was created.
    /// - Returns: Optional Date value containing the last fetched date
    func getLastModifiedFetchDate() -> Date? {
        guard let lastModifiedEntity = fetchModifiedDate() else {
            return nil
        }
        return lastModifiedEntity.modifiedDate
    }
    
    /// Fetch the Main Context for 'ModifiedRecords' Entity
    /// - Returns: NSManagedObject of type 'ModifiedRecords'
    func fetchModifiedDate() -> ModifiedRecords? {
        let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.modifiedDate.rawValue)
        let sortDescriptor = [NSSortDescriptor(key: "modifiedDate", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        do {
            let modEntity = try mainThreadManagedObjectContext.fetch(fetchRequest) as? [ModifiedRecords]
            return modEntity?[0]
        } catch {
            fatalError("ReadFromCoreData -- Error fetching ModifiedDate: \(error.localizedDescription)")
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
