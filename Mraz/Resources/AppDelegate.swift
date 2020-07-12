//  AppDelegate.swift
//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CloudKit
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CoreDataAPI, NotificationManager {
    let cloudKitManager = CloudKitManager.shared
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestNotifications(application: application)
//        checkCloudStatus()

//        UserDefaults.standard.setValue(false, forKey: Key.cloudSubscriptionExists.rawValue)
//        UserDefaults.standard.setValue(false, forKey: Key.initialFetchSuccessful.rawValue)
        cloudKitManager.performInitialCloudKitFetch()
        cloudKitManager.subscribeToBeerChanges()
        return true
    }

    // MARK: - Helpers
    func requestNotifications(application: UIApplication) {
        requestUserAuthenticationForNotifications { (result) in
            switch result {
            case .success(true):
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            case .success(false): break
            case .failure(let error):
                print("App Delegate -- Error Requesting Notifications Auth: \(error.localizedDescription)")
            }
        }
    }
    
    /// Check the User's CK status and perform actions appropriately.
    func checkCloudStatus() {
        CloudKitManager.shared.getUserAccountStatus { (result) in
            switch result {
            case .success(let status):
                switch status {
                case .available: break
                case .noAccount: Alerts.cloudKitAlert(title: .iCloudError, message: .noAccount)
                case .couldNotDetermine: Alerts.cloudKitAlert(title: .iCloudError, message: .couldNotDetermine)
                case .restricted: Alerts.cloudKitAlert(title: .iCloudError, message: .restricted)
                }
            case .failure(let ckError):
                Alerts.cloudKitErrorAlert(ckError)
            }
        }
    }
    
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Remote Notifications
  
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        print("NotificationManager -- Notifications ID: \(identifier)")
    }
    
    // Should this be in app delegate?
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let dict = userInfo as? [String: NSObject] else { return }
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
 
        if notification?.notificationType == CKNotification.NotificationType.query {
            let queryNotification = notification as! CKQueryNotification
            guard let recordName = queryNotification.recordID?.recordName else { return }
            let sync = SyncCloudKitRecordChanges(changedRecordName: recordName)
            sync.fetchUpdatedObject()
        }
        completionHandler(.newData)
    }
}

/*
 let notification: CKNotification =
     CKNotification(fromRemoteNotificationDictionary:
         userInfo as! [String : NSObject])

 if (notification.notificationType ==
             CKNotificationType.query) {

     let queryNotification =
         notification as! CKQueryNotification

     let recordID = queryNotification.recordID

     viewController.fetchRecord(recordID!)
 }
 */
  
