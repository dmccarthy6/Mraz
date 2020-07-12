//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

// MARK: - Brewery Information

/// Enum that containts all the brewery information (Name, Address, Phone#).
enum Mraz {
    static let title = "Mraz Brewing Co."
    static let address = "222 Francisco Dr., Suite 510 El Dorado Hills, CA"
    static let phone = "916-934-0744"
}

// MARK: - View Constants
enum AgeVerificationConstants {
    static let viewWidthAnchor = CGFloat(370)
    static let viewHeightAnchor = CGFloat(350)
    static let buttonWidthAnchors = CGFloat(300)
}

enum BeerCellConstants {
    static let favIcon = CGFloat(35)
}

enum SocialConstants {
    static let iconWidth = CGFloat(25)
    static let iconHeight = CGFloat(25)
}
