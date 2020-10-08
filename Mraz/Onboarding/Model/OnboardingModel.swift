//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
        case notifications = "Stay updated when we brew new beers and when your favorite beers are tapped."
        case geofencing = "Allow Mraz to access your location to display local restaurants and send notifications when you're nearby."
        case openApp = "Click below to get started."
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
            // Page 0 -> Age Auth // Page 1 Notifications // Page 2 Geofencing /// Page 3 ///Open App
            OnboardingModel(title: "Stay updated with push notifications", description: .notifications, image: OnboardingImages.mrazNotification, actionButtonTitle: "Accept", nextBtnEnabled: false, nextBtnHidden: false),
            OnboardingModel(title: "Get notified when you're close", description: .geofencing, image: OnboardingImages.mrazGeofencing, actionButtonTitle: "Accept", nextBtnEnabled: nil, nextBtnHidden: true),
            OnboardingModel(title: "Open the app", description: .openApp, image: OnboardingImages.openAppImage, actionButtonTitle: "Open app", nextBtnEnabled: nil, nextBtnHidden: true)
        ]
    }
}
