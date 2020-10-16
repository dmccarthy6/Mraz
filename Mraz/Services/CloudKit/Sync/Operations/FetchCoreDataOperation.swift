//  Created by Dylan  on 10/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData
import os.log

final class FetchCoreDataOperation: Operation {
    // MARK: - Properties
    private let log = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: FetchCoreDataOperation.self))
    var fetchedBeers: [Beers]
    var managedObjectIDs = Set<String>()
    
    private let predicate: NSPredicate
    private let coreDataManager: CoreDataManager
    
    // MARK: - Lifecycle
    init(predicate: NSPredicate, coreDataManager: CoreDataManager) {
        self.predicate = predicate
        self.coreDataManager = coreDataManager
        
        fetchedBeers = []
        super.init()
    }
    
    override func main() {
        os_log("Main Hit %@", log: log, type: .debug, #function)
        fetchCoreDataObjects()
    }
    
    private func fetchCoreDataObjects() {
        let beers = coreDataManager.fetchManagedObject(by: predicate)
        
        beers.forEach { (beer) in
            guard let id = beer.id else { return }
            managedObjectIDs.insert(id)
        }
        
        fetchedBeers = beers
    }
}
