//  AppDelegate.swift
//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CloudKit
import NotificationCenter
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let ckManager = CloudKitManager()
    let sync = SyncContainer()
    let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: AppDelegate.self))
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureNotificationCtr()
        MrazSettings().set(false, for: .suppressCloudKitError)
        checkCKAuth()
        application.registerForRemoteNotifications()
        return true
    }

    // Reset application badge
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func configureNotificationCtr() {
        let notificationMgr = LocalNotificationManger(notificationCenter: UNUserNotificationCenter.current())
        notificationMgr.notificationCenter.delegate = self
    }
    
    func checkCKAuth() {
        ckManager.requestCKAccountStatus()
        ckManager.setupAccountStatusChangedNotificationHandling()
    }
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
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let dict = userInfo as? [String: NSObject] else { return }
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        if notification?.notificationType == CKNotification.NotificationType.query {
            os_log("Remote notifiation received from CK", log: self.mrazLog, type: .default)
            sync.processMrazSubscriptionNotification(with: dict)
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
}
