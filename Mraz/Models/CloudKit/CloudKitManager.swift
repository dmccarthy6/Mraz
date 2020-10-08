//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit
import os.log

final class CloudKitManager: CloudKitAPI {
    // MARK: - Properties
    static let shared = CloudKitManager()
    
    private var mrazSyncContainer: SyncContainer?
    private let dbManager = CoreDataManager()
    private let settings: MrazSettings = MrazSettings()
    private let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: CloudKitManager.self))
    var predicate: NSPredicate
    
    private var beerModelObjects: [BeerModel] = []
    
    lazy var publicCloudKitDatabase: CKDatabase = {
        let container = CKContainer(identifier: MrazSyncConstants.containerIdentifier)
        return container.publicCloudDatabase
    }()
    
    lazy var defaultContainer: CKContainer = {
        return CKContainer.default()
    }()
    
    // MARK: - Lifecycle
    init(predicate: NSPredicate = NSPredicate(value: true)) {
        self.predicate = predicate
    }
    
    // MARK: - Authorizations
    /// RIGHT NOW CALLED IN APP DEL, COMMENTED. I MAY NOT NEED TO CHECK USERS STATUS AT ALL
//    func checkUserCloudKitAccountStatusAndSubscribe() {
//        getUsersCurrentAuthStatus { (result) in
//            switch result {
//            case .success(let currentCKStatus):
//                switch currentCKStatus {
//                case .available: self.fetchAndSubscribe()
//                case .couldNotDetermine, .noAccount:
//                    self.fetchAndSubscribe()
//                    DispatchQueue.main.async {
//                        Alerts.cloudKitAlert(title: .iCloudError, message: .noAccountOrCouldNotDetermine)
//                    }
//                case .restricted:
//                    DispatchQueue.main.async {
//                        Alerts.cloudKitAlert(title: .iCloudError, message: .restricted)
//                    }
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    Alerts.cloudKitErrorAlert(error)
//                }
//            }
//        }
//    }

    // MARK: - Helper Booleans
    /// Flag to check if the initial CK fetch has been performed.
    func hasInitialFetchBeenPerformed() -> Bool {
        return settings.readBool(for: .initialFetchSuccessful)
    }
    
    // MARK: - Fetching
    /// This method performs the initial CloudKit fetch when the app is first loaded. This method will only be called if
    /// the initial fetch performed user defaults key is set to false. All updates from CK are handle separately.
    /// - Parameter withPredicate: The NSPredicate value to use in the CKQuery. Use this to narrow down the query search.
    /// - Parameter qualityOfService: The quality of service to use for the CloudKit fetch.
    func fetchRecords(_ predicate: NSPredicate, qos: QualityOfService, fetch: FetchType, _ completion: (([CKRecord]) -> Void)?) {
        var fetchedRecords: [CKRecord] = []
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let query = mrazCloudKitQuery(predicate: predicate, sortDescriptors: sortDescriptors)
        let fetchAllRecordsOperation = CKQueryOperation(query: query)
        
        fetchAllRecordsOperation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }
        fetchAllRecordsOperation.queryCompletionBlock = { [weak self] (cursor, error) in
            guard let self = self else { return }
            if let error = error {
                os_log("Error fetching CloudKit Records: %@", log: self.mrazLog, type: .error, error.localizedDescription)
            }
            switch fetch {
            case .initial:
                self.convertCKRecordsToBeerModelObjects(from: fetchedRecords)
                self.setFetchedValue(true)
            case .subsequent:
                completion?(fetchedRecords)
            }
        }
        fetchAllRecordsOperation.resultsLimit = 250
        fetchAllRecordsOperation.qualityOfService = qos
        publicCloudKitDatabase.add(fetchAllRecordsOperation)
    }
    
    // MARK: - Helpers
    /// Set User Defaults value for 'initialFetchSuccessful'
    func setFetchedValue(_ bool: Bool) {
        settings.set(bool, for: .initialFetchSuccessful)
    }
    
    /// Iterates ckRecords parameter and converts the objects to local 'BeerModel' objects.
    /// - Parameter ckRecords: Array of CloudKit record objects.
    func convertCKRecordsToBeerModelObjects(from ckRecords: [CKRecord]) {
        for record in ckRecords {
            let beerObj = generateLocalModelFrom(record: record, isFav: false)
            beerModelObjects.append(beerObj)
        }
        beerModelObjects.forEach { (beer) in
            dbManager.saveNewBeerToDatabase(from: beer)
        }
    }
    
    /// Takes in a CloudKit Record object and converts it to and returns a local Beer Model object
    /// - Parameter record: CKRecord object to create a local 'Beer Model' object out of
    /// - Parameter isFav: Optional boolean value. Set this to the Core Data isFav if the beer already exists
    func generateLocalModelFrom(record: CKRecord, isFav: Bool?) -> BeerModel {
        let isTap = record[.isOnTap] as? Int64 ?? 0
        let recordID =          record.recordID.recordName
        let changeTag =         record.recordChangeTag ?? ""
        let section =           record[.sectionType] as? String ?? ""
        let name =              record[.name] as? String ?? ""
        let description =       record[.description] as? String ?? ""
        let beerABV =           record[.abv] as? String ?? ""
        let type =              record[.type] as? String ?? ""
        let createdDate =       record.creationDate ?? Date()
        let modifiedDate =      record.modificationDate ?? Date()
        let isFavorite =        isFav ?? false
        let isOnTap =           isTap.boolValue
        
        let beerModel = BeerModel(id: recordID,
                  section: section,
                  changeTag: changeTag,
                  name: name,
                  beerDescription: description,
                  abv: beerABV,
                  type: type,
                  createdDate: createdDate,
                  modifiedDate: modifiedDate,
                  isOnTap: isOnTap,
                  isFavorite: isFavorite)
        return beerModel
    }
}
