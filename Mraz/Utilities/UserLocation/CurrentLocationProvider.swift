//  Created by Dylan  on 11/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreLocation
import MapKit

/// Protocol used to notify MapViewController when the user's location changes
/// or to enable showing the user's location on the map.
protocol UserLocationUpdatedDelegate: class {
    /// Method called when users location changes. Trigger map to center on users location
    func centerMapOnUsersLocation()
    
    /// If location authorized, shows users current location on map.
    func showUsersCurrentLocationOnMap()
}

final class CurrentLocationProvider: NSObject {
    // MARK: - Properties
    var locationFetcher: LocationFetcher
    
    weak var locationChangedDelegate: UserLocationUpdatedDelegate?
    
    // Callback Methods
    var locationChangedCallback: ((CLLocation) -> Void)?
    var currentRegionCallback: ((CLRegion) -> Void)?
    var authStatusChangedCallback: ((CLAuthorizationStatus) -> Void)?
    
    var currentAuthStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        return locationManager
    }()
    
    // MARK: - Lifecycle
    init(locationFetcher: LocationFetcher = CLLocationManager()) {
        self.locationFetcher = locationFetcher
        super.init()
        
        self.locationFetcher.locationFetcherDelegate = self
        self.locationFetcher.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Geofencing
    
    /// Send a geofencing notification when user enters the specified region
    public func sendGeofencingNotification() {
        let localNotificationManager = LocalNotificationManger()
        
        currentRegionCallback = { region in
            localNotificationManager.triggerGeofencingNotification(for: region)
        }
    }
    
    // MARK: - Location Authorization
    public func checkLocationAuthStatus() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                requestAlwaysAuth()
            }
        }
    }
    
    private func requestAlwaysAuth() {
        // Confirm we haven't asked already
        guard currentAuthStatus == .notDetermined else { return }
        
        authStatusChangedCallback = {[weak self] authStatus in
            guard let self = self else { return }
            
            if authStatus == .authorizedWhenInUse {
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.pausesLocationUpdatesAutomatically = true
            }
            if authStatus == .authorizedAlways {
                let geofencingManager = GeofencingManager(locationManager: self.locationManager)
                geofencingManager.monitorRegionAtBrewery()
                self.locationChangedDelegate?.showUsersCurrentLocationOnMap()
            }
        }
        self.locationManager.requestWhenInUseAuthorization()
    }
}

extension CurrentLocationProvider: LocationFetcherDelegate {
    func locationFetcher(_ fetcher: LocationFetcher, didChangeAuthorization: CLAuthorizationStatus) {
        authStatusChangedCallback?(didChangeAuthorization)
    }
    
    func locationFetcher(_ fetcher: LocationFetcher, didFailWithError error: Error) {
        guard let coreLocationError = error as? CLError else { return }
        
        if coreLocationError.code == .network || coreLocationError.code == .denied {
            //Alert to user?
        } else if coreLocationError.code == .regionMonitoringResponseDelayed {
            let userDict = coreLocationError.userInfo
            guard let alternateRegion = userDict["alternateRegion"] as? CLRegion else { return }
            currentRegionCallback?(alternateRegion)
        }
    }
    
    func locationFetcher(_ fetcher: LocationFetcher, didUpdateLocations locs: [CLLocation]) {
        guard let updatedLocation = locs.first else { return }
        locationChangedCallback?(updatedLocation)
        locationChangedDelegate?.centerMapOnUsersLocation()
    }
    
    func locationFetcher(_ fetcher: LocationFetcher, didEnterRegion region: CLRegion) {
        currentRegionCallback?(region)
        sendGeofencingNotification()
    }
}

extension CurrentLocationProvider: CLLocationManagerDelegate {
    // Called when CLLocationManager fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationFetcher(manager, didFailWithError: error)
    }
    
    // Called when user's phone moves
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationFetcher(manager, didUpdateLocations: locations)
    }
    
    // Trigger notification when user enters a region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.locationFetcher(manager, didEnterRegion: region)
    }
    
    // Delegate method called when user changes their Location Authorization Status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationFetcher(manager, didChangeAuthorization: status)
    }
}
