//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
        case notifications = "Keep on tap beers updated along with any new beers we're brewing."
        case openApp = "Click the 'Show app button to open the application."
    }
    
    let title: String
    let description: OnboardDescriptions
    let image: UIImage?
    let actionButtonTitle: String
    let nextBtnEnabled: Bool?
    let nextBtnHidden: Bool?
}

extension OnboardingModel {
    static var data: [OnboardingModel] {
        return [
            // Page 2 -> Notifications /// Page 3 ///Open App
            OnboardingModel(title: "Stay updated with push notifications", description: .notifications, image: OnboardingImages.mrazNotification, actionButtonTitle: "Accept", nextBtnEnabled: false, nextBtnHidden: false),
            OnboardingModel(title: "Open the app", description: .openApp, image: OnboardingImages.openAppImage, actionButtonTitle: "Open app", nextBtnEnabled: nil, nextBtnHidden: true)
        ]
    }
}
