//  Created by Dylan  on 7/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

struct OnboardingModel {
    // MARK: - Types
    enum OnboardDescriptions: String {
        case notifications = "To get notifications when your favorite beers are tapped, tap 'Accept' then 'Allow' on the notification alert. You can always change this later in 'Settings' -> 'Notifications' -> 'Mraz' then toggle 'Allow Notifications'"
        case geofencing = "To get notifications when you're nearby, tap 'Accept', 'Allow While Using App' then select 'Change to Always Allow' on the next alert. You can change this later in 'Settings' -> 'Privacy' -> 'Location Services' -> 'Mraz'"
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
