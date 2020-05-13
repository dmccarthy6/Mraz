//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import MapKit

struct Contact {
    // MARK: - Types
    enum SocialHooks {
        case facebook
        case instagram
        case twitter
        
        var hook: String {
            switch self {
            case .facebook: return "fb://profile/MrazBrewingCompany"
            case .instagram: return "instagram://user?username=mrazbrewingco"
            case .twitter: return "twitter://user?screen_name=mrazbrewing"
            }
        }
        
        var webURL: String {
            switch self {
            case .facebook:     return "https://facebook.com/MrazBrewingCompany"
            case .instagram:    return "https://instagram.com/mrazbrewingco"
            case .twitter:      return "https://twitter.com/mrazbrewing"
            }
        }
    }
    
    // MARK: - Contact Methods
    /// Open the phone application and call the Brewery. Using the phone number: (916) 934-0744
    static func callBrewery() {
        guard let mrazPhoneURL = URL(string: "tel://9169340744"), UIApplication.shared.canOpenURL(mrazPhoneURL) else {
            return
        }
        UIApplication.shared.open(mrazPhoneURL, options: [:], completionHandler: nil)
    }
    
    /// Open the Mraz website. Current url is: www.mrazbrewingcompany.com
    static func openBreweryWebsite() {
        guard let mrazURL = URL(string: "https://mrazbrewingcompany.com") else { return }
        UIApplication.shared.open(mrazURL, options: [:]) { (success) in
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
    static func showBreweryLocationOnMap() {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let coordinate = Coordinates.mraz.location
        let destination = MKPlacemark(coordinate: coordinate)
        let mrazMapItem = MKMapItem(placemark: destination)
        mrazMapItem.name = "Mraz Brewing Co."
        mrazMapItem.openInMaps(launchOptions: launchOptions)
    }
    
    static func openBreweryFacebook() {
        openInApplicationOrWeb(for: .facebook)
    }
    
    static func openBreweryInstagram() {
        openInApplicationOrWeb(for: .instagram)
    }
    
    static func openBreweryTwitter() {
        openInApplicationOrWeb(for: .twitter)
    }
    
    // MARK: - Private methods
    /// This method takes an enum value and first tries to open the application (if the user has the specific application installed)
    /// If the user does not have the app installed Safari will be opened with the appropriate link.
    /// - Parameter social: SocialHools enum value to pass in for the application we're trying to open.
    private static func openInApplicationOrWeb(for social: SocialHooks) {
        let hook = social.hook
        guard let hookUrl = URL(string: hook) else { return }
        let application = UIApplication.shared
        
        if application.canOpenURL(hookUrl) {
            application.open(hookUrl, options: [:], completionHandler: nil)
        } else {
            guard let webURL = URL(string: social.webURL) else { return }
            application.open(webURL, options: [:], completionHandler: nil)
        }
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
