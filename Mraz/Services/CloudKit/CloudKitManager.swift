//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import NotificationCenter
import CloudKit
import os.log

final class CloudKitManager: CloudKitAPI {
    // MARK: - Properties
    private let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: CloudKitManager.self))
    
    private let dbManager = CoreDataManager()
    
    private let settings: MrazSettings = MrazSettings()
    
    var predicate: NSPredicate

    var ckContainer: CKContainer
    
    lazy var publicCloudKitDatabase: CKDatabase = {
        return ckContainer.publicCloudDatabase
    }()
    
    private var beerModelObjects: [BeerModel] = []
    
    private(set) var ckAccountStatus: CKAccountStatus = .couldNotDetermine
    
    // MARK: - Lifecycle
    init(predicate: NSPredicate = NSPredicate(value: true), container: CKContainer = CKContainer(identifier: MrazSyncConstants.containerIdentifier)) {
        self.predicate = predicate
        self.ckContainer = container
    }

    // MARK: - Account Status
    /// Syncronous method uses ubiquityIdentityToken
    /// .
    func isUserLoggedIntoCloud(_ viewController: UIViewController, popoverDelegate: UIPopoverPresentationControllerDelegate) {
        if FileManager.default.ubiquityIdentityToken == nil {
           guard let ckAlertController = Alerts.buildCloudKitAlertController(with: .iCloudError,
                                                                       message: .userNotLoggedIn,
                                                                       popoverDelegate: popoverDelegate) else { return }
            viewController.present(ckAlertController, animated: true)
        }
    }
    
    /// Asyncronous CloudKit Account Status
    func requestCKAccountStatus() {
        ckContainer.accountStatus { (accountStatus, error) in
            if let error = error { print(error) }
            
            self.ckAccountStatus = accountStatus
        }
    }
    
    func setupAccountStatusChangedNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleStatusChange(_:)), name: Notification.Name.CKAccountChanged, object: nil)
    }
    
    @objc private func handleStatusChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.requestCKAccountStatus()
            
            if self.ckAccountStatus == .available {
                SyncContainer.init()
            }
        }
    }
    
    // MARK: - Fetching
    /// Uset his method to perform the initial CK fetch.
    func performInitialCKFetch() {
        let initialFetchPerformed = settings.readInitalFetchPerformed()
        initialFetchPerformed ? nil : fetchAllBeersFromCK()
    }
    
    /// Perform initial CK Fetch. This method fetches all beers from CK.
    private func fetchAllBeersFromCK() {
        let truePred = NSPredicate(value: true)
        fetchRecords(truePred, qos: .userInitiated, fetch: .initial, nil)
    }
    
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
        fetchAllRecordsOperation.queryCompletionBlock = {  (cursor, error) in //[weak self]
            if let error = error {
                os_log("Error fetching CloudKit Records: %@", log: self.mrazLog, type: .error, error.localizedDescription)
            }
            switch fetch {
            case .initial:
                self.convertCKRecordsToBeerModelObjects(from: fetchedRecords)
                self.settings.setInitialFetch(true)
                self.settings.setLastSyncDate(date: Date())
            case .subsequent:
                completion?(fetchedRecords)
            }
        }
        fetchAllRecordsOperation.resultsLimit = 250
        fetchAllRecordsOperation.qualityOfService = qos
        publicCloudKitDatabase.add(fetchAllRecordsOperation)
    }
    
    // MARK: - Helpers
   
    /// Iterates ckRecords parameter and converts the objects to local 'BeerModel' objects.
    /// - Parameter ckRecords: Array of CloudKit record objects.
    func convertCKRecordsToBeerModelObjects(from ckRecords: [CKRecord]) {
        for record in ckRecords {
            let beerModel = BeerModel.createBeerModel(from: record, isFavorite: false)
            beerModelObjects.append(beerModel)
        }
        beerModelObjects.forEach { (beer) in
            dbManager.saveNewBeerToDatabase(from: beer)
        }
    }
}
