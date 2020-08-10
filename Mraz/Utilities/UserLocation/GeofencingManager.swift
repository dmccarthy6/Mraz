//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation

final class GeofencingManager: NSObject, LocationManager {
    // MARK: -
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Helpers
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    // MARK: - Monitor Region
    func monitorRegionAtBrewery() {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let maxDistance = locationManager.maximumRegionMonitoringDistance
            let region = CLCircularRegion(center: Coordinates.mraz.location,
                                          radius: maxDistance, identifier: GeoRegion.identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }
    
    // MARK: - Trigger Notification
    func triggerGeofencingNotification(_ region: CLRegion) {
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
}

extension GeofencingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Failed With Error")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Tracking user, they updated location")
        //guard let usersLastLocation = locations.last else { return }
        updateUsersLocation(delegate: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        triggerGeofencingNotification(region)
    }
}
