//  Created by Dylan  on 10/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit

protocol CloudKitSync {
    func fetchRemoteChangedRecords(by modifiedRecordID: CKRecord.ID)
    func handleNew(record: CKRecord)
    func handleModified(record: CKRecord, beer: Beers?)
}
