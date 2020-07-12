//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

typealias CloudKitAPI = ReadFromCloudKit & WriteToCloudKit

final class CloudKitManager: CloudKitAPI, CoreDataAPI {
    // MARK: - Properties
    static let shared = CloudKitManager()
    var storage: Storage = Storage()
    var records: [CKRecord] = []
    
    // MARK: - CloudKit Fetch Methods
    /// Check if initial CloudKit Fetch was successful, if so do not fetch again.
    func performInitialCloudKitFetch() {
        if !hasInitialFetchBeenPerformed() {
            fetchAllBeersFromCloud { (result) in
                switch result {
                case .success(true), .success(false):
                    self.convertRecordsToBeerModelObjects()
                    
                case .failure(let error):
                    print("CloudKitManager: -- \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Perform the intial fetch from the CloudKit database. If successful, this method sets a UserDefaults flag
    ///
    /// - Parameter completion: Completion handler with a result type of Boolean. Returns true if successful fetch.
    func fetchAllBeersFromCloud(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        fetchFromCloudKit(NSPredicate(value: true), qualityOfService: .utility) { [unowned self] (result) in
            switch result {
            case .success(let ckRecords):
                self.records = ckRecords
                guard self.records.count > 0 else { return }
                self.setFetchedValue(true)
                completion(.success(true))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch any records that have been updated in the Public Database. This method uses
    /// the
    func fetchUpdatedRecordsFromCloud() {
        guard let objectID = modifiedDateObjectID() else { return }
        let fromDate = getLastModifiedFetchDate()
        let toDate = Date()
        print("CloudKitManager -- Fetching Objects From:\(fromDate!) to \(toDate)")

        let predicate = NSPredicate(format: "modificationDate >= %@ && modificationDate <= %@", fromDate! as NSDate, toDate as NSDate)
        fetchFromCloudKit(predicate, qualityOfService: .utility) { (result) in
            switch result {
            case .success(let fetchedRecords):
                //Remove current records values (if any) set the records to the fetchedRecords then convert
                // to BeerModel objects and save to Core Data.
                self.records.removeAll()
                self.records = fetchedRecords

                print("These are the records that have changes: \n \(fetchedRecords)")
                self.convertChangedRecordsToBeerObjects()
                self.updateLastModifiedDate(id: objectID)
            case .failure(let error):
                //
                print("CloudKitManager -- Error fetching updated records: \(error.localizedDescription)")

            }
        }
    }
 
    /// Fetches list of beers that have the 'isOnTap' value set to true.
    /// - Parameter completion: Completion handler that returns a
    func fetchOnTapList() {
        let onTapPredicate = NSPredicate(format: "isOnTap == %d", 1)
        fetchFromCloudKit(onTapPredicate, qualityOfService: .userInitiated) { (result) in
            switch result {
            case .success(let ckRecords):
                self.records.removeAll()
                self.records = ckRecords
                self.convertChangedRecordsToBeerObjects()
                // TO-DO: Convert these to Beer Model -> Core Data Objects
                print("CloudKitManager - Success fetching onTap FromCK")
            case .failure(let error):
                print("CloudKitManager: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    /// Take the CK Record values received from CloudKit and convert
    /// them into locak BeerModel' objects to be saved into Core Data.
    func convertRecordsToBeerModelObjects() {
        guard records.count > 0 else { return }
        self.convertCKRecordsToBeerModelObjects(records) {[unowned self] (result) in
            switch result {
            case .success(let beerModelObjects):
                for beer in beerModelObjects {
                    self.saveBeerObjectToCoreData(from: beer)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Use this method when CloudKit records are updated. This method searches for the ManagedObject with the 'recordName'
    /// matching the CKRecord's recordName.
    func convertChangedRecordsToBeerObjects() {
        guard records.count > 0 else { return }

        self.convertCKRecordsToBeerModelObjects(records) {[unowned self] (result) in
            switch result {
            case .success(let beerModelObjects):
                for object in beerModelObjects {
                    guard let objectID = self.getManagedObjectIDFrom(object.id) else {
                        //Create New Model Object -- it's not an update.
                        print("CloudKitManager -- This is a new object, not an update. Added: \(object.name)")
                        return
                    }
                    let beerToUpdate = self.getBeerObjectFrom(objectID: objectID)
                    self.updateCurrentBeersObject(beer: beerToUpdate, from: object, in: self.mainThreadManagedObjectContext)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    /// Flag to check if the initial CK fetch has been performed.
    /// If this is true, no need to call CloudKit again. This data
    /// should hae been saved to local database.
    func hasInitialFetchBeenPerformed() -> Bool {
        guard let hasFetched = storage.initialFetchSuccessful else {
            return false
        }
        return hasFetched
    }
    
    /// Set Initial fetch value
    func setFetchedValue(_ bool: Bool) {
        storage.initialFetchSuccessful = bool
    }
}
