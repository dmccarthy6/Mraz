//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import NotificationCenter
import CloudKit
import os.log

final class CloudKitManager: CloudKitAPI {
    // MARK: - Properties
    private let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: CloudKitManager.self))
    
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
    /// Performs a CloudKit Fetch matching the predicate provided.
    /// - Parameter predicate: Predicate value to search CloudKit records.
    /// - Parameter qualityOfService: The CK Quality of service value to use
    /// - Parameter completion: Completion Handler that returns array of BeerModel objects upon completion.
    func fetchRecords(matching predicate: NSPredicate = NSPredicate(value: true), qualityOfService: QualityOfService, completion: @escaping ([BeerModel]) -> Void) {
        var fetchedBeerRecords: [CKRecord] = []
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let ckQuery = mrazCloudKitQuery(predicate: predicate, sortDescriptors: sortDescriptors)
        
        let fetchOperation = CKQueryOperation(query: ckQuery)
        
        fetchOperation.recordFetchedBlock = { record in
            fetchedBeerRecords.append(record)
        }
        
        fetchOperation.queryCompletionBlock = { [weak self] cursor, error in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Error fetching Records from CK %@", log: self.mrazLog, type: .error, error.localizedDescription)
            }
            
            let alreadyFetched = self.settings.readInitalFetchPerformed()
            
            if !alreadyFetched {
                self.settings.setInitialFetch(true)
            }

            self.settings.setLastSyncDate(date: Date())
            let beerModelObjects = self.buildBeerModel(from: fetchedBeerRecords)
            completion(beerModelObjects)
        }
        
        fetchOperation.resultsLimit = 250
        fetchOperation.qualityOfService = qualityOfService
        publicCloudKitDatabase.add(fetchOperation)
    }
    
    // MARK: - Helpers
    /// Take initia array of CK records from fetch and create
    /// - Parameter records: Array of CKRecord objects
    /// - Returns: Array of Beer Model objects
    func buildBeerModel(from records: [CKRecord]) -> [BeerModel] {
        var modelBeers: [BeerModel] = []
        
        records.forEach { record in
            let beerModel = BeerModel.createBeerModel(from: record, isFavorite: false)
            modelBeers.append(beerModel)
        }
        return modelBeers
    }
}
