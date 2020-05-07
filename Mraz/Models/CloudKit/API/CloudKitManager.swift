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
            performCloudKitFetch(date: nil) { (result) in
                switch result {
                case .success(true), .success(false):
                    self.convertRecordsToBeerModelObjects()
                    
                case .failure(let error):
                    print("CloudKitManager: -- \(error.localizedDescription)")
                }
            }
//            fetchAllRecordsFromCloudKit(NSPredicate(value: true)) { (result) in
//                switch result {
//                case .success(true):
//                    self.convertRecordsToBeerModelObjects()
//                case .failure(let error):
//                    print("CloudKitManager - Error: \(error)")
//                case .success(false):()
//                }
//            }
        }
    }
    
    /// This method checks if the initial fetch has already performed, if not performs it. If fetch initial fetch happend it checks for any
    /// updated records.
    /// - Parameter date: Date that represents the 'modifiedDate' value to check against.
    /// - Parameter completion: Completion handler
    func performCloudKitFetch(date: Date?, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        if !hasInitialFetchBeenPerformed() {
            performInitialCloudKitFetch(NSPredicate(value: true)) { (result) in
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
        } else {
            guard let modifiedDate = date else { return }
            getChangedRecordsSince(modifiedDate) { (result) in
                switch result {
                case .success(let ckRecords):
                    self.records.removeAll()
                    self.records = ckRecords
                    self.convertRecordsToBeerModelObjects()
                    completion(.success(true))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
//    /// Create a CloudKit Query operation to fetch all beer objects from the database. This method
//    /// is intented to be called 1 time by the user to get the initial fetch then cache to Core Data.
//    /// - Parameter predicate: NSPredicate value
//    /// - Returns: Result Type with Array of fetched CKRecords or Error.
//    func fetchAllRecordsFromCloudKit(_ predicate: NSPredicate, _ completion: @escaping (Result<Bool, Error>) -> Void) {
//        let allRecordsPred = NSPredicate(value: true)
//        performInitialCloudKitFetch(allRecordsPred) { (result) in
//            switch result {
//            case .success(let fetchedRecords):
//                self.records = fetchedRecords
//                guard self.records.count > 0 else { return }
//                self.setFetchedValue(true)
//                completion(.success(true))
//
//            case .failure(let ckError):
//                completion(.failure(ckError))
//            }
//        }
//    }
//
//    /// Perform the fetch for changed records -- query by Modified Date
//    func fetchUpdatedRecordsSince(date: Date) {
//        getChangedRecordsSince(date) { (result) in
//            switch result {
//            case .success(let updatedRecords):
//                self.records.removeAll()
//                self.records = updatedRecords
//                self.convertRecordsToBeerModelObjects()
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    // Will Plan To Use This for Fetching Only On Tap Items for Home VC
    func fetchOnTapList(_ completion: @escaping (Result<[Beers], Error>) -> Void) {
        let onTapPredicate = NSPredicate(format: "isOnTap == %@", 1)
        let sortDescriptor = [NSSortDescriptor(key: "beerName", ascending: true)]
        let query = CKQuery(recordType: CKRecordType.beers, predicate: onTapPredicate)
        query.sortDescriptors = sortDescriptor
        
        //Create operation
        let onTapOp = CKQueryOperation(query: query)
        
        onTapOp.recordFetchedBlock = { record in
            
        }
        onTapOp.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                //Fetch On Tap Beers
                //Call Success on Completion Handler here
            }
        }
        publicDatabase.add(onTapOp)
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
