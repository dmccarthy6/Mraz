//  Created by Dylan  on 5/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreLocation
import MapKit

final class MapViewModelController: NSObject, Network, MapContextMenu {
    // MARK: - Properties
    var network: Networking {
        return self
    }
    var restaurants: [Restaurant] = []
    
    // MARK: - Network
    func fetchLocationData(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        fetchNearbyRestaurants { (result) in
            switch result {
            case .success(let mod):
                for location in mod.results {
                    let restaurantLoc = location.geometry.location
                    self.restaurants.append(Restaurant(lat: restaurantLoc.lat, lng: restaurantLoc.lng, name: location.name))
                    print("Heres the photo attributions: \(location.photos[0].htmlAttributions)")
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
    
    // MARK: - Set Zoom Region
    func centerMapViewOnUsersLocation(mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 15000
        let coordinateRegion = MKCoordinateRegion(center: Coordinates.mraz.location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Context Menu
    func createInteraction(annotationView: MKAnnotationView) {
        let interaction = UIContextMenuInteraction(delegate: self)
        annotationView.addInteraction(interaction)
    }
}

extension MapViewModelController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedAction in
            return self.makeMrazMapContextMenu()
        }
    }
}
