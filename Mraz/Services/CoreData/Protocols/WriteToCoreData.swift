//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

protocol WriteToCoreData: ReadFromCoreData {
    var mainContext: NSManagedObjectContext { get }
    
    func saveObject<T: NSManagedObject>(object: T, model: BeerModel, in context: NSManagedObjectContext)
    func delete<T: NSManagedObject>(_ managedObject: T)
}
