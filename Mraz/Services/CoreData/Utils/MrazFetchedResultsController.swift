//  Created by Dylan  on 10/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import os.log

typealias MrazFRC = NSFetchedResultsController<Beers>

struct MrazFetchResultsController {
    // MARK: - Properties
    private static let frcLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: MrazFetchResultsController.self))
    
    static func configureMrazFetchedResultsController(for entity: EntityName,
                                                      matching predicate: NSPredicate,
                                                      in context: NSManagedObjectContext,
                                                      key: String = "name",
                                                      ascending: Bool = true) -> MrazFRC {
        let beersFetchRequest = Beers.sortedFetchRequest
        beersFetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: true)]
        beersFetchRequest.predicate = predicate
        beersFetchRequest.returnsObjectsAsFaults = false
        beersFetchRequest.fetchBatchSize = 25
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: beersFetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            os_log("Error fetching %@", log: self.frcLog, type: .error, error.localizedDescription)
        }
        return fetchedResultsController
    }
}
