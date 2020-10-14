//  Created by Dylan  on 10/11/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CoreData

protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
    
    /// Update or create a new beer object from a local model.
    /// - Parameter object: Beers object to create or update
    /// - Parameter model: Local BeerModel corresponding to the Beers object
    static func updateOrCreate(_ object: Self, from model: BeerModel) {
        guard let object = object as? Beers else { return }
        object.id = model.id
        object.name = model.name
        object.beerDescription = model.beerDescription
        object.abv = model.abv
        object.section = model.section
        object.beerType = model.type
        object.changeTag = model.changeTag
        object.isFavorite = model.isFavorite
        object.isOnTap = model.isOnTap
        object.changeTag = model.changeTag
        object.ckCreatedDate = model.createdDate
    }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String {
        return EntityName.beers.rawValue
    }
    
    // MARK: - Fetching
    static func fetch(in context: NSManagedObjectContext, configurationBlock: ((NSFetchRequest<Self>) -> Void) = {_ in}) -> [Self] {//64
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
    /// Use this method to first check the context to see if a single item matches the predicate. If not, fetch request is performed.
    /// Only use this method when there is one object that can match a predicate.
    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        return object
    }
    
    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else {
                continue
            }
            return result
        }
        return nil
    }
}
