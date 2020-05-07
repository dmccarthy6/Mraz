//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

protocol CloudKitRecordsChangedDelegate: class, CoreDataAPI {
    func notificationReceived(_ notification: CKDatabaseNotification)
}

extension CloudKitRecordsChangedDelegate {
    
}
