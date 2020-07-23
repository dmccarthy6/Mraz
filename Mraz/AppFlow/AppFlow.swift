//  Created by Dylan  on 7/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

final class AppFlow {
    // MARK: - Properties
    private lazy var onboardingFlow = OnboardingFlow(userSettings: context.userSettings)
    private let context: AppContext
    private let window: UIWindow
    private var rootViewController: UIViewController { return window.rootViewController! }
    
    // MARK: - Life Cycle
    init(context: AppContext, window: UIWindow?) {
        self.context = context
        self.window = window ?? .init()
    }
    
    // MARK: - Launching Configurations
    func didFinishLaunching() -> Bool {
        window.rootViewController = MrazTabBarController()
        window.makeKeyAndVisible()
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
        onboardingFlow.start(with: rootViewController)
    }
}
