//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, WriteToCoreData {
    var window: UIWindow?
    var appFlow: AppFlow!
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let context = AppContext()
            appFlow = AppFlow(context: context, window: window)
            appFlow.didFinishLaunching()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.sharedDatabase.save(context: mainThreadManagedObjectContext)
    }
}
