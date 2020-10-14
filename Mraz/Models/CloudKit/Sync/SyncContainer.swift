//  Created by Dylan  on 10/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

class SyncContainer: CloudKitSync {
    // MARK: - Properties
    let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: SyncContainer.self))
    private let ckManager = CloudKitManager()
    private let dbManager = CoreDataManager()
    private let mrazSettings = MrazSettings()
    private let workQueue = DispatchQueue(label: "MrazWorkContainer.Work", qos: .userInitiated)
    private let cloudQueue = DispatchQueue(label: "MrazSyncContainer.Cloud", qos: .userInitiated)
    private lazy var publicDB: CKDatabase = {
        return ckManager.publicCloudKitDatabase
    }()
    private(set) lazy var publicSubscriptionId: String = {
        return "\(MrazSyncConstants.publicSubID).subscription"
    }()
    private var createdPublicSubscription: Bool {
        get {
            return mrazSettings.readBool(for: .publicCKSubscriptionCreated)
        }
        set {
            mrazSettings.set(newValue, for: .publicCKSubscriptionCreated)
        }
    }
    
    // MARK: - Setup boilerplate
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
                self.ckManager.fetchRecords(NSPredicate(value: true), qos: .userInitiated, fetch: .initial) { (_) in
                    self.mrazSettings.set(true, for: .initialFetchSuccessful)
                }
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
    
    // MARK: - Handle CK Remote Notifications
    
    /// Method called when a remote notification is received from CloudKit.
    /// - Parameter modifiedRecordID: A CKRecord.ID to fetch from the CloudKit database
    func fetchRemoteChangedRecords(by modifiedRecordID: CKRecord.ID) {
        os_log("%{public}@", log: mrazLog, type: .debug, #function)
        
        publicDB.fetch(withRecordID: modifiedRecordID) { [weak self] (record, error) in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Failed to ", log: self.mrazLog, type: .error, String(describing: error))
                return
            }
            guard let changedRecord = record else { return }
            let recordName = changedRecord.recordID.recordName
            let recordNamePredicate = NSPredicate(format: "id == %@", recordName)
            let beer = Beers.findOrFetch(in: self.dbManager.mainContext, matching: recordNamePredicate)
//                self.dbManager.findManagedObject(matching: recordNamePredicate)
            let beerAlreadyExists = beer != nil
            DispatchQueue.main.async {
                beerAlreadyExists ?  self.handleModified(record: changedRecord, beer: beer!) : self.handleNew(record: changedRecord)
            }
        }
    }
    
    /// Creates a new ManagedObject from CKRecord.
    /// - Parameter record: The CKRecord object that was modified/created.
    func handleNew(record: CKRecord) {
        let newBeerManagedObj = Beers(context: dbManager.mainContext)
        let newBeerModel = BeerModel.createBeerModel(from: record, isFavorite: newBeerManagedObj.isFavorite)
        Beers.updateOrCreate(newBeerManagedObj, from: newBeerModel, in: dbManager.mainContext)
//        dbManager.createOrUpdateBeerObject(from: newBeerModel, beer: newBeerManagedObj, in: dbManager.mainThreadContext)
    }
    
    /// Method used when we receive a remote notification from an object that already
    /// exists in CoreData. This means a field has been updated on an existing object.
    /// - Parameter record: The CKRecord that was modified
    /// - Parameter beer: The ManagedObject with the same ID as the record parameter
    func handleModified(record: CKRecord, beer: Beers?) {
        os_log("%{public}@", log: mrazLog, type: .debug, #function)
        guard let updatedBeer = beer else { return }
        let localModBeer = BeerModel.createBeerModel(from: record, isFavorite: updatedBeer.isFavorite)
        Beers.updateOrCreate(updatedBeer, from: localModBeer, in: dbManager.mainContext)
        LocalNotificationManger().sendFavoriteBeerNotification(for: updatedBeer)
    }
}
