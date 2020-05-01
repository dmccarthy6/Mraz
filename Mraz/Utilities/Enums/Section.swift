//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

/*
 Section enum for my CollectionView. Removing this from the CollectionViewController file
 */

enum Section: CaseIterable {
    case Ale, Amber, Belgian, Blonde, IPA, Lager, Mosaic, Porter, Saison, Sour, Stout
    
    var title: String {
        switch self {
        case .Ale:      return "Ale"
        case .Amber:    return "Amber"
        case .Belgian:  return "Belgian"
        case .Blonde:   return "Blonde"
        case .IPA:      return "IPA"
        case .Lager:    return "Lager"
        case .Mosaic:   return "Mosaic"
        case .Porter:   return "Porter"
        case .Saison:   return "Saison"
        case .Sour:     return "Sour"
        case .Stout:    return "Stout"
        }
    }
}

