//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

typealias CloudKitAPI = ReadFromCloudKit & WriteToCloudKit

final class CloudKitManager: CloudKitAPI, CoreDataAPI, CloudKitRecordsChangedDelegate {
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
    
    ///
    func fetchUpdatedRecordsFromCloud() {
        let date = NSDate(timeInterval: <#T##TimeInterval#>, since: <#T##Date#>) // Date used minus 120 Minutes?
        let predicate = NSPredicate(format: <#T##String#>, <#T##args: CVarArg...##CVarArg#>)
        fetchFromCloudKit(<#T##withPredicate: NSPredicate##NSPredicate#>, qualityOfService: <#QualityOfService#>) { (result) in
            switch result {
            case .success(let fetchedRecords):
                //Remove current records values (if any) set the records to the fetchedRecords then convert
                // to BeerModel objects and save to Core Data.
                self.records.removeAll()
                self.records = fetchedRecords
                self.convertChangedRecordsToBeerObjects()
            case .failure(let error):
                //
                print(error)
            }
        }
    }
 
    // TO-DO: Should this return 'Beers' or should I create a new Core Data Entity that I'll use for the Home VC?
    /// Fetches list of beers that have the 'isOnTap' value set to true.
    /// - Parameter completion: Completion handler that returns a
    func fetchOnTapList(_ completion: @escaping (Result<[Beers], Error>) -> Void) {
        let onTapPredicate = NSPredicate(format: "isOnTap == %@", 1)
        fetchFromCloudKit(onTapPredicate, qualityOfService: .utility) { (result) in
            switch result {
            case .success(let ckRecords):
                // TO-DO: Convert these to Beer Model -> Core Data Objects
                print("Success")
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Syncing
    /// This method
    /// - Parameter date: The Date to use to fetch the CK Database.
    func seeIfThisWorks(date: Date) {
        func notificationReceived(_ notification: CKDatabaseNotification) {
            let type = notification.notificationType
            switch type {
            case .query:
                fetchFromCloudKit(<#T##withPredicate: NSPredicate##NSPredicate#>, qualityOfService: <#QualityOfService#>, <#T##completion: (Result<[CKRecord], Error>) -> Void##(Result<[CKRecord], Error>) -> Void#>)
                
            case .database, .readNotification, .recordZone: break
            @unknown default: ()
            }
        }
    }
    
    func notificationReceived(_ notification: CKDatabaseNotification) {
        <#code#>
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
                    self.createManagedObjectFrom(beer, in: self.mainThreadManagedObjectContext)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Updated records
    func convertChangedRecordsToBeerObjects() {
        guard records.count > 0 else { return }
        
        self.convertCKRecordsToBeerModelObjects(records) {[unowned self] (result) in
            switch result {
            case .success(let beerModelObjects):
                for object in beerModelObjects {
                    guard let objectID = self.getManagedObjectIDFrom(object.id) else { return }
                    let beerToUpdate = self.getBeerObjectFrom(objectID: objectID)
                    self.updateCurrentBeersObject(beer: beerToUpdate, from: object, in: self.mainThreadManagedObjectContext)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
 
    func convertCloudRecordsToLocalModelObjects() {
        guard records.count > 0 else { return }
        self.convertCKRecordsToBeerModelObjects(records) { [unowned self] (result) in
            switch result {
            case .success(let beerObjects):
                for beer in beerObjects {
                    if !self.hasInitialFetchBeenPerformed() {
                        self.createManagedObjectFrom(beer, in: self.mainThreadManagedObjectContext)
                    } else {
                        //Updating
                        guard let objectID = self.getManagedObjectIDFrom(beer.id) else { return }
                        let beerToUpdate = self.getBeerObjectFrom(objectID: objectID)
                        self.updateCurrentBeersObject(beer: beerToUpdate, from: beer, in: self.mainThreadManagedObjectContext)
                    }
                }
            case .failure(let error):
                // TO-DO: HANDLE THIS ERROR APPROPRIATELY
                print("CloudKitManager -- Encountered an error converting objects: \(error)")
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
