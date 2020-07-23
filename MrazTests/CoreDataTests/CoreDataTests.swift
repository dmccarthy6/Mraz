//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
import CoreData
@testable import Mraz

class CoreDataTests: XCTestCase, CoreDataAPI {
    // MARK: - Properties
    let context = CoreDataUnitTestHelpers.setUpInMemoryManagedObjectContext()
    var beerModel: [BeerModel]?
    
    // MARK: - Set Up
    override func setUpWithError() throws {
        super.setUp()
        setupTestData()
    }

    func setupTestData() {
        beerModel = [BeerModel(id: UUID().uuidString,
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
    
    // MARK: - Core Data Tests
    func testBeerObjectsCreated() {
        /// Delete all objects in context to start from scratch.
        deleteAllObjectsFromContext()
        createBeerObjects()
        /// Check that the managed object is being inserted into the context.
        XCTAssert(context.insertedObjects.count == beerModel?.count)
        
        // Create Fetch Request
        let fetchRequest = Beers.fetchRequest() as NSFetchRequest<Beers>
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertNoThrow(results)
            //XCTAssertTrue(results.count == beerModel?.count, "The fetch count is \(results.count) & it should be: \(beerModel?.count ?? 9999)")
            
        } catch {
            XCTFail("Unable to fetch managed objects")
        }
    }
    
    /// Test fetching from the context works.
    func testBeersFetch() {
        deleteAllObjectsFromContext()
        createBeerObjects()
        
        do {
            let fetchedObjects = try CoreDataUnitTestHelpers.fetchObjects(in: context, sortedBy: "name", ascending: true) as [Beers]
            XCTAssert(fetchedObjects.count == beerModel?.count)
        } catch {
            XCTFail("Failure fetching")
        }
    }

    // MARK: - Helper Methods
    /// Helper function to create a beer object
    private func createBeerObjects() {
        for model in beerModel! {
            let beerObj = Beers(context: context)
            createBeerObject(from: model, beer: beerObj, context: context)
        }
    }
    
    private func deleteAllObjectsFromContext() {
        do {
            try CoreDataUnitTestHelpers.deleteAllObjects(objectType: Beers.self, with: context)
        } catch {
            XCTFail("CoreDataTests -- Failed to delete all objects from context.")
        }
    }
    
    // MARK: - Teardown
    override func tearDownWithError() throws {
        beerModel = nil
    }
}
