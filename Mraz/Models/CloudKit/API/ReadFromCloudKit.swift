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
    
    // MARK: - Account Status
    /// Check the users iCloud Account Status returning a result type with the status or an error if one occurs. Utilize this method to
    /// Handle any iCloud status changes the user may perform.
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
    /// Send a request to the user for authoirzation to access their record from CloudKit.
    /// The data returned includes the user's ID, and the user's CKRecord.
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
    
    /// If the user gives authorization to access their CKRecord, this method is used
    /// to obtain the current user's CKRecord.ID.
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
    /// Perform a CKQuery fetch operation on the CloudKit database and return the fetched records. This method uses A CKQuery Operation and
    /// The 'recordFetchedBlock' and 'queryCompletionBlock' to handle fetched records. Results limit set to 250.
    /// - Parameter withPredicate: The NSPredicate value to use in the CKQuery. Use this to narrow down the query search.
    /// - Parameter qualityOfService: The quality of service to use for the CloudKit fetch.
    /// - Parameter completion: Completion handler that returns an array of CKRecords on success and an Error value on failure.
    func fetchFromCloudKit(_ withPredicate: NSPredicate, qualityOfService: QualityOfService, _ completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let query = CKQuery(recordType: CKRecordType.beers, predicate: withPredicate)
        query.sortDescriptors = sortDescriptors
        var fetchedRecords = [CKRecord]()
        
        // Create Operation
        let fetchAllOperation = CKQueryOperation(query: query)
        // Completion Blocks on Operation
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
        // Set properties on operation and add to public DB.
        fetchAllOperation.resultsLimit = 250
        fetchAllOperation.qualityOfService = qualityOfService
        publicDatabase.add(fetchAllOperation)
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
            let recordID =          record.recordID.recordName
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
    
    //
    func sync() {
        
    }
}
