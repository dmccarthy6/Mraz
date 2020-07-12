//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit
import MapKit

final class MapViewController: UIViewController, LocationManager, MapContextMenu {
    // MARK: - Properties
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        return map
    }()
    private let modelController = MapViewModelController()
    private let mapIdentifier = "MrazMapID"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkLocationAuthorization()
        fetchRestaurants()
        modelController.addBreweryAnnotation(on: mapView)
        modelController.centerMapViewOnUsersLocation(mapView: mapView)
    }
    
    // MARK: - Layout
    private func setupView() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Authorization
    private func checkLocationAuthorization() {
        self.checkAuthorizationStatus { [unowned self] (result) in
            switch result {
            case .success(let authStatus):
                switch authStatus {
                case .requestAuthorization: self.requestAuthorizationFromUser()
                case .startTrackingUpdates:
                    DispatchQueue.main.async {
                        self.startTrackingUsersLocationOnMap()
                    }
                }
                
            case .failure(let authError):
                switch authError {
                case .deniedRestricted: print("DENIED OR RESTRICTED")
                }
            }
        }
    }
    
    // MARK: - Network
    func fetchRestaurants() {
        modelController.fetchLocationData { [unowned self] (result) in
            switch result {
            case .success(true), .success(false):
                DispatchQueue.main.async {
                    self.addMapAnnotations()
                }
                
            case .failure(let error): // TO-DO: Handle this error appropriately
                print("Error fetching from API: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Annotations
    private func addMapAnnotations() {
        modelController.addRestaurantLocations(on: mapView)
    }
    
}
// MARK: - MKMapView Delegate
extension MapViewController: MKMapViewDelegate {
    /// Method called when the user taps the annotation,
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        } else {
            guard let currentAnnotation = view.annotation else { return }
            if view.reuseIdentifier == mapIdentifier {
                self.showRestaurantActionSheet(self, location: currentAnnotation.coordinate, title: currentAnnotation.title ?? "Destination")
            } else {
                print("Title =- \(view.annotation?.title)")
                self.showRestaurantActionSheet(self, location: currentAnnotation.coordinate, title: currentAnnotation.title ?? "Destination")
            }
        }
    }
    
    /// Set images for the annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        if (annotation.title)! == Mraz.title {
            return setMarker(image: AnnotationImages.beerMug, for: annotation, identifier: mapIdentifier)
        }
        return nil
    }
    
    /// Helper method to set the image for the MKAnnotation view.
    func setMarker(image: UIImage, for annotation: MKAnnotation, identifier: String) -> MKAnnotationView? {
        var view: MKMarkerAnnotationView
        let annotationIsUserLocation = annotation is MKUserLocation
        if !annotationIsUserLocation {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.glyphImage = image
            view.annotation = annotation
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //
        print("View \(view.annotation?.title ?? "NO TITLE")")
        guard let currentAnnotation = view.annotation else { return }
        self.showRestaurantActionSheet(self, title: currentAnnotation.title ?? "Destination")
    }
}
// MARK: - CLLocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TO-DO: Error Handling
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        let mapCenter = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: mapCenter, latitudinalMeters: mapRegionMeters, longitudinalMeters: mapRegionMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("LocationManager -- User Entered Specified Region")
        scheduleEnteredRegionNotification(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: startTrackingUsersLocationOnMap()
        case .denied, .restricted: requestAuthorizationFromUser()
        case .notDetermined: requestAuthorizationFromUser()
        default: ()
        }
    }
}
