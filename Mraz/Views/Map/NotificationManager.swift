//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UserNotifications
import UIKit

protocol NotificationManager {
    
}

extension NotificationManager {
    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    // MARK: - Authorization
    func requestUserAuthenticationForNotifications(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                //Failure
                completion(.failure(error))
            }
            if !granted {
                completion(.success(false))
                print("Authorization Not Granted")
            } else {
                print("NotificationManager -- Notifications Authorized -- ")
                completion(.success(true))
            }
        }
    }
    
    /// Check the users UNAuthorization status from UserNotifications
    /// - Parameter completion: Completion hanlder with the status of the user's authorizatons.
    func checkCurrentAuthorizationStatus(_ completion: @escaping (Result<Bool, LocationAuthError>) -> Void) {
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

