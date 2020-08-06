//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import MapKit

struct Contact {
    // MARK: - Properties
    private static let application = UIApplication.shared
    
    // MARK: - Contact Methods
    /// Open the phone application and call the Brewery. Using the phone number: (916) 934-0744
    static func placePhoneCall(to number: String) {
        guard let mrazPhoneURL = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(mrazPhoneURL) else {
            return
        }
        application.open(mrazPhoneURL, options: [:], completionHandler: nil)
    }
    
    /// Open the Mraz website. Current url is: www.mrazbrewingcompany.com
    static func open(website: String) {
        guard let mrazURL = URL(string: "\(website)") else { return }
        application.open(mrazURL, options: [:]) { (success) in
            if !success {
                //
                print("Error opening Mraz URL")
            } else {
                return
            }
        }
    }
    
    /// Open Apple Maps and set pin for Mraz Brewery location
    /// at 222 Francisco Drive, EDH, CA.
    static func getDirections(to coordinate: CLLocationCoordinate2D, title: String? = "Destination") {
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
