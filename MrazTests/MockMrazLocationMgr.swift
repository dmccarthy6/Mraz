//  Created by Dylan  on 9/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit
@testable import Mraz

class MockMrazLocationManager: MrazLocationManager {
    var locationManager: CLLocationManager? = {
        let locMgr = CLLocationManager()
        locMgr.desiredAccuracy = kCLLocationAccuracyBest
        locMgr.distanceFilter = kCLLocationAccuracyKilometer
        return locMgr
    }()
    
    weak var locationDelegate: CLLocationManagerDelegate?
    
    var mapView: MKMapView?
    
}
