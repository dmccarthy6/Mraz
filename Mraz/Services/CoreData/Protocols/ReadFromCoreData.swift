//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

protocol ReadFromCoreData: Managed {
    var frcPredicate: NSPredicate? { get set }
    
    func findOrFetchObject(matching predicate: NSPredicate) -> Beers?
}
