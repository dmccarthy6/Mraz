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
}
