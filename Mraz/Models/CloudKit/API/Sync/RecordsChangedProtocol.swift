//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

protocol CloudKitRecordsChangedDelegate: class {
    func processChanged(_ records: [CKRecord])
}
