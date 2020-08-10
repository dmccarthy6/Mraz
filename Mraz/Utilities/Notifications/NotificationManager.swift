//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import UserNotifications

protocol NotificationManager {
    var notificationCenter: UNUserNotificationCenter { get }
    func requestUserAuthForNotifications(_ completion: @escaping (Result<Bool, Error>) -> Void)
    func checkUserLocalNotificationStatus(_ completion: @escaping (Result<Bool, Error>) -> Void)
}

extension NotificationManager {
    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    // MARK: - Authorization
    /// This method calles 'requestAuthorization' from the UNUserNotification center. This asks the user for authorization to send both
    /// local and push notifications.
    /// - Parameter completion: completion handler returning the boolean property containing the result of the user's action.
    func requestUserAuthForNotifications(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(granted))
        }
    }
    
    func checkUserLocalNotificationStatus(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestUserAuthForNotifications { (result) in
                    switch result {
                    case .failure(let error):
                        print("Error requesting Local Notification Status: \(error.localizedDescription)")
                    case .success(let granted):
                        if granted {
                            completion(.success(true))
                        }
                        completion(.success(false))
                    }
                }
            case .authorized, .provisional:
                completion(.success(true))
            default: completion(.success(false))
            }
        }
    }
}
