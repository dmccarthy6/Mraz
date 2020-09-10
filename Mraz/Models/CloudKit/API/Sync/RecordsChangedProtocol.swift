//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import CoreData

struct SyncCloudKitChanges {
    // MARK: - Properties
    let cloudKitManager = CloudKitManager.shared
    var changedRecordName: String
    var changedRecordID: CKRecord.ID

    /// Fetch updated record from CKNotification. Create new record if it doesn't exist in Core Data or Update the record if it does.
    func fetchUpdatedRecord() {
        cloudKitManager.fetchModifiedRecords(by: changedRecordID)
    }
}
