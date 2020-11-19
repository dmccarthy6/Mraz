//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import MapKit
import os.log

final class MapViewController: UIViewController, UserLocationUpdatedDelegate {
    // MARK: - Properties
    let log = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: MapViewController.self))
    
    lazy var mapView: MZMapView = {
        let map = MZMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        return map
    }()
    
    private let mapIdentifier = "MrazMapID"
    
    private lazy var locationManager: CLLocationManager = {
        return locationProvider.locationManager
    }()
    
    var locationProvider = CurrentLocationProvider()
    
    var mapRegionMeters: Double {
        return 1000
    }
    
    private var fetchedRestaurants: [Restaurant] = []
    
    /// URL Request for restaurants
    private let restaurantsRequest = RestaurantsRequest()
    
    private var annotationCoordinate: MKAnnotation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchRestaurants()
        locationProvider.locationChangedDelegate = self
        showUsersCurrentLocationOnMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUsersCurrentLocationOnMap()
        mapView.centerMapViewOnUsersLocation(mapView: mapView)
    }
    
    // MARK: - Layout
    private func setupView() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Network
    func fetchRestaurants() {
        let loader = APIRequestLoader(apiRequest: restaurantsRequest)
        loader.loadAPIRequest(requestData: Coordinates.mraz.location) { (rootObject, error) in
            guard error == nil else { return } // FIX THIS
            
            if let rootObject = rootObject {
                for restaurant in rootObject.results {
                    let location = restaurant.geometry.location
                    let restaurant = Restaurant(lat: location.lat, lng: location.lng, name: restaurant.name ?? "Nil")
                    self.fetchedRestaurants.append(restaurant)
                }
            }
            DispatchQueue.main.async {
                self.mapView.addRestaurantLocations(self.fetchedRestaurants)
            }
        }
    }

    // MARK: - Context Menu
    func makeContextMenu() -> UIMenu {
        let directions = UIAction(title: "Directions", image: SystemImages.mapFillImage) { _ in
            //Show System Share Sheet
            guard let currentAnnotation = self.annotationCoordinate else { return }
            let restaurantTitle = currentAnnotation.title ?? ""
            Contact.contact(contactType: .directions, value: restaurantTitle ?? "", coordinate: currentAnnotation.coordinate)
        }
        return UIMenu(title: "", children: [directions])
    }
    
    func addInteractionTo(_ view: UIView) {
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(contextMenuInteraction)
    }
    
    // MARK: - UserLocationUpdated Delegate Methods
    func centerMapOnUsersLocation() {
        locationProvider.locationChangedCallback = {[weak self] location in
            guard let self = self else { return }
            
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            let mapCenter = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: mapCenter, latitudinalMeters: self.mapRegionMeters, longitudinalMeters: self.mapRegionMeters)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    /// Check users Location Auth status and show location on map.
    func showUsersCurrentLocationOnMap() {
        let currentLocationStatus = locationProvider.currentAuthStatus
        
        if currentLocationStatus == .authorizedAlways || currentLocationStatus == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
        } else {
            self.mapView.showsUserLocation = false
        }
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
            annotationCoordinate = currentAnnotation
            addInteractionTo(view)
        }
    }
    
    /// Set images for the annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        if (annotation.title)! == BreweryInfo.name {
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
}

// MARK: - Context Menu Delegate Methods
extension MapViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.makeContextMenu()
        }
    }
}
