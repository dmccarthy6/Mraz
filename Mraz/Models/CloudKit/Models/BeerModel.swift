//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

struct BeerModel {
    let id: String
    let section: String
    let changeTag: String
    let name: String
    let beerDescription: String
    let abv: String
    let type: String
    let createdDate: Date
    let modifiedDate: Date
    let isOnTap: Bool
    let isFavorite: Bool
}
