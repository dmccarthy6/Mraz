//  Created by Dylan  on 8/9/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import CoreLocation
import UIKit
import os.log

enum NotificationType {
    case geofencing
    case local
}

enum NotificationID: String {
    case authorization = "Something"
}

class LocalNotificationManger: NSObject, MrazNotifications {
    // MARK: - Properties
    let notificationLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: LocalNotificationManger.self))
    var scheduledNotifications: [MrazNotification] = [MrazNotification]()
    var notificationTrigger: UNNotificationTrigger
    var notificationCenter: UNUserNotificationCenter
    
    // MARK: - Life Cycle
    init(notificationTrigger: UNNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false),
         notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationTrigger = notificationTrigger
        self.notificationCenter = notificationCenter
        super.init()
    }

    // MARK: - Scheduling Notifications
    func schedule() {
        getUserNotificationSettings { [weak self] in
            guard let self = self else { return }
            os_log("User authorized notifications", log: self.notificationLog, type: .debug, #function)
            self.scheduleLocalNotification()
        }
    }
    
    func scheduleLocalNotification() {
        os_log("%{public}@ called.", log: self.notificationLog, type: .debug, #function)
            //let badgeCount = UIApplication.shared.applicationIconBadgeNumber + 1
        
        for notification in scheduledNotifications {
            let content = UNMutableNotificationContent()
//            content.categoryIdentifier = contentID.rawValue
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            //content.badge = NSNumber(value: badgeCount)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: notificationTrigger)
            
            notificationCenter.add(request) { (error) in
                if let error = error {
                    os_log("Error scheduling local notifications %@",
                           log: self.notificationLog,
                           type: .error,
                           String(describing: error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Trigger Notifications
    func triggerMrazLocalNotification(type: NotificationType, title: String, body: String, region: CLRegion?) {
        var notification: MrazNotification?
        
        switch type {
        case .geofencing:
            guard let region = region else {
                os_log("Trying to send Geofencing notification without a region", log: self.notificationLog, type: .error)
                return
            }
            notification = MrazNotification(id: region.identifier, title: title, body: body)
        case .local:
            notification = MrazNotification(id: UUID().uuidString, title: title, body: body)
        }
        scheduledNotifications.append(notification!)
        schedule()
    }
    
    // MARK: - Interface
    func triggerGeofencingNotification(for region: CLRegion) {
        triggerMrazLocalNotification(type: .geofencing, title: GeoNotificationContent.title, body: GeoNotificationContent.body, region: region)
    }
    
    func sendFavoriteBeerNotification(for beer: Beers) {
        if beer.isFavorite && beer.isOnTap {
            os_log("Favorite beer notification triggered for %@", log: self.notificationLog, type: .debug, String(describing: beer.name))
            
            let beerName = beer.name ?? "Favorite Beer"
            let title = "\(beerName) is on tap!"
            let body = "Come by the tasting room to get yours before it's gone."
            triggerMrazLocalNotification(type: .local, title: title, body: body, region: nil)
        }
    }
}
