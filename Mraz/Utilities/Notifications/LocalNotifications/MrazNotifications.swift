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
            completion(granted)
        }
    }
    
    /// Checks notifcation center authorization. If authorized completion is called.
    func requestNotificationAuthorization(_ completion: @escaping () -> ()) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Error requesting Auth: \(error.localizedDescription)")
            }
            if granted {
                completion()
            }
        }
    }
}
