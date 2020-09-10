//  Created by Dylan  on 8/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import UIKit

protocol MrazNotifications: MrazNotificationAuthorization {
    // MARK: - Properties
    var notificationCenter: UNUserNotificationCenter { get set }
    var scheduledNotifications: [Notification] { get }
    
    // MARK: - Methods
    func schedule()
    func scheduleLocalNotification()
}

extension MrazNotifications {
    // MARK: - Authorizations
    func promptUserForLocalNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Error requesting Local Notifications: \(error.localizedDescription)")
            }
            if !granted {
                return
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func getLocalNotificationStatus(_ completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Error requesting Local Notification Auth: \(error.localizedDescription)")
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
