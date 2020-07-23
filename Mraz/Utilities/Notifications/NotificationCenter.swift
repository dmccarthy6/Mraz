//  Created by Dylan  on 7/22/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import NotificationCenter
import CloudKit

final class MrazNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        print("NotificationManager -- Notifications ID: \(identifier)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let dict = userInfo as? [String: NSObject] else { return }
        
        // CloudKit Remote Notifications
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        if notification?.notificationType == CKNotification.NotificationType.query {
            if let queryNotification = notification as? CKQueryNotification {
            guard let recordID = queryNotification.recordID else { return }
            let sync = SyncCloudKitRecordChanges(changedRecordName: recordID.recordName, changedRecordID: recordID)
            sync.fetchUpdatedRecord()
                completionHandler(.newData)
            }
        }
        completionHandler(.noData)
    }
}
