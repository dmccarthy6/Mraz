//  Created by Dylan  on 8/9/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import CoreLocation
import UIKit

class LocalNotificationManger: NSObject, MrazNotifications {
    // MARK: - Properties
    var scheduledNotifications: [Notification] = [Notification]()
    var notificationTrigger: UNNotificationTrigger
    var notificationCenter: UNUserNotificationCenter
    
    // MARK: - Life Cycle
    init(notificationTrigger: UNNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false),
         notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationTrigger = notificationTrigger
        self.notificationCenter = notificationCenter
        
        super.init()
       // getPending()
    }

    // MARK: - Scheduling Notifications
    func schedule() {
        getUserNotificationSettings { [weak self] in
            print("Notifications are authorized")
            self?.scheduleLocalNotification()
        }
    }
    
    func scheduleLocalNotification() {
        print("Sched Local Notifications Called")
        let badgeCount = UIApplication.shared.applicationIconBadgeNumber + 1
        for notification in scheduledNotifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            content.badge = NSNumber(value: badgeCount)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: notificationTrigger)
            
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error scheduling Notification - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getPending() {
        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            for request in notificationRequests {
                let content = request.content
                print("Here's the pending notifications:")
                print("Title: \(content.title)")
                print("Body: \(content.body)")
            }
        }
    }
    
    // MARK: -
    func triggerGeofencingNotification(for region: CLRegion) {
        let notification = Notification(id: region.identifier,
                                title: GeoNotificationContent.title,
                                body: GeoNotificationContent.body)
        notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        //notificationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        scheduledNotifications.append(notification)
        schedule()
    }
    
    func triggerLocalNotification(title: String, body: String) {
        let notification = Notification(id: UUID().uuidString, title: title, body: body)
        scheduledNotifications.append(notification)
        schedule()
    }
}
