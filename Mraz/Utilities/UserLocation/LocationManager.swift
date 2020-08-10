//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit

protocol LocationManager: NSObject, NotificationManager {
    var mapView: MKMapView { get }
}

extension LocationManager {
    var mapView: MKMapView {
        return MKMapView()
    }
    var locationManager: CLLocationManager {
        return CLLocationManager()
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
    /// Check the user's location authorization status. if authorized
    /// creates geofencing region and starts tracking user on map. If not authorized
    /// requests authorization.
    func checkUsersLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            createGeofencingRegionAndNotify()
            startTrackingUsersLocationOnMap()
        case .notDetermined:
            requestAuthorizationFromUser()
        case .denied, .restricted:
            break
        default: break
        }
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
        checkUsersLocationAuth()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Geofencing
    /// Method that creates the Geofencing Region and Notifies User when they enter via Local Notification.
    private func createGeofencingRegionAndNotify() {
        let region = CLCircularRegion(center: Coordinates.mraz.location,
                                      radius: defaultGeofencingRadius,
                                      identifier: GeoRegion.identifier)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
    }
    
    /// Check the user's local notification setting status and calls setLocationTrigger to
    /// create the notification content for the Geofencing local notification.
    func scheduleEnteredRegionNotification(_ region: CLRegion) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestUserAuthForNotifications { (result) in
                    switch result {
                    case .failure(let error): print("\(error.localizedDescription)")
                    case .success(let granted):
                        if granted {
                            self.setLocationTriggerFor(region)
                        }
                    }
                }
            case .authorized, .provisional:
                self.setLocationTriggerFor(region)
            case .denied: break
            default: break
            }
        }
    }
    
    ///Set geofencing location trigger for a region.
    private func setLocationTriggerFor(_ region: CLRegion) {
        let note = Notification(id: region.identifier,
                                title: GeoNotificationContent.title,
                                subTitle: "",
                                body: GeoNotificationContent.body)
        let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let notificationManager = LocalNotificationManger(notificationTrigger: locationTrigger)
        notificationManager.notifications = [note]
        notificationManager.schedule()
    }
}
