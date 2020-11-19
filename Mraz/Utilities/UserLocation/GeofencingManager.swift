//  Created by Dylan  on 11/16/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

final class GeofencingManager {
    // MARK: - Properties
    var defaultRadius: Double {
        return 950
    }
    
    let locationManager: CLLocationManager
    
    // MARK: - Lifecycle
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    // MARK: - Monitor Region
    func monitorRegionAtBrewery() {
        let mrazBreweryRegion = CLCircularRegion(center: Coordinates.mraz.location, radius: defaultRadius, identifier: GeoRegion.identifier)
        let currentlyMonitoredRegions = locationManager.monitoredRegions
        let isMonitoringAvailable = CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
        
        if !currentlyMonitoredRegions.contains(mrazBreweryRegion) && isMonitoringAvailable {
            mrazBreweryRegion.notifyOnEntry = true
            locationManager.startMonitoring(for: mrazBreweryRegion)
        }
    }
}
