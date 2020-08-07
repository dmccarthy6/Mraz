//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreLocation
import MapKit

final class MapViewModelController: NSObject, Network {
    // MARK: - Properties
    var network: Networking {
        return self
    }
    var restaurants: [Restaurant] = []
    private var annotationID = "ID"
    
    // MARK: - Network
    func fetchLocationData(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        fetchNearbyRestaurants { (result) in
            switch result {
            case .success(let mod):
                for location in mod.results {
                    let restaurantLoc = location.geometry.location
                    self.restaurants.append(Restaurant(lat: restaurantLoc.lat, lng: restaurantLoc.lng, name: location.name))
                }
                completion(.success(true))
            case .failure(let apiError):
                print(apiError)
                completion(.failure(apiError))
            }
        }
    }
    
    // MARK: - Annotations
    /// Adds the Mraz annotation on the map.
    /// - Parameter map: The map used to add this annotation on to.
    func addBreweryAnnotation(on map: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: LocationCoordinates.mrazLat, longitude: LocationCoordinates.mrazLong)
        annotation.title = Mraz.title
        annotation.subtitle = Mraz.address
        map.addAnnotation(annotation)
    }
    
    /// Add all the restaurant locations
    /// - Parameter map: The MapView to add these annotations.
    func addRestaurantLocations(on map: MKMapView) {
        guard restaurants.count > 0 else { return }
        for location in restaurants {
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            map.addAnnotation(annotation)
        }
    }
    
    func addInteractions(on view: UIView, contextMenuDelegate: UIContextMenuInteractionDelegate) {
        let interaction = UIContextMenuInteraction(delegate: contextMenuDelegate)
        view.addInteraction(interaction)
    }
    
    // MARK: - Set Zoom Region
    func centerMapViewOnUsersLocation(mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 15000
        let coordinateRegion = MKCoordinateRegion(center: Coordinates.mraz.location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
