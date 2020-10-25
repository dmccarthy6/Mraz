//  Created by Dylan  on 7/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

final class AppFlow {
    // MARK: - Properties
    private lazy var onboardingFlow = OnboardingFlow(userSettings: context.userSettings)
    
    private let context: AppContext
    
    private let window: UIWindow
    
    private let ckManager: CloudKitManager
    
    private let cdManager: CoreDataManager
    
    private var rootViewController: UIViewController {
        return window.rootViewController!
    }
    
    // MARK: - Life Cycle
    init(context: AppContext, window: UIWindow?, coreDataManager: CoreDataManager, cloudKitManager: CloudKitManager) {
        self.context = context
        self.window = window ?? .init()
        self.ckManager = cloudKitManager
        self.cdManager = coreDataManager
    }
    
    // MARK: - Launching Configurations
    @discardableResult
    func didFinishLaunching() -> Bool {
        createRootViewController()
        handleCloudKitStatus()
        return didStartFlow()
    }
    
    // MARK: - Flow Management
    private func didStartFlow() -> Bool {
        switch context.state {
        case .onboarding: startOnboardingFlow()
        case .session: return true
        }
        return true
    }
    
    private func startOnboardingFlow() {
        MrazSettings().set(true, for: .didFinishOnboarding)
        onboardingFlow.start(with: rootViewController)
    }
    
    private func handleCloudKitStatus() {
        ckManager.requestCKAccountStatus()
        ckManager.setupAccountStatusChangedNotificationHandling()
    }
    
    private func createRootViewController() {
        let tabBar = MrazTabBarController(cloudKitManager: ckManager, coreDataManager: cdManager)
        
        if #available(iOS 14.0, *) {
            let sideBarViewController = SideBarViewController(coreDataManager: cdManager, cloudKitManager: ckManager)
            let splitVC = UISplitViewController(style: .doubleColumn)
            
            splitVC.preferredDisplayMode = .allVisible
            splitVC.presentsWithGesture = true
            splitVC.preferredSplitBehavior = .tile
            
            splitVC.setViewController(sideBarViewController, for: .primary)
            splitVC.setViewController(tabBar, for: .compact)
            
            window.rootViewController = splitVC
            window.makeKeyAndVisible()
        } else {
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
        }
    }
}
