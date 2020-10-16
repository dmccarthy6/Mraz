//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit
import os.log

final class LocationManager: NSObject, MrazLocationManager {
    // MARK: - Properties
    let mrazLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: LocationManager.self))
    var mapView: MKMapView?
    weak var locationDelegate: CLLocationManagerDelegate?
    private var requestAlwaysAuthCallback: ((CLAuthorizationStatus) -> Void)?
    lazy var locationManager: CLLocationManager? = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLLocationAccuracyKilometer
        return CLLocationManager()
    }()

    // MARK: - Life Cycle
    override init() {
        super.init()
        configureLocationManager()
    }
    
    // MARK: - Configuration
    private func configureLocationManager() {
        locationDelegate = self
        locationManager?.delegate = locationDelegate
    }
    
    // MARK: - Auth
    func requestAlwaysAuth() {
        // don't ask if we've already asked
        guard currentAuthStatus == .notDetermined else { return }
        
        self.requestAlwaysAuthCallback = { [weak self] status in
            guard let self = self else { return }
            if status == .authorizedWhenInUse {
                self.locationManager?.requestAlwaysAuthorization()
                self.locationManager?.allowsBackgroundLocationUpdates = true
                self.locationManager?.pausesLocationUpdatesAutomatically = true
            }
        }
        self.locationManager?.requestWhenInUseAuthorization()
    }
    
}

// MARK: - CLLocationManager Delegate Methods
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("Location failed with the following error: %@",
               log: self.mrazLog,
               type: .error,
               error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        os_log("User moved, updating location", log: self.mrazLog, type: .debug)
        guard let usersLastLocation = locations.last, let map = mapView else { return }
        let lat = usersLastLocation.coordinate.latitude
        let lng = usersLastLocation.coordinate.longitude
        let mapCenter = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: mapCenter, latitudinalMeters: mapRegionMeters, longitudinalMeters: mapRegionMeters)
        map.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        os_log("User entered geofencing region: %@", log: self.mrazLog, type: .default, region.identifier)
        LocalNotificationManger().triggerGeofencingNotification(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("User changed location authroization status", log: self.mrazLog, type: .debug)
        self.requestAlwaysAuthCallback?(status)
//        let requestAuth = (status == .notDetermined)
//        mapView?.showsUserLocation = (status == .authorizedAlways)
//        requestAuth ? requestAlwaysAuth() : nil
    }
}
