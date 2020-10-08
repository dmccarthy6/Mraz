//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

protocol WriteToCoreData: ReadFromCoreData {
    var mainThreadContext: NSManagedObjectContext { get }
    
    func save(context: NSManagedObjectContext)
    func saveObject<T: NSManagedObject>(object: T, model: BeerModel, modifiedDate: Date, in context: NSManagedObjectContext)
    func delete<T: NSManagedObject>(_ managedObject: T)
}
