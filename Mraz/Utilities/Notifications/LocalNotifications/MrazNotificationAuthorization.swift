//  Created by Dylan  on 8/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

protocol MrazNotificationAuthorization {
    func getLocalNotificationStatus(_ completion: @escaping (_ authorized: Bool) -> Void)
    func requestNotificationAuthorization(_ completion: @escaping () -> Void)
    func promptUserForLocalNotifications()
}
