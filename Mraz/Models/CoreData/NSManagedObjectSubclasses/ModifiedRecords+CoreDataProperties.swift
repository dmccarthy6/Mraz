//  Created by Dylan  on 5/7/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreData

extension ModifiedRecords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ModifiedRecords> {
        return NSFetchRequest<ModifiedRecords>(entityName: "ModifiedRecords")
    }

    @NSManaged public var modifiedDate: Date?

}
