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
        requestNotifications(application: application)
//        checkCloudStatus()
        cloudKitManager.subscribeToCKIfNotAlreadySubscribed()
        cloudKitManager.performInitialCloudKitFetch()
        return true
    }

    // MARK: - Helpers
    func requestNotifications(application: UIApplication) {
        Notifications().requestAuthFromUserToAllowNotifications { (result) in
            switch result {
            case .success(let granted):
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else { return }
                
            case .failure(let error):
                print("App Delegate -- Error Requesting Auth: \(error)")
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

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        guard let viewController = SceneDelegate().window?.rootViewController as? MrazTabBarController else { return }
//        let dict = userInfo as! [String:NSObject]
//        guard let notification: CKDatabaseNotification = CKNotification(fromRemoteNotificationDictionary: dict) as? CKDatabaseNotification else {
//            return
//        }
        //Here call VC.fetchChanges(in: notification.database)
    }
}
