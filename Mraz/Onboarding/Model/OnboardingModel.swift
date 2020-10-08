//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
        case notifications = "Stay updated when we release new beers and get notified when your favorite beers are on tap."
        case geofencing = "Allow Mraz to access your location to display local restaurants and send notifications when you're nearby."
        case openApp = "Click below to get started."
    }
    
    let title: String
    let description: OnboardDescriptions
    let image: UIImage?
}

extension OnboardingModel {
    static var data: [OnboardingModel] {
        return [
            // Page 0 -> Age Auth // Page 1 Notifications // Page 2 Geofencing /// Page 3 ///Open App
            OnboardingModel(title: "Stay updated with push notifications", description: .notifications, image: OnboardingImages.mrazNotification),
            OnboardingModel(title: "Get notified when you're close", description: .geofencing, image: OnboardingImages.mrazGeofencing),
            OnboardingModel(title: "Open the app", description: .openApp, image: OnboardingImages.openAppImage)
        ]
    }
}
