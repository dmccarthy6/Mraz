//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreLocation
import UserNotifications

final class Notifications: NSObject {
    //MARK: - Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    private let gcmMessageIDKey = "gcm.message_id" // ?? No idea What This is??
    private let title = "Mraz Brewing Company"
    private let messageBody = "You are right by the brewery. Stop in for a Beer!"
    
    //MARK: - Authorization Status Methods
    /// Request authorization from users to allow notifications.
    func requestAuthFromUserToAllowNotifications(completion: @escaping (Result<Bool, Error>) -> Void) {
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                //TO-DO: Handle Error
                completion(.failure(error))
                print("Notifications -- Error requesting Auth for Notifications: \(error)")
            }
            if !granted {
                completion(.success(granted))
                //User did not grant authorization, Ok, maybe alert here?
            }
            else {
                completion(.success(granted))
                print("Notifications -- Authorization Granted by User")
            }
        }
    }
    
    /// Check the user's current authorization status.
    func checkAuthStatus(completion: @escaping (Result<Bool, AuthorizationError>) -> Void) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(.success(true))
            case .denied, .notDetermined, .provisional:
                completion(.failure(.authDenied))
            @unknown default: ()
            }
        }
    }
    
    
    //MARK: - Geofencing Methods
    /// This method is fired when the user enters the specified region that is passed in. This method will send
    ///  local notification to the user when they pass into the region.
    /// - Parameters:
    ///     - region: The CLRegion that specifies the geofencing region we are using.
    func scheduleEnteredRegionNotification(region: CLRegion!) {
        checkAuthStatus { [unowned self] (result) in
            switch result {
            case .success(let granted):
                if granted {
                    self.setLocationTriggerFor(region: region)
                }
                else {
                    self.requestAuthFromUserToAllowNotifications { (result) in
                        switch result {
                        case .success(_):
                            self.setLocationTriggerFor(region: region)
                        case .failure(let authError):
                            print("Notifications -- AuthError: \(authError.localizedDescription)")
                        }
                    }
                }
                
            case .failure(let authError):
                print("Notifications -- Error Checking Auth Status: \(authError)")
            }
        }
    }
    
    /// Set the geofencing location trigger based on the region passed in
    private func setLocationTriggerFor(region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = messageBody
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let identifier = region.identifier
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: locationTrigger)
        
        self.notificationCenter.add(request) { (error) in
            if let error = error {
                print("Notifications -- Error: \(error.localizedDescription)")
            }
        }
    }
   
}

extension Notifications: UNUserNotificationCenterDelegate {
    
    /// This method allows notifications to be shown if the App is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    /// Respond to user's tapping notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Get the notification identifier to respond accordingly.
        let identifier = response.notification.request.identifier
        print("Notifications -- ID: \(identifier)")
    }
    
    ///Remote Notifications Here???
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //MARK:
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Notifications -- messageID: \(messageID)")
        }
        
        //print full message
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        //MARK: - CloudKit Push Notifications
    }
    
    
}
