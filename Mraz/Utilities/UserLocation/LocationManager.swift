//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit

final class LocationManager: NSObject, MrazLocationManager {
    // MARK: - Properties
    var mapView: MKMapView?
    weak var locationDelegate: CLLocationManagerDelegate?
    var locationManager: CLLocationManager? = {
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
}

// MARK: - CLLocationManager Delegate Methods
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Failed With Error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Tracking user, they updated location")
        guard let usersLastLocation = locations.last, let map = mapView else { return }
        let lat = usersLastLocation.coordinate.latitude
        let lng = usersLastLocation.coordinate.longitude
        let mapCenter = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: mapCenter, latitudinalMeters: mapRegionMeters, longitudinalMeters: mapRegionMeters)
        map.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("*!*!*!*!*!*!*! ENTERED REGION *!*!*!*!*!")
        LocalNotificationManger().triggerGeofencingNotification(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: confirmUsersLocationAuthorizationStartTrackingLoc()
        case .denied, .restricted: break
        case .notDetermined: requestAlwaysAuthFromUser()
        default: ()
        }
    }
}
