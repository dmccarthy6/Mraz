//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

final class CloudKitManager: CloudKitAPI, CoreDataAPI {
    // MARK: - Properties
    static let shared = CloudKitManager()
    let settings: MrazSettings = MrazSettings()
    var records: [CKRecord] = []
    
    // MARK: - Authorizations
    /// Checks the user's current iCloud status, if available performs the initial fetch
    /// and subscribes to all beer changes.
    func checkUserCloudKitAccountStatusAndSubscribe() {
        getUserAccountStatus { (result) in
            switch result {
            case .success(let currentCKStatus):
                switch currentCKStatus {
                case .available: self.fetchAndSubscribe()
                case .couldNotDetermine, .noAccount:
                    self.fetchAndSubscribe()
                    DispatchQueue.main.async {
                        Alerts.cloudKitAlert(title: .iCloudError, message: .noAccountOrCouldNotDetermine)
                    }
                case .restricted:
                    DispatchQueue.main.async {
                        Alerts.cloudKitAlert(title: .iCloudError, message: .restricted)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    Alerts.cloudKitErrorAlert(error)
                }
            }
        }
    }
    
    /// Helper method that performs the initial fetch
    /// and subscribes to CK record changes.
    func fetchAndSubscribe() {
        performInitialCloudKitFetch()
        subscribeToBeerChanges()
    }
    
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

    /// Flag to check if the initial CK fetch has been performed.
    /// If this is true, no need to call CloudKit again. This data
    /// should hae been saved to local database.
    func hasInitialFetchBeenPerformed() -> Bool {
        return settings.readBool(for: .initialFetchSuccessful)
    }
    
    /// Set Initial fetch value
    func setFetchedValue(_ bool: Bool) {
        settings.set(bool, for: .initialFetchSuccessful)
    }
}
