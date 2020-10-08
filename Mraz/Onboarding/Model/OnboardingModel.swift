//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
<<<<<<< Updated upstream
        case notifications = "Keep on tap beers updated along with any new beers we're brewing."
        case openApp = "Click the 'Show app button to open the application."
=======
        case notifications = "Stay updated when we release new beers and get notified when your favorite beers are on tap."
        case geofencing = "Allow Mraz to access your location to display local restaurants and send notifications when you're nearby."
        case openApp = "Click below to get started."
>>>>>>> Stashed changes
    }
    
    let title: String
    let description: OnboardDescriptions
    let image: UIImage?
}

extension OnboardingModel {
    static var data: [OnboardingModel] {
        return [
<<<<<<< Updated upstream
            // Page 2 -> Notifications /// Page 3 ///Open App
            OnboardingModel(title: "Stay updated with push notifications", description: .notifications, image: OnboardingImages.mrazNotification, actionButtonTitle: "Accept", nextBtnEnabled: false, nextBtnHidden: false),
            OnboardingModel(title: "Open the app", description: .openApp, image: OnboardingImages.openAppImage, actionButtonTitle: "Open app", nextBtnEnabled: nil, nextBtnHidden: true)
=======
            // Page 0 -> Age Auth // Page 1 Notifications // Page 2 Geofencing /// Page 3 ///Open App
            OnboardingModel(title: "Stay updated with push notifications", description: .notifications, image: OnboardingImages.mrazNotification),
            OnboardingModel(title: "Get notified when you're close", description: .geofencing, image: OnboardingImages.mrazGeofencing),
            OnboardingModel(title: "Open the app", description: .openApp, image: OnboardingImages.openAppImage)
>>>>>>> Stashed changes
        ]
    }
}
