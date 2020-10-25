//  Created by Dylan  on 10/20/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

enum TabsViewModel: String, CaseIterable {
    case home
    case beers
    case food
    
    //
    var icon: UIImage? {
        switch self {
        case .home:         return SystemImages.houseImage
        case .beers:      return TabBarImages.beerMug
        case .food:           return SystemImages.mapImage
        }
    }
    
    var title: String { rawValue }
}
