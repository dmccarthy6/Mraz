//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreLocation

/// Brewery location name and coordinate.
enum LocationTitle: String {
    case mraz = "Mraz Brewery"
}

/// Get the CLLocation value for each location
enum Coordinates {
    case mraz
    
    var location: CLLocationCoordinate2D {
        switch self {
        case .mraz: return CLLocationCoordinate2D(latitude: LocationCoordinates.mrazLat,
                                                  longitude: LocationCoordinates.mrazLong)
        }
    }
}

/// Obtain the Latitude & Longitude values for each location
enum LocationCoordinates {
    static let mrazLat = Double(38.710252)
    static let mrazLong = Double(-121.086191)
}

// MARK: - Location Authorization

enum LocationAuthStatus {
    case startTrackingUpdates
    case requestAuthorization
}

// MARK: - Geofencing Enums

enum GeoRegion {
   static let identifier = "MrazBrewery"
}

enum GeoNotificationContent {
    static let title = "Mraz"
    static let body = "You're right by the tasting room. Stop in for a beer!"
}
