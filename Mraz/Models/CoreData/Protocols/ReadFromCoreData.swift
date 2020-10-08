//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
//import CloudKit

protocol ReadFromCoreData {
    var frcPredicate: NSPredicate? { get set }
    
    func configureFetchedResultsController(for entity: EntityName,
                                           key: String?,
                                           ascending: Bool) -> MrazFetchedResultsController
    func getObjectBy<T: NSManagedObject>(_ objectID: NSManagedObjectID) -> T?
}
