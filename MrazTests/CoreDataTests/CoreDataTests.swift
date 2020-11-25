//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
import CoreData
@testable import Mraz

class CoreDataTests: XCTestCase {
    // MARK: - Properties
    var coreDataStore: CoreDataStore!
    var manager: CoreDataManager!
    
    // MARK: - Set Up
    override func setUpWithError() throws {
        super.setUp()
        
        coreDataStore = CoreDataStore(.inMemory)
        manager = CoreDataManager(coreDataStore: coreDataStore)
    }
    
    // MARK: - Core Data Tests
    func testAddBeer() {
        let beer = createNewBeerObject(name: "Tan Lines", abvValue: "4.5%", description: "A beer", isOnTap: true, sectionType: "Ale", section: "Ale", changeTag: "1234", context: manager.context)
        
        XCTAssertNotNil(beer, "Beer should not be nil")
        
        XCTAssertTrue(beer.name == "Tan Lines", "Beer name is not correct")
        XCTAssertTrue(beer.abv == "4.5%", "Abv value is not correct")
        XCTAssertTrue(beer.beerDescription == "A beer", "Beer description is wrong")
        XCTAssertTrue(beer.isOnTap == true, "Beer is on tap is incorrect")
    }
    
    // Test that saving beer works
    func testContextIsSavedAfterAddingBeer() {
        let store = manager.coreDataStore
        let privateContext = store.newDerivedContext()
        
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: manager.context) { _ in
            return true
        }
        
        privateContext.perform {
            let beerObject = self.createNewBeerObject(name: "Gabriel", abvValue: "5.5%", description: "Description", isOnTap: true, sectionType: "Ale", section: "Ale", changeTag: "4567", context: privateContext)
            store.save(self.manager.context)
            XCTAssertNotNil(beerObject, "Beer object is nil")
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    /// Test Fetching beers from context
    func testGetBeers() {
        let store = manager.coreDataStore
        
        // Create Beer
        let beer = createNewBeerObject(name: "Window of Opportunity", abvValue: "5.0%", description: "Beer Desc", isOnTap: false, sectionType: "Sour", section: "Sour", changeTag: "abcdefg", context: manager.context)
        
        // Save to in memory context
        store.save(self.manager.context)
        
        // Fetch saved beer
        let testPredicate = NSPredicate(format: "name == %@", beer.name!)
        let resultingBeer = manager.findOrFetchObject(matching: testPredicate)
        
        XCTAssertNotNil(resultingBeer, "Beer was not saved correctly to context")
        XCTAssertEqual(resultingBeer?.name, beer.name)
        XCTAssertEqual(resultingBeer?.abv, beer.abv)
        XCTAssertEqual(resultingBeer?.beerDescription, beer.beerDescription)
        XCTAssertEqual(resultingBeer?.isOnTap, beer.isOnTap)
        XCTAssertEqual(resultingBeer?.section, beer.section)
    }
    
    func testUpdatingBeerObject() {
        let store = manager.coreDataStore
        
        // create beer to update
        let beer = createNewBeerObject(name: "Wrong", abvValue: "5.5%", description: "changing beer name", isOnTap: false, sectionType: "Ale", section: "Ale", changeTag: "cjkl", context: manager.context)
        
        // Save newly created beer to in memory context
        store.save(manager.context)
        
        // Get Beer to update
        let testPredicate = NSPredicate(format: "name == %@", "Wrong")
        let resultingBeer = manager.findOrFetchObject(matching: testPredicate)
        XCTAssertNotNil(resultingBeer, "Couldn't fetch beer object")
        
        // Update
        resultingBeer?.name = "Stone IPA"
        manager.updateFavoriteStatusOf(beer: resultingBeer!)
        
        let updatePredicate = NSPredicate(format: "name == %@", "Stone IPA")
        let updatedBeer = manager.findOrFetchObject(matching: updatePredicate)
        XCTAssertTrue(updatedBeer?.name == "Stone IPA", "Beer is not correct")
    }
    
    // MARK: - Helper
    /// Helper method to create a new 'Beers' object given the parameters.
    func createNewBeerObject(name: String, abvValue: String, description: String, isOnTap: Bool, sectionType: String, section: String, changeTag: String, context: NSManagedObjectContext) -> Beers {
        let beer = Beers(context: context)
        beer.name = name
        beer.abv = abvValue
        beer.beerDescription = description
        beer.isOnTap = isOnTap
        beer.section = section
        beer.beerType = sectionType
        beer.ckCreatedDate = Date()
        beer.ckModifiedDate = Date()
        beer.changeTag = changeTag
        beer.isFavorite = false
        return beer
    }

    // MARK: - Teardown
    override func tearDownWithError() throws {
        manager = nil
        coreDataStore = nil
    }
}
