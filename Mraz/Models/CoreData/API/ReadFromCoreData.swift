//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import UIKit

protocol ReadFromCoreData {
    
    
}

extension ReadFromCoreData {
    var mainThreadContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.managedObjectContext
    }
    
    var privateContext: NSManagedObjectContext {
        return CoreDataManager.sharedDatabase.privateContext
    }
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return configureFetchedResultsController()
    }
    
    
    //MARK: - Configure Fetched Results Controller
    func configureFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        let sortDescriptor = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.predicate = NSPredicate(value: true)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainThreadContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            //TO-DO: Update snapshot here
        }
        catch {
            let error = error as NSError
            print("Error fetching Core Data: \(error.userInfo)")
        }
        return fetchedResultsController
    }
    
    //MARK: - Fetch Functions
    /// Uses configured FetchedResultsController to return specified objects.
    /// - Returns: Array of 'Beers' objects.
    func fetchAllBeerObjects() -> [Beers] {
        let beers = fetchedResultsController.fetchedObjects as! [Beers]
        return beers
    }
    
    
    //MARK: - Background Fetch
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
                    .compactMap({ self.mainThreadContext.object(with: $0) as? Beers })
                //Do Something with that queue safe array - beers
            }
        }
        do {
            try privateContext.execute(asyncFetchRequest)
        }
        catch {
            print("READ FROM COREDATA --  error: \(error)")
        }
    }
}
