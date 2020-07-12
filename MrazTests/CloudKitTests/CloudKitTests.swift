//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
@testable import Mraz

class CloudKitTests: XCTestCase {
    let cloudKitManager = CloudKitManager.shared
    
    // MARK: -
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    // MARK: - CloudKit Tests:
    
//    func testFetchPerformedCorrectly() {
//        cloudKitManager.fetchBeerListFromCloud { (result) in
//            switch result {
//            case .success(let beers):
//                XCTAssert(beers.count > 0, "Error converting CloudKit to Core Data")
//                
//            case .failure(let error):
//                XCTAssertNil(error, "Error is not Nil fetching beer list from cloud")
//            }
//        }
//    }

    // MARK: - Performance
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
