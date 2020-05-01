//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreData
import CloudKit

extension Beers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Beers> {
        return NSFetchRequest<Beers>(entityName: "Beers")
    }

    @NSManaged public var abv: String?
    @NSManaged public var beerDescription: String?
    @NSManaged public var beerType: String?
    @NSManaged public var id: CKRecord.ID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isOnTap: Bool
    @NSManaged public var name: String?
    @NSManaged public var section: String?
    @NSManaged public var changeTag: String?
    @NSManaged public var ckCreatedDate: Date?
    @NSManaged public var ckModifiedDate: Date?

}
