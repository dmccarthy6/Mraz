//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

final class BeersViewModel: CoreDataAPI {
    // MARK: - Properties
    var mainContext: NSManagedObjectContext? = nil
    private (set) var beersData = [Beers]()
    
    // MARK: -
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    
    // MARK: -
//    func setDataSource() {
//        CloudKitManager.shared.fetchBeerListFromCloud { (result) in
//            switch result {
//            case .success(let beers):
//                //
//                self.beersData = beers
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
//    func configureFetchedResultsController(for entity: EntityName, key: String?, ascending: Bool = true) -> NSFetchedResultsController<NSFetchRequestResult> {
//        let sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
//        let fetchRequest = CoreDataFetchRequestFor(entityName: entity.rawValue)
//        fetchRequest.predicate = NSPredicate(value: true)
//        fetchRequest.sortDescriptors = sortDescriptors
//        
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                              managedObjectContext: self.mainThreadManagedObjectContext,
//                                                              sectionNameKeyPath: nil,
//                                                              cacheName: nil)
//        do {
//            try fetchedResultsController.performFetch()
//            updateSnapshot()
//        } catch {
//            print(error)
//        }
//    }
}
