//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import CloudKit
import CoreData

struct SyncCloudKitRecordChanges: ReadFromCloudKit {
    // MARK: - Types
    enum UpdatedRecordType {
        case updatedRecord
        case newRecord
    }
    
    // MARK: - Properties
    var changedRecordName: String
    var changedRecordID: CKRecord.ID

    /// Fetch updated record from CKNotification. Create new record if it doesn't exist in Core Data or Update the record if it does.
    func fetchUpdatedRecord() {
        publicDatabase.fetch(withRecordID: changedRecordID) { (addedRecord, error) in
            if let error = error {
                print("Error Fetching Record From CloudKit: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                guard let record = addedRecord,
                    let updatedBeer = self.fetchBeerBy(recordName: record.recordID.recordName) else {
                        if let record = addedRecord {
                            self.createNewBeer(from: record)
                        }
                        return
                }
                self.manage(object: updatedBeer, from: record, recordType: .updatedRecord)
            }
        }
    }
    
    // if no beer exists by that name, create it
    func createNewBeer(from record: CKRecord) {
        let newBeerObject = Beers(context: mainThreadManagedObjectContext)
        manage(object: newBeerObject, from: record, recordType: .newRecord)
    }
    
    func fetchBeerBy(recordName: String) -> Beers? {
        let changedBeerRequest = CoreDataFetchRequestFor(entityName: EntityName.beers.rawValue)
        changedBeerRequest.predicate = NSPredicate(format: "id == %@", recordName)
        do {
            let beers = try self.mainThreadManagedObjectContext.fetch(changedBeerRequest) as? [Beers]
            guard let safeBeers = beers, safeBeers.count > 0 else { return  nil}
            return safeBeers[0]
        } catch {
            return nil
        }
    }
    
    /// Take the CK Record passed in, update or create a beer record and 
    func manage(object: Beers, from record: CKRecord, recordType: UpdatedRecordType) {
        let tapStatus = record[.isOnTap] as? Int64 ?? 0
        let recordID = record.recordID.recordName//New Only
        let changeTag = record.recordChangeTag ?? "Error - No Change Tag"
        let section = record[.sectionType] as? String
        let name = record[.name] as? String ?? "Beer Name"
        let description = record[.description] as? String ?? ""
        let abv = record[.abv] as? String ?? "No ABV"
        let type = record[.type] as? String ?? "Beer Type"
        let createdDate = record.creationDate ?? Date()
        let modifiedDate = record.modificationDate ?? Date()
        let isOnTap = tapStatus.boolValue
        
        switch recordType {
        case.newRecord, .updatedRecord:
            object.abv = abv
            object.beerDescription = description
            object.beerType = type
            object.changeTag = changeTag
            object.ckCreatedDate = createdDate
            object.ckModifiedDate = modifiedDate
            object.id = recordID
            object.isOnTap = isOnTap
            object.name = name
            object.section = section
        }
        if object.isFavorite && object.isOnTap == true {
            let favoriteBeerNotification = FavoriteBeerNotifications(beer: object)
            favoriteBeerNotification.checkStatusSendNotification()
        }
        save(context: mainThreadManagedObjectContext)
    }
}
