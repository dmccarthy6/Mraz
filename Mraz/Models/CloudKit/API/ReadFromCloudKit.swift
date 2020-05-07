//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

protocol ReadFromCloudKit {
    func getUserAccountStatus(completion: @escaping (Result<CloudKitStatus, CloudKitStatusError>) -> Void)
}

extension ReadFromCloudKit {
    var publicDatabase: CKDatabase {
        let container = CKContainer(identifier: ContainerID.beers.rawValue)
        let database = container.publicCloudDatabase
        return database
    }
    
    var ckContainer: CKContainer {
        return CKContainer.default()
    }
    
    var cloudKitChangeToken: String {
        return "Mraz + \(UUID().uuidString)"
    }
    
    // MARK: - Check Account Status
    
    /// Check the users iCloud Account Status
    /// - Returns: Result type with a CloudKit Status enum value and a CloudKitError enum value.
    func getUserAccountStatus(completion: @escaping (Result<CloudKitStatus, CloudKitStatusError>) -> Void) {
        ckContainer.accountStatus { (status, error) in
            if error != nil {
                completion(.failure(.failedConnection))
                return
            }
            
            switch status {
            case .available://Logged in -- good to go
                completion(.success(.available))
            case .noAccount: //User Not Logged In
                completion(.success(.noAccount))
            case .couldNotDetermine://For some reason status couldn't be determined, try again
                completion(.success(.couldNotDetermine))
            case .restricted://iCloud settings restricted by parental controls or configuration profile
                completion(.success(.restricted))
            default: ()
            }
        }
    }
    
    // MARK: - User Information Methods
    /// Request the user's permission to access their record from CK
    func requestPermission() {
        ckContainer.requestApplicationPermission(.userDiscoverability) { (status, error) in
            guard status == .granted, error == nil else {
                // Handle error if needed
                return
            }
            let currentUserID = self.getUserID()
            self.ckContainer.discoverUserIdentity(withUserRecordID: currentUserID) { (identity, error) in
                guard let components = identity?.nameComponents, error == nil else {
                    //Handle Error
                    return
                }
                
                DispatchQueue.main.async {
                    let usersFullName = PersonNameComponentsFormatter().string(from: components)
                    print("ReadFromCK -- Here's the user's fullName: \(usersFullName)")
                }
            }
        }
    }
    
    /// Get the user's CKRecord ID
    private func getUserID() -> CKRecord.ID {
        var fetchedUserRecordID = CKRecord.ID()
        ckContainer.fetchUserRecordID { (userRecordID, error) in
            guard let userID = userRecordID, error == nil else {
                return
            }
            fetchedUserRecordID = userID
        }
        return fetchedUserRecordID
    }
    
    /// Use the user's CKRecord,ID to fetch the user info
    func getUserRecord() -> CKRecord {
        let userRecordID = getUserID()
        var userRecord: CKRecord?
        
        ckContainer.publicCloudDatabase.fetch(withRecordID: userRecordID) { (record, error) in
            guard let record = record, error == nil else {
                return
            }
            userRecord = record
            print("The user record is: \(record)")
        }
        return userRecord!
    }
    
