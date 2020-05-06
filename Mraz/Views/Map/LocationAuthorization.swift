//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

struct LocationAuthorization {
    //MARK: - Types
    
    ///
    enum LocationAuthStatus {
        case startTrackingUpdates
        case requestAuthorization
    }
    
    /// Location Error
    enum LocationAuthError: Error {
        case deniedRestricted
        
        var localizedDescription: String {
            switch self {
            case .deniedRestricted: return "Location services are not turned on for this application. To utilize this go to Settings and authorize location services for Mraz."
            }
        }
    }
    
    // MARK: -
    
    /// Check the user's current authorization status for location.
    /// - Returns: Result completion consisting of
    static func checkLocationAuthorization(_ completion: @escaping (Result<LocationAuthStatus, LocationAuthError>) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(.success(.startTrackingUpdates))
            
        case .denied, .restricted:
            completion(.success(.requestAuthorization))
            
        case .notDetermined:
            completion(.success(.requestAuthorization))
            
        default: ()
        }
    }
}
