//  Created by Dylan  on 8/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import UIKit
import os.log

protocol MrazNotifications: MrazNotificationAuthorization {
    var notificationCenter: UNUserNotificationCenter { get set }
    var scheduledNotifications: [MrazNotification] { get }
    
    func schedule()
    func scheduleLocalNotification()
}

extension MrazNotifications {
    var notificationsLog: OSLog {
        return OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: MrazNotifications.self))
    }
    
    // MARK: - Authorizations
    func promptUserForLocalNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                os_log("Error requesting local notification authorization from user. %@",
                       log: notificationsLog,
                       type: .error,
                       error.localizedDescription)
            }
            if !granted {
                os_log("Notification authorization granted - %@", log: notificationsLog, type: .debug, granted)
                return
            }
            os_log("Authorizations are granted", log: notificationsLog, type: .debug)
        }
    }
    
    func getLocalNotificationStatus(_ completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                os_log("Error requesting notification authorization - %@",
                       log: notificationsLog,
                       type: .error,
                       error.localizedDescription)
                return
            }
            completion(granted)
        }
    }
    
    /// If user has authorized notifications completion hanlder is called.
    /// prompts user for local notifications if status is 'not determined'
    func getUserNotificationSettings(_ completion: @escaping () -> Void) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional: completion()
            case .denied: break
            case .notDetermined: self.promptUserForLocalNotifications()
            default: ()
            }
        }
    }
    
    func getCurrentNotificationStatus() -> Bool {
        var currentStatus = false
        
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional: currentStatus = true
            case .denied: currentStatus = false
            case .notDetermined: currentStatus = false
            default: ()
            }
        }
        return currentStatus
    }
}
