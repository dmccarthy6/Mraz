//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appFlow: AppFlow!
    let store = CoreDataStore(.persistent)
    lazy var databaseManager = CoreDataManager(context: store.context)
    lazy var cloudKitManager = CloudKitManager()
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let context = AppContext()
            
            appFlow = AppFlow(context: context,
                              window: window,
                              coreDataManager: databaseManager,
                              cloudKitManager: cloudKitManager)
            appFlow.didFinishLaunching()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        databaseManager.saveContext()
    }
}
