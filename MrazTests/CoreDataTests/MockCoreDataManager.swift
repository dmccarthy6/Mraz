//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreData
@testable import Mraz

class MockCoreDataManager {
    // MARK: - Types
    enum CoreDataError: Error {
        case missingContext
        case errorWhileDeleting
        case couldNotCreateFetchReq
        case errorFetchingData
    }
    
    // MARK: - Properties
    var coreDataStore: CoreDataStore = CoreDataStore(.inMemory)
    
    lazy var mainContext = coreDataStore.mainThreadContext
    
    // MARK: - Saving
    func createBeer(object: Beers, from model: BeerModel) {
        object.id = model.id
        object.abv = model.abv
        object.beerDescription = model.beerDescription
        object.beerType = model.type
        object.changeTag = model.changeTag
        object.ckCreatedDate = model.createdDate
        object.ckModifiedDate = model.modifiedDate
        object.isFavorite = model.isFavorite
        object.isOnTap = model.isOnTap
        object.name = model.name
        object.section = model.section
    }
    
    // MARK: - Fetching
    class func fetchObjects<T: NSManagedObject>(in context: NSManagedObjectContext) throws -> [T] {
        guard let fetchReq = Beers.sortedFetchRequest as? NSFetchRequest<T> else {
            throw CoreDataError.couldNotCreateFetchReq
        }
        do {
            let results = try context.fetch(fetchReq)
            return results
        } catch {
            throw CoreDataError.errorFetchingData
        }
    }
    
    // MARK: - Deleting
    /// Delete Objects from the in memory context passed in.
    class func deleteAllObjects<T: NSManagedObject>(objectType: T.Type, with context: NSManagedObjectContext) throws {
        guard let deleteObjectsFetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else {
            throw CoreDataError.couldNotCreateFetchReq
        }
        
        do {
            let fetchResults = try context.fetch(deleteObjectsFetchRequest)
            print("Found \(fetchResults.count) objects of type \(T.description())")
            fetchResults.forEach { (managedObject) in
                context.delete(managedObject)
            }
            try context.save()
        } catch {
            throw CoreDataError.couldNotCreateFetchReq
        }
    }
    
    // MARK: - Helpers
    func createModelObjects() -> [BeerModel] {
        return [BeerModel(id: UUID().uuidString,
                               section: "Ale",
                               changeTag: "CKChangeTag",
                               name: "TestBeer",
                               beerDescription: "Test beer is delicious",
                               abv: "4.5",
                               type: "Ale",
                               createdDate: Date(),
                               modifiedDate: Date(),
                               isOnTap: true,
                               isFavorite: false),
            BeerModel(id: UUID().uuidString,
                      section: "Belgian",
                      changeTag: "CKChangeTag1",
                      name: "TestBeer1",
                      beerDescription: "Test beer is delicious also",
                      abv: "4.7",
                      type: "Belgian",
                      createdDate: Date(),
                      modifiedDate: Date(),
                      isOnTap: false,
                      isFavorite: false)
        ]
    }
}
