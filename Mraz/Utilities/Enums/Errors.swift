//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

/// This error enum is used for any time we're requesting Authorization
/// from the user. In this case to ask the user for Authorization to send
/// notifications.
enum AuthorizationError: Error {
    case authDenied
    case authApproved
    
    var localizedDescription: String {
        switch self {
        case .authDenied:
            return "To receive notiications from Mraz it is recommended that you have notifications approved. You will not receive any notifications from this application which includes Alerts & Badges."
        case .authApproved: return "User approved"
        }
    }
}

enum LocationAuthError: Error {
    case deniedRestricted
    
    var localizedDescription: String {
        switch self {
        case .deniedRestricted: return "Location services are not turned on for this application. To utilize this go to Settings and authorize location services for Mraz."
        }
    }
}
