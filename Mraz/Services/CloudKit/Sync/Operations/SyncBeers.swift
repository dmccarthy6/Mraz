//  Created by Dylan  on 10/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit
import os.log

enum SyncType {
    case onTap, allBeers
}

final class SyncBeers {
    // MARK: - Properties
    private let coreDataManager: CoreDataManager
    
    private let cloudKitManager: CloudKitManager
    
    private let coreDataPredicate: NSPredicate
    
    private let cloudKitPredicate: NSPredicate
    
    lazy var cloudKitOperation = FetchCKRecodsOperation(cloudKitManager: cloudKitManager, predicate: cloudKitPredicate, syncType: syncType, managedObjectIDs: coreDataOperation.managedObjectIDs)
    
    lazy var coreDataOperation = FetchCoreDataOperation(predicate: coreDataPredicate, coreDataManager: coreDataManager)
    
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Sync Operation Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    let syncType: SyncType
    
    // MARK: - Lifecycle
    init(coreDataPredicate: NSPredicate, cloudKitPredicate: NSPredicate, syncType: SyncType, coreDataManager: CoreDataManager, ckManager: CloudKitManager) {
        self.coreDataPredicate = coreDataPredicate
        self.cloudKitPredicate = cloudKitPredicate
        self.coreDataManager = coreDataManager
        self.cloudKitManager = ckManager
        self.syncType = syncType
        
        addOperationsToQueue()
    }
    
    func addOperationsToQueue() {
        operationQueue.addOperations([coreDataOperation, cloudKitOperation], waitUntilFinished: false)
    }
    
    func performSync() {
        cloudKitOperation.completionBlock = {
            self.sync()
        }
    }
    
    private func sync() {
        let fetchedRecords = cloudKitOperation.fetchedRecords
        var coreDataIDs = coreDataOperation.managedObjectIDs
        
        fetchedRecords.forEach { (beerModel) in
            let currentRecordID = beerModel.id
            
            switch syncType {
            case .allBeers:
                
                coreDataManager.createBeerObjects(from: fetchedRecords)
                
            case .onTap:
                if coreDataIDs.contains(currentRecordID) {
                    coreDataIDs.remove(currentRecordID)
                }
                coreDataManager.updateOrCreateBeer(from: beerModel)
                
                coreDataIDs.forEach { (beerID) in
                    let predicate = NSPredicate(format: "id == %@", beerID)
                    guard let beer = Beers.findOrFetch(in: coreDataManager.context, matching: predicate) else { return }
                    let beerModel = BeerModel.createBeerModel(from: beer)
                    coreDataManager.update(beer, from: beerModel)
                }
            }
        }
    }
}
