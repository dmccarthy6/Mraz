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
        
        // For Development
        let mrazSettings = MrazSettings()
        mrazSettings.set(false, for: .didFinishOnboarding)
        mrazSettings.set(false, for: .userIsOfAge)
        //
        handleNotifications()
        
        cloudKitManager.checkUserCloudKitAccountStatusAndSubscribe()
        return true
    }
    
    // MARK: - Notifications
    func handleNotifications() {
        notificationCenter.delegate = self
        requestUserAuthForNotifications { (result) in
            switch result {
            case .success(true):
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .success(false): return
            case .failure(let error): print("Error registering for notifications: \(error)")
            }
        }
    }
    
    // Reset the badge
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let dict = userInfo as? [String: NSObject] else { return }
        
        // CloudKit Remote Notifications
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        if notification?.notificationType == CKNotification.NotificationType.query {
            if let queryNotification = notification as? CKQueryNotification {
            guard let recordID = queryNotification.recordID else { return }
            let sync = SyncCloudKitRecordChanges(changedRecordName: recordID.recordName, changedRecordID: recordID)
            sync.fetchUpdatedRecord()
                completionHandler(.newData)
            }
        }
        completionHandler(.noData)
    }
}
