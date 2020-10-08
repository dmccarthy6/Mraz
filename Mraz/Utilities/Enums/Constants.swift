//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

// MARK: - Brewery Information

/// Enum that containts all the brewery information (Name, Address, Phone#).
enum BreweryInfo {
    static let name = "Mraz Brewing Company"
    static let address = "222 Francisco Drive \nEl Dorado Hills, CA 95762"
    static let phone = "9169340744"
    static let website = "https://mrazbrewingcompany.com"
}

// MARK: - View Constants
enum AgeVerificationConstants {
    static let buttonWidthAnchors = CGFloat(200)
    static let buttonHeightAnchors = CGFloat(40)
}

enum BeerCellConstants {
    static let favIcon = CGFloat(35)
}

enum SocialConstants {
    static let iconWidth = CGFloat(25)
    static let iconHeight = CGFloat(25)
}
