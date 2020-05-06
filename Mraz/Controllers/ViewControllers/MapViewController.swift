//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit
import MapKit

final class MapViewController: UIViewController {
    // MARK: - Properties
    private lazy var map: MrazMapView = {
        let map = MrazMapView()
        map.delegate = self
        return map
    }()
    private let annotationID = "MapIdentifier"
    private var selectedAnnotation: MKAnnotation?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutView()
        checkVerification()
    }
    
    // MARK: - Helpers
    private func layoutView() {
        view.addSubview(map)
        
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func checkVerification() {
        LocationAuthorization.checkLocationAuthorization { (result) in
            switch result {
            case .success(.startTrackingUpdates):
                print("")
                self.map.startTrackingUserLocation()
                self.map.addMapAnnotation(coordinate: .mraz, title: .mraz)
            case .success(.requestAuthorization):
                print("Request Auth")
                
            case .failure(.deniedRestricted):
                print("DENIED OR RESTRICTED HANDLE WITH USER")
            }
        }
    }
}
extension MapViewController: MKMapViewDelegate {
    ///
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        } else {
            selectedAnnotation = view.annotation
            if view.reuseIdentifier == annotationID {
                Alerts.showRestaurantActionSheet(self)
            } else {
                //Alert?
            }
        }
    }
    
    /// Use this method to set the images for the annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        //Get Images -- enum?
        let mrazImage = UIImage(named: "")
        let otherImage = UIImage(named: "")
        
        if annotation.title == LocationTitle.mraz.rawValue {
            return setMarkerImage(image: AnnotationImages.mrazAnnotation!, annotation: annotation, id: annotationID)
        } else {
            return setMarkerImage(image: AnnotationImages.mrazAnnotation!, annotation: annotation, id: annotationID)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //What to do when the image is tapped.
        // -- TO-DO: Show Action Sheet from Here?
        Alerts.showRestaurantActionSheet(self)
    }
    
    // MARK: - Helpers
    
    ///Method that sets the image for the map marker
    /// - Parameters:
    ///     - image: UIImage to set on the marker
    ///     - annotation: the annotation to set the image and identifer on
    ///     - id: Identifier value
    /// - Returns: Optional MKAnnotation view with the image and ID set.
    private func setMarkerImage(image: UIImage, annotation: MKAnnotation, id: String) -> MKAnnotationView? {
        var view: MKMarkerAnnotationView
        
        if !(annotation is MKUserLocation) {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.glyphImage = image
            view.annotation = annotation
            return view
        }
        return nil
    }
}
