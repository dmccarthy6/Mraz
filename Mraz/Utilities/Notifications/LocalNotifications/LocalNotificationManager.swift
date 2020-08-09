//  Created by Dylan  on 8/9/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications

class LocalNotificationManger {
    // MARK: - Properties
    var notifications = [Notification]()
    private var notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Authorization
    private func requestAuthorizationForLocalNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted && error == nil {
                self.scheduleNotifications()
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
                self.scheduleNotifications()
            default: break
            }
        }
    }
    
    private func scheduleNotifications() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.subtitle = notification.subTitle
            content.sound = .default
            
            let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: timeTrigger)
            
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
