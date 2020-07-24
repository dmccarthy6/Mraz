//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

final class GeofencingManager: NSObject, LocationManager {
 
}

extension GeofencingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Failed With Error")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Tracking user, they updated location")
        //guard let usersLastLocation = locations.last else { return }
        updateUsersLocation(delegate: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        scheduleEnteredRegionNotification(region)
    }
}
