//  Created by Dylan  on 5/11/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

struct OnTap: Hashable {
    let id: String
    let beerName: String
    let beerABV: String
    let beerDescription: String
    
    // Hashable Conformance
    static func == (lhs: OnTap, rhs: OnTap) -> Bool {
        return lhs.id == rhs.id
    }
}
