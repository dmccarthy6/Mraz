//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
        case firstView = "Welcome to the Mraz Brewery App! "
        case secondView = "We use notifications to keep our beer list updated, to update our on tap list and alert you when one of your favorite beers is on tap. \n\n We request access to your location to send notifications when you're close to the brewery. We do not store or sell your location."
        case thirdView = "Take me to the app!"
    }
    let title: String
    let description: OnboardDescriptions
    let image: UIImage
    let acceptBtnTitle: String
    let denyBtnTitle: String
    let isSkipHidden: Bool
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
                            isSkipHidden: true,
                            agreeButtonHidden: true,
                            denyButtonHidden: true,
                            showAppButtonHidden: true),
            OnboardingModel(title: "Notifications",
                            description: .secondView,
                            image: OnboardingImages.mrazMapImage,
                            acceptBtnTitle: "Allow Notifications",
                            denyBtnTitle: "Don't Allow",
                            isSkipHidden: true,
                            agreeButtonHidden: false,
                            denyButtonHidden: false,
                            showAppButtonHidden: true),
            OnboardingModel(title: "Open The App",
                            description: .thirdView,
                            image: OnboardingImages.openAppImage,
                            acceptBtnTitle: "",
                            denyBtnTitle: "",
                            isSkipHidden: true,
                            agreeButtonHidden: true,
                            denyButtonHidden: true,
                            showAppButtonHidden: false)
        ]
    }
}
