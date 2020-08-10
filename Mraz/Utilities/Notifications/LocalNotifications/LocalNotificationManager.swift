//  Created by Dylan  on 8/9/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications

class LocalNotificationManger: NSObject, LocationManager {
    // MARK: - Properties
    var notifications = [Notification]()
    let notificationTrigger: UNNotificationTrigger
    
    // MARK: - Life Cycle
    init(notificationTrigger: UNNotificationTrigger) {
        self.notificationTrigger = notificationTrigger
    }
    
    // MARK: - Authorization
    private func requestAuthorizationForLocalNotifications() {
        requestUserAuthForNotifications { (result) in
            switch result {
            case .success(let granted):
                if granted {
                    self.scheduleLocalNotification()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Scheduling Notifications
    func schedule() {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorizationForLocalNotifications()
            case .authorized, .provisional:
                self.scheduleLocalNotification()
            default: break
            }
        }
    }
    
    private func scheduleLocalNotification() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.subtitle = notification.subTitle
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
    
    // MARK: - Methods
    func listScheduledNotifications() {
        notificationCenter.getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                print(notification)
            }
        }
    }
}
