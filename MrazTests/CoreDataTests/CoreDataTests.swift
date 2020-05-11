//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
import CoreData
@testable import Mraz

class CoreDataTests: XCTestCase, CoreDataAPI {
    // MARK: - Properties
    let context = CoreDataUnitTestHelpers.setUpInMemoryManagedObjectContext()
    
    override func setUpWithError() throws {
        super.setUp()
        
    }

    // MARK: - Core Data Tests
    func testCreateObject() {
//        let beerModel = BeerModel(id: <#T##CKRecord.ID#>, section: "Ale", changeTag: "123", name: "TestBeer", beerDescription: "Test beer desc", abv: "4.5", type: "Ale", createdDate: Date(), modifiedDate: Date(), isOnTap: true, isFavorite: true)
        do {
            try CoreDataUnitTestHelpers.deleteAllObjects(objectType: Beers.self, with: context)
//            try createManagedObjectFrom(beerModel, in: context)
            
        } catch {
            XCTFail("CoreDataTests -- Failure - Could not create objects")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // MARK: - Teardown Code
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
