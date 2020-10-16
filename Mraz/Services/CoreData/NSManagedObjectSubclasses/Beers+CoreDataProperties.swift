//  Created by Dylan  on 5/7/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreData

extension Beers: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Beers> {
        return NSFetchRequest<Beers>(entityName: "Beers")
    }

    @NSManaged public var abv: String?
    @NSManaged public var beerDescription: String?
    @NSManaged public var beerType: String?
    @NSManaged public var changeTag: String?
    @NSManaged public var ckCreatedDate: Date?
    @NSManaged public var ckModifiedDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isOnTap: Bool
    @NSManaged public var name: String?
    @NSManaged public var section: String?

    static func == (lhs: Beers, rhs: Beers) -> Bool {
        lhs.id == rhs.id
    }
}
