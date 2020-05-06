//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct PresentAgeVerificationView {
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    let viewController: UIViewController
     
    // MARK: - Life Cycle Methods
    @discardableResult
    init(viewController: UIViewController) {
        self.viewController = viewController
        guard let view = viewController.view else { return }
        let ageVerificationView = AgeVerificationView(frame: CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0))
        handleAgeVerification(viewController, verificationView: ageVerificationView)
    }
 
    /// Check the age verification value in User Defaults and handle the UI based on the value.
    private func handleAgeVerification(_ viewController: UIViewController, verificationView: AgeVerificationView) {
        guard let view = viewController.view else { return }
        let storage = Storage()
        let userAuthenticated = storage.userIsOfAge
        
        switch userAuthenticated {
        case true:
            break
        case false:
            view.addSubview(verificationView)
            verificationView.present(viewController)
        case .none:
            view.addSubview(verificationView)
            verificationView.present(viewController)
        case .some(_):
            ()
        }
    }
}
