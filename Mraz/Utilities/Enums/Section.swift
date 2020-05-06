//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

/*
 Section enum for my CollectionView. Removing this from the CollectionViewController file
 */

enum Section: CaseIterable {
    case ale, amber, belgian, blonde, ipa, lager, mosaic, porter, saison, sour, stout
    
    var title: String {
        switch self {
        case .ale:      return "Ale"
        case .amber:    return "Amber"
        case .belgian:  return "Belgian"
        case .blonde:   return "Blonde"
        case .ipa:      return "IPA"
        case .lager:    return "Lager"
        case .mosaic:   return "Mosaic"
        case .porter:   return "Porter"
        case .saison:   return "Saison"
        case .sour:     return "Sour"
        case .stout:    return "Stout"
        }
    }
}
