//  Created by Dylan  on 8/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit

protocol MrazLocationManager: MrazLocationAuthorization {
    var locationManager: CLLocationManager? { get set }
    var locationDelegate: CLLocationManagerDelegate? { get set }
    var mapView: MKMapView? { get }
}

extension MrazLocationManager {
    var defaultGeofencingRadius: Double {
        return 950
    }
    var mapRegionMeters: Double {
        return 1000
    }
    var currentAuthStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    // MARK: - Authorization
    func requestWhenInUseAuth() {
        CLLocationManager().requestWhenInUseAuthorization()
    }
    
    func checkLocationAuthIsEnabled(_ completion: @escaping () -> Void) {
        let locationAuthorized = currentAuthStatus == .authorizedAlways || currentAuthStatus == .authorizedWhenInUse
        locationAuthorized ? completion() : nil
    }
    
    func confirmUsersLocationAuthorizationStartTrackingLoc() {
        guard let safeMap = mapView else { return }
        checkLocationAuthIsEnabled {
            safeMap.showsUserLocation = true
        }
    }
    
    func promptUserForLocationAuth() {
        switch currentAuthStatus {
        case .authorizedAlways, .authorizedWhenInUse: monitorRegionAtBrewery()
        case .denied, .restricted: return
        case .notDetermined: requestWhenInUseAuth()
        default: ()
        }
    }
    
    func monitorRegionAtBrewery() {
        guard let locationManager = locationManager else { return }
        let breweryRegion = CLCircularRegion(center: Coordinates.mraz.location,
                                             radius: defaultGeofencingRadius, identifier: GeoRegion.identifier)
        let regionsBeingMonitored = locationManager.monitoredRegions
        let isMonitoringAvail = CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
        if !regionsBeingMonitored.contains(breweryRegion) && isMonitoringAvail {
            breweryRegion.notifyOnEntry = true
            breweryRegion.notifyOnExit = false
            locationManager.startMonitoring(for: breweryRegion)
        }
    }
}
