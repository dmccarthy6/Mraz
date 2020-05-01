//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

protocol ReadFromCloudKit {
    func getUserAccountStatus(completion: @escaping (Result<CloudKitStatus, CloudKitStatusError>) -> Void)
    func fetchBeerListFromCloud(_ completion: @escaping (Result<[Beers], Error>) -> Void)
}

extension ReadFromCloudKit {
    var database: CKDatabase {
        let container = CKContainer(identifier: ContainerID.beers.rawValue)
        let db = container.publicCloudDatabase
        return db
    }
    
    var ckContainer: CKContainer {
        return CKContainer.default()
    }
    
    
    //MARK: - Check Account Status
    
    /// Check the users iCloud Account Status
    /// - Returns: Result type with a CloudKit Status enum value and a CloudKitError enum value.
    func getUserAccountStatus(completion: @escaping (Result<CloudKitStatus, CloudKitStatusError>) -> Void) {
        ckContainer.accountStatus { (status, error) in
            if let error = error {
                completion(.failure(.failedConnection))
                //TO-DO: Handle Error
            }
            else {
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
    }
    
    /// These methods are to obtain the User's info from the CK database.
    
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
    
    //MARK: - Subscription Methods
    
    /// Create the CloudKit Subscription on Beers values
    func createSubscriptionForAllBeers() {
//        let isOnTapPredicate = NSPredicate(format: "isOnTap == %@", 1)
        let predicate = NSPredicate(value: true)
        
        ///Flush out existing subscrptions
        deleteAllSubscriptionsFromCloudKit()
        
        //Create the New subscription
        var options = CKQuerySubscription.Options()
        options.insert(.firesOnRecordUpdate)
        options.insert(.firesOnRecordCreation)
        let subscription = CKQuerySubscription(recordType: CKRecordType.beers.name, predicate: predicate, options: options)
        
        //Save subscription to database
        createCKSubscription(subscription)
    }
    
    /// Delete all  subscriptions from CloudKit
    private func deleteAllSubscriptionsFromCloudKit() {
        database.fetchAllSubscriptions { (subscription, error) in
            if error == nil {
                if let subscription = subscription {
                    for subscription in subscription {
                        self.database.delete(withSubscriptionID: subscription.subscriptionID) { (str, error) in
                            if error != nil {
                                //TO-DO: Error Handling
                                print("ReadFromCK -- Error deleting subscription: \(String(describing: error?.localizedDescription))")
                            }
                        }
                    }
                }
            }
            else {
                //TO-DO: Error Handling
            }
        }
    }
    
    /// Create a subscription
    private func createCKSubscription(_ subscription: CKSubscription) {
        let notificationInfo = CKSubscription.NotificationInfo()
        subscription.notificationInfo = notificationInfo
        
        database.save(subscription) { (ckSubscription, error) in
            if let error = error {
                print("ReadFromCloudKit -- Error saving subscription: \(error.localizedDescription)")
            }
            else {
                //TO-DO: Save Subscription ID to UserDefaults?
                let userDef = UserDefaults.standard
                let subscriptionID = ckSubscription?.subscriptionID
                userDef.set(subscriptionID, forKey: Key.cloudSubscription.rawValue)
                print("ReadFromCloudKit -- CK Subscription Saved Successfully!")
            }
        }
    }
    
    //MARK: Fetching
    func fetchRecord(_ recordID: CKRecord.ID) {
        if UserDefaults.standard.value(forKey: Key.cloudSubscription.rawValue) != nil {
            
        }
    }
    
    //MARK: - Errors
    
    /// Retries a CloudKit operation if the error suggests
    ///
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
    
}
