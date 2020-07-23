//  AppDelegate.swift
//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CloudKit
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CoreDataAPI, NotificationManager {
    let cloudKitManager = CloudKitManager.shared
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // For Development
        let mrazSettings = MrazSettings()
        mrazSettings.set(false, for: .didFinishOnboarding)
        mrazSettings.set(false, for: .userIsOfAge)
        //
        
        cloudKitManager.checkUserCloudKitAccountStatusAndSubscribe()
        return true
    }
}
