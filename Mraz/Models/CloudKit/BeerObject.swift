//  Created by Dylan  on 4/29/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

/*
 
 */

struct BeerObject {
    let abv: String
    let beerDesciption: String
    let beerType: String
    let id: CKRecord.ID
    let name: String
    let section: String
    let changeTag: String
    let isFavorite: Bool
    let isOnTap: Bool
    let creationDate: Date
    let modifiedDate: Date
}
