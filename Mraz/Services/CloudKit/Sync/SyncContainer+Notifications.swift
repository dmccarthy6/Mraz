//  Created by Dylan  on 10/3/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

extension SyncContainer {
    @discardableResult
    func processMrazSubscriptionNotification(with userInfo: [AnyHashable: Any]) -> Bool {
        os_log("%{public}@", log: mrazLog, type: .error, #function)
        
        guard let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) else {
            os_log("Not a CKNotification", log: self.mrazLog, type: .error)
            return false
        }
        
        guard notification.subscriptionID == publicSubscriptionId else {
            os_log("Not our subscription ID", log: self.mrazLog, type: .debug)
            return false
        }
        guard let changedRecordID = notification.recordID else {
            os_log("Query notification received without RecordID", log: self.mrazLog, type: .debug)
            return false
        }
        os_log("Received remote CloudKit notification for user data", log: mrazLog, type: .debug)
        
        fetchRemoteChangedRecords(by: changedRecordID)
        return true
    }
    
    // MARK: - Handle CK Remote Notifications
    
    /// Method called when a remote notification is received from CloudKit.
    /// - Parameter modifiedRecordID: A CKRecord.ID to fetch from the CloudKit database
    func fetchRemoteChangedRecords(by modifiedRecordID: CKRecord.ID) {
        os_log("%{public}@", log: mrazLog, type: .debug, #function)
        
        self.publicDB.fetch(withRecordID: modifiedRecordID) { [weak self] (record, error) in
            guard let self = self else { return }
            
            if let error = error {
                os_log("Failed to ", log: self.mrazLog, type: .error, String(describing: error))
                return
            }
            guard let updatedOrNewRecord = record else { return }
            self.syncDelegate?.saveRemoteChange(using: updatedOrNewRecord)
           
            //
           // self.ckManager.buildBeerModel(from: <#T##[CKRecord]#>)
//            let recordName = changedRecord.recordID.recordName
//            let recordNamePredicate = NSPredicate(format: "id == %@", recordName)
//            let beer = Beers.findOrFetch(in: self.dbManager.context, matching: recordNamePredicate)
//            let beerAlreadyExists = beer != nil
//            DispatchQueue.main.async {
//                beerAlreadyExists ?  self.update(beer: beer, from: changedRecord) : self.createNewBeerFrom(record: changedRecord)
//            }
        }
}
}