    // MARK: - Subscriptions
    /// Create the CloudKit Subscription on Beers values
    func subscribeToBeerChanges() {
        publicDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if error != nil {
                print("Error fetching CK Subscriptions: \(error!.localizedDescription)")
                return
            }
            guard let validSubscriptions = subscriptions else { return }
            for subscription in validSubscriptions {
                let subscriptionExists = UserDefaults.standard.value(forKey: Key.cloudSubscription.rawValue)
                if subscription.subscriptionID ==  subscriptionExists as? String {
                    print("ReadFromCK -- We Already Have That Subscription!")
                } else {
                    print("ReadFromCK -- Creating Beers Subscription")
                    self.createBeersSubscription()
                }
            }
        }
    }
    
    /// Create the CKQuerySubscription and save to the public CloudKit database. Subscription fires on
    /// record creation or record update. 
    private func createBeersSubscription() {
        let predicate = NSPredicate(value: true)
        
        ///Flush out existing subscrptions
        deleteAllSubscriptionsFromCloudKit()
        
        //Create the New subscription
        let subscription = CKQuerySubscription(recordType: CKRecordType.beers,
                                               predicate: predicate,
                                               options: [.firesOnRecordUpdate, .firesOnRecordCreation])
        
        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        //Save subscription to database
        createCKSubscription(subscription)
    }
    
    /// Delete all  current subscriptions from CloudKit to reduce
    /// the possibilty of adding a subscription mroe than once.
    private func deleteAllSubscriptionsFromCloudKit() {
        publicDatabase.fetchAllSubscriptions { (subscription, error) in
            if error == nil {
                if let subscription = subscription {
                    for subscription in subscription {
                        self.publicDatabase.delete(withSubscriptionID: subscription.subscriptionID) { (str, error) in
                            
                            if error != nil {
                                //TO-DO: Error Handling
                                print("ReadFromCK -- Error deleting subscription: \(String(describing: error?.localizedDescription))")
                            }
                        }
                    }
                }
            } else {
                print(error)
                //TO-DO: Error Handling
            }
        }
    }
    
    /// Private helper method that takes in the CKSubscription and adds that subscription to the database.
    /// - Parameter subscription: CKSubscription value.
    private func createCKSubscription(_ subscription: CKSubscription) {
        let notificationInfo = CKSubscription.NotificationInfo()
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.save(subscription) { (ckSubscription, error) in
            if let error = error {
                print("ReadFromCloudKit -- Error saving subscription: \(error.localizedDescription)")
            } else {
                let userDef = UserDefaults.standard
                let subscriptionID = ckSubscription?.subscriptionID
                userDef.set(subscriptionID, forKey: Key.cloudSubscription.rawValue)
                print("ReadFromCloudKit -- CK Subscription Saved Successfully!")
            }
        }
    }
    
    // MARK: - Fetching
    /// Perform the initial CloudKit fetch for the ''Beers' entity.
    /// - Parameter withPredicate: NSPredicate value used on the CKQuery.
    /// - Parameter completion:
    func performInitialCloudKitFetch(_ withPredicate: NSPredicate, _ completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let query = CKQuery(recordType: CKRecordType.beers, predicate: withPredicate)
        query.sortDescriptors = sortDescriptors
        var fetchedRecords = [CKRecord]()
        
        //Oper
        let fetchAllOperation = CKQueryOperation(query: query)
        fetchAllOperation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }
        fetchAllOperation.queryCompletionBlock = { (cursor, error) in
            if let error = error as? CKError {
                completion(.failure(error))
            } else {
                guard fetchedRecords.count > 0 else { return }
                completion(.success(fetchedRecords))
            }
        }
        fetchAllOperation.resultsLimit = 250
        fetchAllOperation.qualityOfService = .utility
        publicDatabase.add(fetchAllOperation)
    }
    
    /// Fetch Updated CK Records. This will be called when remote notification is received
    /// - Parameter modifiedDate: Date value representing the last modified date.
    /// - Parameter completion: Completion handler returning a Result type of [CKRecord] and Error.
    func getChangedRecordsSince(_ modifiedDate: Date, _ completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let predicate = NSPredicate(format: "modifiedAt == %@", modifiedDate as CVarArg)
        let query = CKQuery(recordType: CKRecordType.beers, predicate: predicate)
        let fetchUpdatesOperation = CKQueryOperation(query: query)
        var updatedRecords = [CKRecord]()
        
        //
        fetchUpdatesOperation.recordFetchedBlock = { record in
            updatedRecords.append(record)
        }
        fetchUpdatesOperation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                // TO-DO: Set UserDefaults Last Fetch Date
                completion(.success(updatedRecords))
            }
        }
        fetchUpdatesOperation.qualityOfService = .userInitiated
        publicDatabase.add(fetchUpdatesOperation)
    }
   
    // MARK: - Errors
    
    /// Retries a CloudKit operation if the error suggests
    /// - Parameters:
    ///     - log: The logger to use for logging information about error handling, uses the default
    ///     - block: The block that will execute the operation later if it can be retried
    /// - Returns: Boolean indicating if the operation can be retried or not
    @discardableResult
    func retryCloudKitOperationIfPossible(_ log: OSLog? = nil, with block: @escaping () -> Void) -> Bool {
        let effectiveLog: OSLog = log ?? .default
        guard let effectiveError = self as? CKError else { return false }
        
        guard let retryDelay: Double = effectiveError.retryAfterSeconds else {
            os_log("Error is not recoverable", log: effectiveLog, type: .error)
            return false
        }
        
        os_log("Error is recoverable. Will try after %{public}f seconds", log: effectiveLog, type: .error, retryDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            block()
        }
        return true
    }
    
    // MARK: - Helpers
    /// Take in CKRecord values from CloudKit and convert the CKRecord objects to
    /// - Parameter records: Array of CKRecord values
    /// - Parameter completion:
    func convertCKRecordsToBeerModelObjects(_ records: [CKRecord], completion: @escaping (Result<[BeerModel], Error>) -> Void) {
        var beerModelObjects = [BeerModel]()
        
        for record in records {
            let isFav = record[.isFavorite] as? Int64 ?? 0
            let isTap = record[.isOnTap] as? Int64 ?? 0
            let recordID =          record.recordID
            let changeTag =         record.recordChangeTag ?? ""
            let section =           record[.sectionType] as? String ?? ""
            let name =              record[.name] as? String ?? ""
            let description =       record[.description] as? String ?? ""
            let beerABV =           record[.abv] as? String ?? ""
            let type =              record[.type] as? String ?? ""
            let createdDate =       record.creationDate ?? Date()
            let modifiedDate =      record.modificationDate ?? Date()
            let isFavorite =        isFav.boolValue
            let isOnTap =           isTap.boolValue
            
            let beerObj = BeerModel(id: recordID,
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
            beerModelObjects.append(beerObj)
        }
        completion(.success(beerModelObjects))
    }
}
