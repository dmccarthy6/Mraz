//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

struct SyncCloudKitChanges {
    // MARK: - Properties
    static var shared = SyncCloudKitChanges()
    private let cloudKitManager = CloudKitManager.shared
    private let databaseManager = CoreDataManager.shared
    let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: SyncCloudKitChanges.self))
    
    // MARK: - On Tap
    func performOnTapSyncOperation() {
        let group = DispatchGroup()
        var records = [String: CKRecord]()
        
        group.enter()
        getCurrentOnTapFromCK { (cloudDict) in
            records = cloudDict
            group.leave()
        }
        
        group.notify(queue: .main) {
            getCurrentOnTapFromDatabase(cloudKitRecords: records)
        }
    }
    
    private func getCurrentOnTapFromCK(_ completion: @escaping ([String: CKRecord]) -> Void) {
        var cloudOnTapDict: [String: CKRecord] = [:]
        
        let onTapPredicate = NSPredicate(format: "isOnTap == %i", 1)
        cloudKitManager.fetchRecords(onTapPredicate, qos: .default, fetch: .subsequent) { (records) in
            records.forEach { (record) in
                let recordID = record.recordID.recordName
                cloudOnTapDict[recordID] = record
            }
            completion(cloudOnTapDict)
        }
    }
    
    private func getCurrentOnTapFromDatabase(cloudKitRecords: [String: CKRecord]) {
        var onTapDict: [String: Beers] = [:]
        let predicate = NSPredicate(format: "isOnTap == %d", true)
        let localOnTapBeers = databaseManager.fetchManagedObject(by: predicate)
        var newBeers = [CKRecord]()
        
        // Check if Core Data object 'onTap' value is true.
        // if it is, and it's not included in the CK Array, change status.
        for localBeer in localOnTapBeers {
            guard let localBeerID = localBeer.id else { return }
            
            if cloudKitRecords[localBeerID] == nil {
                databaseManager.changeLocalOnTapStatus(for: localBeer.objectID)
            } else {
                onTapDict[localBeerID] = localBeer
            }
        }
        
        //Check
        for (key, record) in cloudKitRecords {
            if onTapDict[key] == nil {
                // if this value is true, all the vals match (name, ID, description, etc.)
                let beer = databaseManager.fetchCoreDataObject(by: key)
                
                if let safeBeer = beer {
                    let recordsMatch = databaseManager.validateBeerFieldsFrom(record: record,
                                                                              beer: safeBeer)
                    if recordsMatch {
                        databaseManager.changeLocalOnTapStatus(for: safeBeer.objectID)
                    } else {
                        let beerModel = cloudKitManager.generateLocalModelFrom(record: record, isFav: safeBeer.isFavorite)
                        databaseManager.saveModifiedBeerToDatabase(beer: safeBeer,
                                                                   model: beerModel,
                                                                   context: databaseManager.mainThreadContext)
                    }
                } else {
                    os_log("Adding this beer to Core Data: %@", log: self.mrazLog, type: .default, record[.name] as! CVarArg)
                    newBeers.append(record)
                }
            }
        }
        cloudKitManager.convertCKRecordsToBeerModelObjects(from: newBeers)
    }
}
