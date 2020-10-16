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
    private lazy var coreDataManager = CoreDataManager()
    
    private lazy var cloudKitManager = CloudKitManager()
    
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
    init(coreDataPredicate: NSPredicate, cloudKitPredicate: NSPredicate, syncType: SyncType) {
        self.coreDataPredicate = coreDataPredicate
        self.cloudKitPredicate = cloudKitPredicate
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
        
        fetchedRecords.forEach { (recoord) in
            let currentRecordID = recoord.recordID.recordName
            
            switch syncType {
            case .allBeers:
                updateOrCreateBeerFrom(record: recoord)
                
            case .onTap:
                if coreDataIDs.contains(currentRecordID) {
                    coreDataIDs.remove(currentRecordID)
                }
                updateOrCreateBeerFrom(record: recoord)
                
                coreDataIDs.forEach { (beerID) in
                    updateLocal(beer: beerID)
                }
            }
        }
    }
    
    // MARK: - Helpers
    /// Updates managed ojbect if it exists locally, if not creates it.
    private func updateOrCreateBeerFrom(record: CKRecord) {
        guard let beerExistsLocally = Beers.findOrFetch(in: coreDataManager.mainContext, matching: coreDataPredicate) else {
            let newBeer = Beers(context: coreDataManager.mainContext)
            let newBeerModel = BeerModel.createBeerModel(from: record, isFavorite: newBeer.isFavorite)
            Beers.updateOrCreate(newBeer, from: newBeerModel)
            return
        }
        
        let beerModel = BeerModel.createBeerModel(from: beerExistsLocally)
        Beers.updateOrCreate(beerExistsLocally, from: beerModel)
    }
    
    /// Update local beer object
    private func updateLocal(beer withID: String) {
        let predicate = NSPredicate(format: "id == %@", withID)
        guard let beer = Beers.findOrFetch(in: coreDataManager.mainContext, matching: predicate) else { return }
        let beerModel = BeerModel.createBeerModel(from: beer)
        Beers.updateOrCreate(beer, from: beerModel)
    }
}
