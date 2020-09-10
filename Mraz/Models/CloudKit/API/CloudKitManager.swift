//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

final class CloudKitManager: CloudKitAPI {
    // MARK: - Properties
    static let shared = CloudKitManager()
    lazy var publicCloudKitDatabase: CKDatabase = {
        let container = CKContainer(identifier: ContainerID.beers.rawValue)
        return container.publicCloudDatabase
    }()
    var defaultContainer = CKContainer.default()
    private var cloudKitChangeToken = "Mraz + \(UUID().uuidString)"
    private let settings: MrazSettings = MrazSettings()
    private lazy var currentCloudSubscriptionID = settings.readValue(for: .mrazCloudKitSubscriptionID) as? String
    var predicate: NSPredicate
    private var fetchedRecords: [CKRecord] = []
    private var beerModelObjects: [BeerModel] = []
    private let coreDataManager = CoreDataManager()
    
    // MARK: - Lifecycle
    init(predicate: NSPredicate = NSPredicate(value: true)) {
        self.predicate = predicate
    }
    
    // MARK: - Authorizations
    /// Checks the current iCloud status, performs initial fetch if logged in
    /// this method also subscribes to all changes for public database.
    func checkUserCloudKitAccountStatusAndSubscribe() {
        getUsersCurrentAuthStatus { (result) in
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
        subscribeToPublicDatabaseChanges()
    }
    
    // MARK: - CloudKit Fetch Methods
    /// Check if initial CloudKit Fetch was successful, if so do not fetch again.
    func performInitialCloudKitFetch() {
        if !hasInitialFetchBeenPerformed() {
            fetchRecordsFromCK(predicate, qualityOfService: .default)
        }
    }

    // MARK: - Helper Booleans -- Don't Delete
    /// Flag to check if the initial CK fetch has been performed.
    /// If this is true, no need to call CloudKit again. This data
    /// should hae been saved to local database.
    func hasInitialFetchBeenPerformed() -> Bool {
        return settings.readBool(for: .initialFetchSuccessful)
    }
    
    /// Set 'initialFetchSuccessful' value to true if successful.
    func setFetchedValue(_ bool: Bool) {
        settings.set(bool, for: .initialFetchSuccessful)
    }

    // MARK: - Subscriptions
    /// Checks if CK Subscription exists, if it doesn't creates subscriptiion.
    func subscribeToPublicDatabaseChanges() {
        publicCloudKitDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if error != nil {
                print("CloudKitManager - Error fetching CK Subscriptions: \(error!.localizedDescription)")
                return
            }
            if let subscriptions = subscriptions {
                guard subscriptions.count > 0 else {
                    self.addAllBeersSubscription()
                    return
                }
                subscriptions.forEach { (subscription) in
                    if subscription.subscriptionID == self.currentCloudSubscriptionID {
                        return
                    } else {
                        print("CloudKitManager - Adding Subscription")
                        self.addAllBeersSubscription()
                    }
                }
            }
        }
    }
    
    func addAllBeersSubscription() {
        deleteAllSubscriptionsFromCloudKit()
        let subscription = CKQuerySubscription(recordType: CKRecordType.beers,
                                               predicate: self.predicate,
                                               options: [.firesOnRecordUpdate, .firesOnRecordCreation])
        createCloudKit(subscription: subscription)
    }
    
    #warning("Delete if above works")
//    func subscribeToPublicDatabaseChanges() {
//        publicCloudKitDatabase.fetchAllSubscriptions { (subscriptions, error) in
//            if error != nil {
//                print("CloudKitManager - Error fetching CK Subscriptions: \(error!.localizedDescription)")
//                return
//            }
//            if let subscriptions = subscriptions {
//                guard subscriptions.count > 0 else {
//                    self.createSubscription(with: self.predicate)
//                    return
//                }
//                subscriptions.forEach { (subscription) in
//                    //Delete Sub
//                    //Create Sub?
//                    if subscription.subscriptionID == self.currentCloudSubscriptionID {
//                        print("CloudKitManager - Already have this subscription, returning gracefully!")
//                        return
//                    } else {
//                        print("CloudKitManager -- creating CK Subscription")
//                        self.createSubscription(with: self.predicate)
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - Fetching
    /// This method performs the initial CloudKit fetch when the app is first loaded. This method will only be called if
    /// the initial fetch performed user defaults key is set to false. All updates from CK are handle separately.
    /// - Parameter withPredicate: The NSPredicate value to use in the CKQuery. Use this to narrow down the query search.
    /// - Parameter qualityOfService: The quality of service to use for the CloudKit fetch.
    func fetchRecordsFromCK(_ withPredicate: NSPredicate, qualityOfService: QualityOfService) {
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let query = CKQuery(recordType: CKRecordType.beers, predicate: withPredicate)
        query.sortDescriptors = sortDescriptors
        let fetchAllRecordsOperation = CKQueryOperation(query: query)
        
        fetchAllRecordsOperation.recordFetchedBlock = { record in
            self.fetchedRecords.append(record)
        }
        fetchAllRecordsOperation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                #warning("Fatal Error - ")
                fatalError("Error Fetching CK Records \(error.localizedDescription)")
            }
            self.convertCKRecordsToBeerModelObjects()
            self.setFetchedValue(true)
        }
        fetchAllRecordsOperation.resultsLimit = 250
        fetchAllRecordsOperation.qualityOfService = qualityOfService
        publicCloudKitDatabase.add(fetchAllRecordsOperation)
    }
    
    // MARK: -
    func convertCKRecordsToBeerModelObjects() {
        for record in fetchedRecords {
            let beerObj = convertCloudRecordToBeerModel(record: record, isFav: false)
            beerModelObjects.append(beerObj)
        }
        saveConvertedObjectsToCoreData()
    }
    
    private func saveConvertedObjectsToCoreData() {
        for beer in beerModelObjects {
            CoreDataManager.shared.saveBeerObjectToCoreData(from: beer)
        }
    }
    
    // MARK: - Sync
    /// Method callec when CloudKit triggers a new record or record change.
    func fetchModifiedRecords(by ckRecordID: CKRecord.ID) {
        let coreDataManager = CoreDataManager.shared
        let mainContext = coreDataManager.mainThreadContext
        publicCloudKitDatabase.fetch(withRecordID: ckRecordID) { (updatedRecord, error) in
            if let error = error {
                print("Error fetching record from CloudKit: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                guard let record = updatedRecord else { return } //Does this make sense?
                guard let beer = coreDataManager.fetchUpdatedRecord(by: record.recordID.recordName) else {
                    // Creae a new object here, it doesn't exist in Core Data
                    let newBeerLocal = self.convertCloudRecordToBeerModel(record: record, isFav: false)
                    let newBeerObject = Beers(context: mainContext)
                    coreDataManager.createManagedObject(from: newBeerLocal, beer: newBeerObject, in: mainContext)
                    return
                }
                //Update object here, something from CK Triggered update
                print("\(beer.isFavorite)")
                let updatedBeer = self.convertCloudRecordToBeerModel(record: record, isFav: beer.isFavorite)
                coreDataManager.createManagedObject(from: updatedBeer, beer: beer, in: mainContext)
                LocalNotificationManger().sendFavoriteBeerNotification(for: beer)
            }
        }
    }
    
    func convertCloudRecordToBeerModel(record: CKRecord, isFav: Bool?) -> BeerModel {
        print("FAVORITE STATUS: \(isFav)")
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
