//  Created by Dylan  on 11/14/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import MapKit

final class MZMapView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addBreweryAnnotation()
        showsUserLocation = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func centerMapViewOnUsersLocation(mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 15000
        let coordinateRegion = MKCoordinateRegion(center: Coordinates.mraz.location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotation(with title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, on map: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        map.addAnnotation(annotation)
    }
    
    func addRestaurantLocations(_ restaurants: [Restaurant]) {
        for restaurant in restaurants {
            let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lng)
            addAnnotation(with: restaurant.name, subtitle: nil, coordinate: coordinate, on: self)
        }
    }
    
    func addBreweryAnnotation() {
        addAnnotation(with: BreweryInfo.name, subtitle: BreweryInfo.address, coordinate: Coordinates.mraz.location, on: self)
    }
}
