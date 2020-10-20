//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
import CoreData
@testable import Mraz

class CoreDataTests: XCTestCase {
    // MARK: - Properties
    var manager: MockCoreDataManager!
    var beerModel: [BeerModel]?
    
    // MARK: - Set Up
    override func setUpWithError() throws {
        super.setUp()
        
        manager = MockCoreDataManager()
        beerModel = manager.createModelObjects()
    }
    
    // MARK: - Core Data Tests
    func testManagedObjectsCreated() {
        beerModel?.forEach({ (beer) in
            let newBeer = Beers(context: manager.mainContext)
            manager.createBeer(object: newBeer, from: beer)
            print(manager.mainContext.insertedObjects.count)
        })
        
        //
        XCTAssert(manager.mainContext.insertedObjects.count == beerModel?.count, "The context's inserted objects don't match the model objects saved")
        
        // Create and Perform Fetch
        let testFetchRequest = Beers.sortedFetchRequest
        do {
            let results = try manager.mainContext.fetch(testFetchRequest)
            XCTAssertNoThrow(results)
            XCTAssertTrue(results.count == beerModel?.count, "Fetched results count \(results.count) does not equal model objects: \(beerModel?.count ?? 9999999999)")
        } catch {
            XCTFail("Unable to fetch objects. \(error.localizedDescription)")
        }
    }
 
    /// Test fetching from the context works.
    func testBeersFetch() {
        beerModel?.forEach({ (beer) in
            let createdBeer = Beers(context: manager.mainContext)
            manager.createBeer(object: createdBeer, from: beer)
        })
    
        do {
            let fetchedObjects = try MockCoreDataManager.fetchObjects(in: manager.mainContext) as [Beers]
            XCTAssert(fetchedObjects.count == beerModel?.count)
        } catch {
            XCTFail("Failure fetching")
        }
    }
  
    // MARK: - Teardown
    override func tearDownWithError() throws {
        manager = nil
        beerModel = nil
    }
}
