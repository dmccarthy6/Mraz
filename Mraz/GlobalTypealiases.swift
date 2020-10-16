//  Created by Dylan  on 7/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

typealias EmptyClosure = (() -> Void)
typealias CloudKitAPI = ReadFromCloudKit 
typealias CoreDataAPI = ReadFromCoreData & WriteToCoreData

/// Generic NSFetchRequest for Core Data Fetching
typealias CoreDataFetchRequestFor = NSFetchRequest<NSFetchRequestResult>
