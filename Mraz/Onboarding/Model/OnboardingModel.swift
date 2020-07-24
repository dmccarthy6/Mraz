//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
        case firstView = "Welcome to the Mraz Brewery App! \n\n We'll go through just 3 short onboarding screens to get the app all set up for you. Click the 'next' button up top or swipe left to start."
        case secondView = "This application uses notifications to keep everything updated in the background along with sending you a few alerts when your favorite beers are on tap. \n\n Mraz uses your location to send you push notifications when you're nearby the tasting room. Tap accept below to authorize notifications."
        case thirdView = "\n\n\n Click the button below to get started."
    }
    
    let title: String
    let description: OnboardDescriptions
    let image: UIImage
    let acceptBtnTitle: String
    let denyBtnTitle: String
    let nextButtonEnabled: Bool
    let agreeButtonHidden: Bool
    let denyButtonHidden: Bool
    let showAppButtonHidden: Bool
}

extension OnboardingModel {
    static var data: [OnboardingModel] {
        return [
            OnboardingModel(title: "Welcome",
                            description: .firstView,
                            image: OnboardingImages.firstImage,
                            acceptBtnTitle: "",
                            denyBtnTitle: "",
                            nextButtonEnabled: true,
                            agreeButtonHidden: true,
                            denyButtonHidden: true,
                            showAppButtonHidden: true),
            OnboardingModel(title: "Notifications",
                            description: .secondView,
                            image: OnboardingImages.bellSystemIcon,
                            acceptBtnTitle: "Accept",
                            denyBtnTitle: "Deny",
                            nextButtonEnabled: false,
                            agreeButtonHidden: false,
                            denyButtonHidden: false,
                            showAppButtonHidden: true),
            OnboardingModel(title: "Open Mraz",
                            description: .thirdView,
                            image: OnboardingImages.openAppImage,
                            acceptBtnTitle: "",
                            denyBtnTitle: "",
                            nextButtonEnabled: false,
                            agreeButtonHidden: true,
                            denyButtonHidden: true,
                            showAppButtonHidden: false)
        ]
    }
}
