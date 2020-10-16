//  Created by Dylan  on 8/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

protocol MrazLocationAuthorization {
    /// Sent request to user for requestAlwaysAuthorization
    func requestAlwaysAuth()
    
    /// Check user's location authorization status. If status is authorizedAlways or authorizedWhenInUse
    /// ciompletion executes.
    func checkLocationAuthIsEnabled(_ completion: @escaping () -> Void)
    
    /// Check that the user has enabled location tracking. If authorized
    /// shows user location on the map.
    func confirmUsersLocationAuthorizationStartTrackingLoc()
    
    func promptUserForLocationAuth() 
}
