//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

protocol ReadFromCloudKit: CloudKitAuthorizations {
    var publicCloudKitDatabase: CKDatabase { get }
    var defaultContainer: CKContainer { get }
    
    func createCloudKit(subscription: CKQuerySubscription)
    //func createSubscription(with predicate: NSPredicate, _ completion: @escaping () -> Void)
    func fetchRecordsFromCK(_ withPredicate: NSPredicate, qualityOfService: QualityOfService)
    func fetchModifiedRecords(by ckRecordID: CKRecord.ID)
}

extension ReadFromCloudKit {
    var subscriptionDispatchGroup: DispatchGroup {
        return DispatchGroup()
    }
    
    // MARK: - Account Status
    /// Check the users iCloud Account Status returning a result type with the status or an error if one occurs. Utilize this method to
    /// Handle any iCloud status changes the user may perform.
    /// - Returns: Result type with a CloudKit Status enum value and a CloudKitError enum value.
    func getUsersCurrentAuthStatus(completion: @escaping (Result<CloudKitStatus, CloudKitStatusError>) -> Void) {
        defaultContainer.accountStatus { (status, error) in
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
    
    // MARK: - Subscriptions
    #warning("https://github.com/dmccarthy6/Mraz/issues/15#issue-697219045")
    //CREATE SUB
    func createCloudKit(subscription: CKQuerySubscription) {
        //Create Subscription
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = ""
        subscription.notificationInfo = notificationInfo
        
        //Save it
        publicCloudKitDatabase.save(subscription) { (ckSubscription, error) in
            if let error = error {
                print("ReadFromCK -- Error saving sub. \(error.localizedDescription)")
            } else {
                let settings = MrazSettings()
                let subID = ckSubscription?.subscriptionID
                settings.set(subID as Any, for: .mrazCloudKitSubscriptionID)
                print("ReadFromCK -- CK Subscription \(subID) saved successfully.")
            }
        }
    }

    /// Delete all subscriptions from CloudKit.
    func deleteAllSubscriptionsFromCloudKit() {
        publicCloudKitDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if let error = error {
                //Error handling
                print("ReadFromCK - Error deleting sub \(error.localizedDescription)")
            }
            
            if let subscriptions = subscriptions {
                subscriptions.forEach { (subscription) in
                    self.publicCloudKitDatabase.delete(withSubscriptionID: subscription.subscriptionID) { (subID, error) in
                        print("ReadFromCK -- Subscription id: \(subID ?? "NO CK SUB ID") successfully deleted.")
                    }
                }
            }
        }
    }
    
    /// Create the CloudKit subscription to save to database.
//    func createSubscription(with predicate: NSPredicate, _ completion: @escaping () -> Void) {
//        let subscription = CKQuerySubscription(recordType: CKRecordType.beers,
//                                               predicate: predicate,
//                                               options: [.firesOnRecordUpdate, .firesOnRecordCreation])
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.shouldSendContentAvailable = true
//        notificationInfo.alertBody = ""
//        subscription.notificationInfo = notificationInfo
//
//        publicCloudKitDatabase.save(subscription) { (ckSub, error) in
//            if let error = error {
//                print("ReadFromCK - Error: \(error.localizedDescription)")
//            }
//            print("ReadFromCK - Saving subscri[ption - \(ckSub?.subscriptionID)")
//        }
//    }
    
    #warning("REMOVE THIS")
//    func saveCloud(_ subscription: CKSubscription) {
//        publicCloudKitDatabase.save(subscription) { (ckSubscription, error) in
//            if let error = error {
//                if ckSubscription == subscription {
//                    print("ReadFromCK - Have a duplicate subscription. Not saving it")
//                    return
//                }
//                print("ReadFromCK - Error saving subscription: \(error.localizedDescription)")
//            } else {
//                let mrazSettings = MrazSettings()
//                let subscriptionID = subscription.subscriptionID
//                print("ReadFromCK - Setting CK Subscription ID to \(subscriptionID)")
//                mrazSettings.set(subscriptionID as Any, for: .mrazCloudKitSubscriptionID)
//            }
//        }
//    }
    
//    func deleteAllSubscriptionsFromCloudKit(_ closure: @escaping () -> Void) {
//        publicCloudKitDatabase.fetchAllSubscriptions { (subscriptions, error) in
//            if let error = error as? CKError {
//                print("Error fetching CloudKit subscriptions: \(error.localizedDescription)")
//                // Retry?
//            }
//
//            guard let subscriptions = subscriptions else { return }
//            subscriptions.forEach { (subscription) in
//                self.publicCloudKitDatabase.delete(withSubscriptionID: subscription.subscriptionID) { (subscriptionID, error) in
//                    if let error = error as? CKError {
//                        print("Error deleting subscription from CloudKit: \(error.localizedDescription)")
//                    }
//                    print("Deleted CloudKit Subscription with ID: \(subscriptionID)")
//                }
//            }
//        }
//    }
    
    // MARK: - CloudKit Errors
    /// Retries a CloudKit operation if the error suggests
    /// - Parameter log: The logger to use for logging information about error handling, uses the default
    /// - Parameter block: The block that will execute the operation later if it can be retried
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
