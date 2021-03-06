//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import MapKit

struct Contact {
    enum ContactType {
        case phone
        case web
        case directions
    }
    // MARK: - Properties
    private static let application = UIApplication.shared
    
    // MARK: - Contact Methods
    static func contact(contactType: ContactType,
                        value: String,
                        coordinate: CLLocationCoordinate2D = Coordinates.mraz.location) {
        switch contactType {
        case .phone:
            handleContact(method: "tel://\(value)")
        case .web:
            handleContact(method: "\(value)")
        case .directions:
            getDirections(to: coordinate, title: value)
        }
    }
    
    private static func handleContact(method: String) {
        guard let safeURL = URL(string: method), application.canOpenURL(safeURL) else {
            return
        }
        application.open(safeURL, options: [:], completionHandler: nil)
    }

    /// Open Apple Maps and set pin for Mraz Brewery location
    /// at 222 Francisco Drive, EDH, CA.
    private static func getDirections(to coordinate: CLLocationCoordinate2D, title: String? = "Destination") {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let mrazMapItem = MKMapItem(placemark: destinationPlacemark)
        mrazMapItem.name = title
        mrazMapItem.openInMaps(launchOptions: launchOptions)
    }
}

/*
 Website: www.mrazbrewingcompany.com
 Phone: (916) 934-0744
 Address: 222 Francisco Dr., suite 510 El Dorado Hills, CA 95762
 
 Facebook: https://www.facebook.com/MrazBrewingCompany/
 Instagram: https://www.instagram.com/mrazbrewingco/
 Twitter: @MrazBrewing
 */
