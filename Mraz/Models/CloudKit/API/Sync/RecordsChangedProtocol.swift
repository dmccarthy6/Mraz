//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit
import CoreData

protocol CloudKitRecordsChanged: class, ReadFromCloudKit {
    func fetchChangedCloudKitRecord(by ckRecordID: CKRecord.ID)
}

extension CloudKitRecordsChanged {
    func fetchChangedCloudKitRecord(by ckRecordID: CKRecord.ID) {
        publicDatabase.fetch(withRecordID: ckRecordID) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let record = record else { return }
                self.fetchManagedObject(from: record)
            }
        }
    }
    
    // first fetch by beer name and update
    func fetchManagedObject(from record: CKRecord) {
        let changedObjectFetchRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        changedObjectFetchRequest.predicate = NSPredicate(format: "name == %@", record[.name] as! String)
    }
    
    // if no beer exists by that name, create it
    func createNewBeerRecord() {
        
    }
}

struct SyncCloudKitRecordChanges: ReadFromCloudKit {
    // MARK: - Properties
    var changedRecordName: String
    var changedRecordID: CKRecord.ID?
    
    //Assume it exists
    func fetchUpdatedObject<T: NSManagedObject>() -> T {
        let changedObjFR = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        changedObjFR.predicate = NSPredicate(format: "id == %@", changedRecordName)
        do {
            let updatedRecord = try self.mainThreadContext.fetch(changedObjFR) as? [T]
            guard let safeRecord = updatedRecord, safeRecord.count > 0 else {
                return T()
            }
            return safeRecord[0]
        } catch {
            createNewBeerRecord()
            return T()
        }
    }
    
    // if no beer exists by that name, create it
    func createNewBeerRecord() {
        
    }
    
    private func fetchCK() {
        guard let changedID = changedRecordID else { return }
        publicDatabase.fetch(withRecordID: changedID) { (addedRecord, error) in
            if let error = error {
                
            }
            
            
        }
    }
}
