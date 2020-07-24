//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import UserNotifications
import CloudKit

protocol NotificationManager {
    var notificationContent: UNMutableNotificationContent { get }
    var notificationTimeTrigger: UNTimeIntervalNotificationTrigger { get }
    var notificationRequest: UNNotificationRequest { get }
    var currentNotificationCenter: UNUserNotificationCenter { get }
    var notificationSound: UNNotificationSound { get }
}

extension NotificationManager {
    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    var notificationContent: UNMutableNotificationContent {
        return UNMutableNotificationContent()
    }
    
    var notificationTimeTrigger: UNTimeIntervalNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    }
    
    var notificationRequest: UNNotificationRequest {
        return UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: notificationTimeTrigger)
    }
    
    var currentNotificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    var notificationSound: UNNotificationSound {
        return UNNotificationSound.default
    }
    
    // MARK: - Authorization
    func requestUserAuthForNotifications(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                completion(.failure(error))
            }
            if granted {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
    
    func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("NotificationManager -- Error while requesting notifications: \(error.localizedDescription)")
            }
        }
    }
    
    /// Check the users UNAuthorization status from UserNotifications
    /// - Parameter completion: Completion hanlder with the status of the user's authorizatons.
    func obtainUserNotificationAuthStatus(_ completion: @escaping (Result<Bool, LocationAuthError>) -> Void) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(.success(true))
            case .denied, .notDetermined, .provisional:
                completion(.failure(.deniedRestricted))
            @unknown default: ()
            }
        }
    }
}
