//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

final class GeofencingManager: NSObject, LocationManager {
    // MARK: - Properties
    
    // MARK: - Authorization Check
    func checkUserLocationAuthStatusAndStartTracking() {
        checkCurrentAuthorizationStatus { (result) in
            switch result {
            case .success(let granted):
                if granted {
                    self.startTrackingUsersLocationOnMap()
                } else {
                    self.requestAuthorizationFromUser()
                }
                
            case .failure(let locAuthError):
                switch locAuthError {
                case .deniedRestricted: print("Auth Denied -- Notify User")//TO-DO: Notify User Here
                }
            }
        }
    }
}

extension GeofencingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Failed With Error")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Tracking user, they updated location")
        //guard let usersLastLocation = locations.last else { return }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        scheduleEnteredRegionNotification(region)
    }
}
