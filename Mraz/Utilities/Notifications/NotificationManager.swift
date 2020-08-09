//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import UserNotifications
import CloudKit

protocol NotificationManager {
    var notificationCenter: UNUserNotificationCenter { get }
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
