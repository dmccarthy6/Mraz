//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit

protocol LocationManager: NSObject, NotificationManager {
    var mapView: MKMapView { get }
    func checkAuthorizationStatus(_ completion: @escaping (Result<LocationAuthStatus, LocationAuthError>) -> Void)
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
    // Core Location Authorizations
    func checkAuthorizationStatus(_ completion: @escaping (Result<LocationAuthStatus, LocationAuthError>) -> Void) {
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
    
    func requestAuthorizationFromUser() {
        locationManager.requestWhenInUseAuthorization()
    }
 
    // MARK: - User Location Tracking
    func startTrackingUsersLocationOnMap() {
        mapView.showsUserLocation = true
    }
    
    // MARK: - Geofencing
    func updateUsersLocation(delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
        //request auth
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    ///
    func reateGeofencingRegionAndNotify() {
        let region = CLCircularRegion(center: Coordinates.mraz.location, radius: defaultGeofencingRadius, identifier: GeoRegion.identifier)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
    }
    
    ///
    func scheduleEnteredRegionNotification(_ region: CLRegion) {
        checkCurrentAuthorizationStatus { [unowned self] (result) in
            switch result {
            case .success(let granted):
                if granted {
                    self.setLocationTriggerFor(region)
                }
                
            case .failure(let authError): print("Error Checking Auth Status: \(authError)")
            }
        }
    }
    
    ///
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
    
    // MARK: -
    func getDirectonsTo(locationCoordinate: CLLocationCoordinate2D, title: String? = "Destination") {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let destination = MKPlacemark(coordinate: locationCoordinate)
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func showRestaurantActionSheet(_ viewController: UIViewController, location: CLLocationCoordinate2D = Coordinates.mraz.location, title: String?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Actions
        let phoneCallAction = UIAlertAction(title: "Call", style: .default) { (action) in
            //Handle Phone Calls
        }
        let directionsAction = UIAlertAction(title: "Directions", style: .default) { [unowned self] (action) in
            self.getDirectonsTo(locationCoordinate: location, title: title)
        }
        let menuAction = UIAlertAction(title: "Menu", style: .default) { (action) in
            //Handle Menu Action
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(phoneCallAction)
        alertController.addAction(directionsAction)
        alertController.addAction(menuAction)
        alertController.addAction(cancelAction)
        /// Present Controller
        viewController.present(alertController, animated: true, completion: nil)
    }
}

/*
 static func showBreweryLocationOnMap() {
     let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
     let coordinate = Coordinates.mraz.location
     let destination = MKPlacemark(coordinate: coordinate)
     let mrazMapItem = MKMapItem(placemark: destination)
     mrazMapItem.name = "Mraz Brewing Co."
     mrazMapItem.openInMaps(launchOptions: launchOptions)
 }
 */
