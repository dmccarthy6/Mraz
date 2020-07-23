//  Created by Dylan  on 7/20/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreLocation
import MapKit

/*
    * This struct handles the interactions with the MKMapView.
        * Contains the Action Menu displayed when user taps an annotation
        * Contans the methods called by the buttons on the action sheet.
 */
struct MapInteractions {
    // MARK: - Properties
    let viewController: UIViewController
    let coordinate: CLLocationCoordinate2D
    
    // MARK: -
    func getDirections(title: String? = "Destination") {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let destination = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func placeCall(number: String?) {
        if let number = number, let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showMenu(url: URL?) {
        if let url = url {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if !success {
                    // Error opening link
                }
            }
        }
    }
    
    // MARK: - Show Restaurant Action Sheet
    func showRestaurantActionSheet(alertTitle: String?, alertMessage: String, phone: String?, url: URL?, restTitle: String?) {
        let actionSheet = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        
        let placePhoneCallAction = UIAlertAction(title: "Call", style: .default) { (_) in
            self.placeCall(number: phone)
        }
        let getDirectionsAction = UIAlertAction(title: "Directions", style: .default) { (_) in
            self.getDirections(title: restTitle)
        }
        let showMenuAction = UIAlertAction(title: "Show Menu", style: .default) { (_) in
            self.showMenu(url: url)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        actionSheet.addAction(placePhoneCallAction)
        actionSheet.addAction(getDirectionsAction)
        actionSheet.addAction(showMenuAction)
        actionSheet.addAction(cancelAction)
        viewController.present(actionSheet, animated: true)
    }
}
