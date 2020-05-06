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
    
    /// Check if initial CloudKit Fetch was successful, if so do not fetch again.
    func performInitialCloudKitFetch() {
        if !hasInitialFetchBeenPerformed() {
            fetchAllRecordsFromCloudKit(NSPredicate(value: true)) { (result) in
                switch result {
                case .success(true):
                    self.convertRecordsToBeerModelObjects()
                case .failure(let error):
                    print("CloudKitManager - Error: \(error)")
                case .success(false):()
                }
            }
        }
    }
    
    /// Create a CloudKit Query operation to fetch all beer objects from the database. This method
    /// is intented to be called 1 time by the user to get the initial fetch then cache to Core Data.
    /// - Returns: Result Type with Array of fetched CKRecords or Error.
    func fetchAllRecordsFromCloudKit(_ predicate: NSPredicate, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let allRecordsPred = NSPredicate(value: true)
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        ///Create Query
        let query = CKQuery(recordType: CKRecordType.beers, predicate: allRecordsPred)
        query.sortDescriptors = sortDescriptors
        ///Create OP
        let fetchAllOperation = CKQueryOperation(query: query)
        
        //Record Fetched Block
        fetchAllOperation.recordFetchedBlock = { record in
            self.records.append(record)
        }
        
        //Query Completion Block -- called when fetch completes.
        fetchAllOperation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                print("Error fetching CK: \(error)")
                completion(.failure(error))
            } else {
                guard self.records.count > 0 else { return }
                self.setFetchedValue(true)
                completion(.success(true))
            }
        }
        fetchAllOperation.resultsLimit = 200
        fetchAllOperation.qualityOfService = .utility
        publicDatabase.add(fetchAllOperation)
    }
    
    /// Take the CK Record values received from CloudKit and convert
    /// them into locak BeerModel' objects to be saved into Core Data.
    func convertRecordsToBeerModelObjects() {
        guard records.count > 0 else { return }
        self.convertCKRecordsToBeerModelObjects(records) { (result) in
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
    
    // MARK: - IF NOT USING, DELETE THESE METHODS
    
    // I DON'T THINK I'M KEEPING THIS -- HOLD FOR NOW.
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
    
    /// Use this method to fetch the beers that are 'onTap' for the home screen. NOT USED YET
//    func fetchOnTap(_ completion: @escaping (Result<[Beers], Error>) -> Void) {
//        let predicate = NSPredicate(format: "isOnTap == %@", 1)
//        fetchAllRecordsFromCloudKit(predicate) { (result) in
//            switch result {
//            case .success(let records):
//                print("RECR")
//
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    // MARK: - Helpers
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
