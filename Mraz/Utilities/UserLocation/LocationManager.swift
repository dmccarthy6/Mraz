//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit

protocol LocationManager: NSObject, NotificationManager {
    var mapView: MKMapView { get }
    func getUserLocationAuthStatus(_ completion: @escaping (Result<LocationAuthStatus, LocationAuthError>) -> Void)
    func requestAuthorizationFromUser()
}

extension LocationManager {
    var mapView: MKMapView {
        let map = MKMapView()
        return map
    }
    var locationManager: CLLocationManager {
        let manager = CLLocationManager()
        return manager
    }
    var defaultGeofencingRadius: Double {
        return 950
    }
    
    var mapRegionMeters: Double {
        return 1000
    }
    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    // MARK: - Authorization
    /// Check user's CLLocationManager authorization status
    /// - Returns: Result type with a LocationAuthStatus and LocationAuthError types.
    func getUserLocationAuthStatus(_ completion: @escaping (Result<LocationAuthStatus, LocationAuthError>) -> Void) {
        let currentStatus = CLLocationManager.authorizationStatus()
        switch currentStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            completion(.success(.startTrackingUpdates))
        case .notDetermined:
            completion(.success(.requestAuthorization))
        case .denied, .restricted:
            completion(.failure(.deniedRestricted))
        default: ()
        }
    }
    
    func requestLocationAuthorizationAndCreateGeofencingRegion() {
        requestAuthorizationFromUser()
        createGeofencingRegionAndNotify()
    }
    
    /// Request location authorization from users - for Geofencing.
    func requestAuthorizationFromUser() {
        locationManager.requestWhenInUseAuthorization()
    }
 
    // MARK: - User Location Tracking
    func startTrackingUsersLocationOnMap() {
        mapView.showsUserLocation = true
    }
    
    func updateUsersLocation(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
        //request auth
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Geofencing
    /// Method that creates the Geofencing Region and Notifies User when they enter via Local Notification.
    func createGeofencingRegionAndNotify() {
        let region = CLCircularRegion(center: Coordinates.mraz.location, radius: defaultGeofencingRadius, identifier: GeoRegion.identifier)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
    }
    
    ///
    func scheduleEnteredRegionNotification(_ region: CLRegion) {
        obtainUserNotificationAuthStatus { [unowned self] (result) in
            switch result {
            case .success(let granted):
                if granted {
                    self.setLocationTriggerFor(region)
                }
            case .failure(let authError): print("Error Checking Auth Status: \(authError)")
            }
        }
    }
    
    ///Set geofencing location trigger for a region.
    func setLocationTriggerFor(_ region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = GeoNotificationContent.title
        content.body = GeoNotificationContent.body
        content.sound = UNNotificationSound.default
        content.badge = 1

        let identifier = region.identifier
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: locationTrigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error { print(error.localizedDescription) }
        }
    }
}
