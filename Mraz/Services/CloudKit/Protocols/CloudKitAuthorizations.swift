//  Created by Dylan  on 8/19/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit

protocol CloudKitAuthorizations {
    func requestCKAccountStatus()
    func setupAccountStatusChangedNotificationHandling()
}
