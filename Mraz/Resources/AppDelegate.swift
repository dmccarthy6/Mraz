//  AppDelegate.swift
//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CloudKit
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CoreDataAPI {
    let cloudKitManager = CloudKitManager.shared
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        resetOnboarding()
        
        configureNotificationCtr()
        cloudKitManager.checkUserCloudKitAccountStatusAndSubscribe()
        return true
    }
    
    // MARK: - FOR DEVELOPMENT
    func resetOnboarding() {
        let mrazSettings = MrazSettings()
        mrazSettings.set(false, for: .didFinishOnboarding)
        mrazSettings.set(false, for: .userIsOfAge)
    }
    
    // Reset application badge
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func configureNotificationCtr() {
        let notificationMgr = LocalNotificationManger(notificationCenter: UNUserNotificationCenter.current())
        notificationMgr.notificationCenter.delegate = self
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
        print("RECEIVED REMOTE NOTIFICATION")
        // CloudKit Remote Notifications
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        if notification?.notificationType == CKNotification.NotificationType.query {
            if let queryNotification = notification as? CKQueryNotification {
                guard let recordID = queryNotification.recordID else { return }
                let sync = SyncCloudKitRecordChanges(changedRecordName: recordID.recordName, changedRecordID: recordID)
                sync.fetchUpdatedRecord()
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    }
}
