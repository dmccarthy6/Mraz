//  Created by Dylan  on 7/16/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class OnboardingFlow {
    // MARK: - Properties
    private let userSettings: MrazSettings
    
    // MARK: - Initializer
    init(userSettings: MrazSettings) {
        self.userSettings = userSettings
    }
    
    // MARK: - Start Flow
    func start(with rootViewController: UIViewController) {
        let onboardingVC = MrazOnboardingPageViewController()
        onboardingVC.modalPresentationStyle = .fullScreen
        rootViewController.present(onboardingVC, animated: true)
    }
}
