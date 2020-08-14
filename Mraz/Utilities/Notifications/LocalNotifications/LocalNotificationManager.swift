//  Created by Dylan  on 8/9/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import CoreLocation

class LocalNotificationManger: NSObject, MrazNotifications {
    // MARK: - Properties
    var scheduledNotifications: [Notification] = [Notification]()
    var notificationTrigger: UNNotificationTrigger
    var notificationCenter: UNUserNotificationCenter
    
    // MARK: - Life Cycle
    init(notificationTrigger: UNNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false), notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationTrigger = notificationTrigger
        self.notificationCenter = notificationCenter
    }

    // MARK: - Scheduling Notifications
    func schedule() {
        scheduleLocalNotification()
//        requestNotificationAuthorization { [weak self] in
//            self?.scheduleLocalNotification()
//        }
    }
    
    func scheduleLocalNotification() {
        for notification in scheduledNotifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            content.badge = 1
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: notificationTrigger)
            
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error scheduling Notification - \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: -
    func triggerGeofencingNotification(for region: CLRegion) {
        let note = Notification(id: region.identifier,
                                title: GeoNotificationContent.title,
                                body: GeoNotificationContent.body)
        notificationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        scheduledNotifications.append(note)
        schedule()
    }
    
    func triggerLocalNotification(title: String, body: String) {
        let notification = Notification(id: UUID().uuidString, title: title, body: body)
        scheduledNotifications.append(notification)
        schedule()
    }
}
