//  Created by Dylan  on 4/30/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import MapKit

/*
 MRAZ:
    Lat: 38.710252,
    Long: -121.086191
 */
class MrazMapView: MKMapView {
    // MARK: - Properties
    private var map: MKMapView = {
        let map = MKMapView()
        map.isUserInteractionEnabled = true
        return map
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupView() {
        addSubview(map)
        
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.topAnchor.constraint(equalTo: topAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Interface
    func addMapAnnotation(coordinate: Coordinates, title: LocationTitle) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate.location
        annotation.title = title.rawValue
        map.addAnnotation(annotation)
    }
    
    func startTrackingUserLocation() {
        map.showsUserLocation = true
    }
}
