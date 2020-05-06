//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreLocation
import MapKit

final class RegionManager: NSObject {
    // MARK: - Properties
    let locationManager = CLLocationManager()
    private let defaultRadius: Double = 950
    private let center: Coordinates = .mraz
    private let regionIdentifier = "Mraz"
    private let regionInMeters: Double = 1000
    var currentLocation: CLLocation?

    // MARK: - Helpers
    
    ///Create the geofencing region and call 'startMonitoring' on that region
    func createRegionAndNotify() {
        let region = CLCircularRegion(center: center.location, radius: defaultRadius, identifier: regionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        locationManager.startMonitoring(for: region)
    }
    
    ///Update the user's location as the user moves.
    func updateLocation(to manager: CLLocationManager) {
        locationManager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
}
extension RegionManager: CLLocationManagerDelegate {
    ///User's location is updated -- Not using this?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation(to: manager)
//        guard let usersLocation = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: usersLocation.coordinate.latitude, longitude: usersLocation.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        //Can set the map region from here?
    }
    
    ///Called when the user changes their CK Status.
    //TO-DO: Figure out best way to handle this change?
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Always OR When In Use")
        case .notDetermined:
            print("Unknown - ask")
        case .denied, .restricted:
            print("Denied OR Restricted")
        default: ()
            
        }
    }
}
