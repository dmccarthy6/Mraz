//  Created by Dylan  on 10/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

protocol CKSyncDelegate: class {
    /// Save any remote changes that come in from CloudKit
    func saveRemoteChange(using record: CKRecord)
    
    /// Save the initial CloudKit fetch to the database.
    func saveBeersToDatabase(from model: [BeerModel])
}

class SyncContainer {
    // MARK: - Properties
    let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: SyncContainer.self))
    
    private let mrazSettings = MrazSettings()
    
    private let ckManager = CloudKitManager()
    
    private let workQueue = DispatchQueue(label: "MrazWorkContainer.Work", qos: .userInitiated)
    
    private let cloudQueue = DispatchQueue(label: "MrazSyncContainer.Cloud", qos: .userInitiated)
    
    weak var syncDelegate: CKSyncDelegate?
    
    lazy var publicDB: CKDatabase = {
        return ckManager.publicCloudKitDatabase
    }()
    
    private(set) lazy var publicSubscriptionId: String = {
        return "\(MrazSyncConstants.publicSubID).subscription"
    }()
    
    private var createdPublicSubscription: Bool {
        get { return mrazSettings.readBool(for: .publicCKSubscriptionCreated) }
        set { mrazSettings.set(newValue, for: .publicCKSubscriptionCreated)}
    }
    
    // MARK: - Setup
    private lazy var mrazCloudOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        
        queue.underlyingQueue = cloudQueue
        queue.name = "SyncContainer.Cloud"
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    // MARK: - Lifecycle
    init() {
        start()
    }
    
    private func start() {
        prepareCloudEnv { [weak self] in
            guard let self = self else { return }
            let ckFetchPerformed = self.mrazSettings.readBool(for: .initialFetchSuccessful)
            if !ckFetchPerformed {
                self.fetchCKRecordsAndSaveToDatabase()
                self.mrazSettings.set(true, for: .initialFetchSuccessful)
            }
        }
    }
    
    private func prepareCloudEnv(_ completion: @escaping () -> Void) {
        workQueue.async { [weak self] in
            guard let self = self else { return }
            self.createPublicSubscriptionsIfNeeded()
            self.mrazCloudOperationQueue.waitUntilAllOperationsAreFinished()
            guard self.createdPublicSubscription else { return }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    /// Performs CloudKit fetch and saves the records to Core Data.
    private func fetchCKRecordsAndSaveToDatabase() {
        ckManager.fetchRecords(qualityOfService: .userInitiated) {[weak self] records in
            guard let self = self else { return }
            self.syncDelegate?.saveBeersToDatabase(from: records)
        }
    }
    
    // MARK: - Subscriptions
    private func createPublicSubscriptionsIfNeeded() {
        guard !createdPublicSubscription else {
            os_log("Already subscribed to public database changes, skipping subscription but checking if it really exists",
                   log: mrazLog,
                   type: .debug)
            checkSubscription()
            return
        }
        
        let subscription = CKQuerySubscription(recordType: CKRecordType.beers,
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: publicSubscriptionId,
                                               options: [.firesOnRecordUpdate, .firesOnRecordCreation])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
                                                       subscriptionIDsToDelete: nil)
        
        operation.database = publicDB
        operation.qualityOfService = .userInitiated
        
        operation.modifySubscriptionsCompletionBlock = { [weak self] _, _, error in
            guard let self = self else { return }
            
            if let error = error {
                let currentCKStatus = CloudKitManager().ckAccountStatus
                if currentCKStatus != .available {
                    self.fetchCKRecordsAndSaveToDatabase()
                }
                os_log("Failed to create public CloudKit subscription: %{public}@",
                       log: self.mrazLog,
                       type: .error,
                       String(describing: error))
                
                error.retryCloudKitOperationIfSuggested(self.mrazLog) { self.createPublicSubscriptionsIfNeeded() }
            } else {
                os_log("Public subscription created successfully",
                       log: self.mrazLog,
                       type: .info)
                self.createdPublicSubscription = true
            }
        }
        mrazCloudOperationQueue.addOperation(operation)
    }
    
    /// Confirm that the subscription does esist.
    private func checkSubscription() {
        let operation = CKFetchSubscriptionsOperation(subscriptionIDs: [publicSubscriptionId])
        
        operation.fetchSubscriptionCompletionBlock = { [weak self] ids, error in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Failed to check for public zone subscription existence: %{public}@",
                       log: self.mrazLog,
                       type: .error, String(describing: error))
                
                if !error.retryCloudKitOperationIfSuggested(self.mrazLog, with: { self.checkSubscription() }) {
                    os_log("Irrecoverable error when fetching public zone subscription, assuming it doesn't exist: %{public}@",
                           log: self.mrazLog,
                           type: .error,
                           String(describing: error))
                    
                    DispatchQueue.main.async {
                        self.createdPublicSubscription = false
                        self.createPublicSubscriptionsIfNeeded()
                    }
                }
            } else if ids == nil || ids?.count == 0 {
                os_log("Public subscription reported as existing, but it doesn't exist. Creating.",
                       log: self.mrazLog,
                       type: .error)
                
                DispatchQueue.main.async {
                    self.createdPublicSubscription = false
                    self.createPublicSubscriptionsIfNeeded()
                }
            }
        }
        
        operation.qualityOfService = .userInitiated
        operation.database = publicDB
        
        mrazCloudOperationQueue.addOperation(operation)
    }
}
