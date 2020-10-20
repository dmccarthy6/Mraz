//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
@testable import Mraz

class CloudKitTests: XCTestCase {
    var cloudKitManager: CloudKitManagerMock!
    
    // MARK: - Setup
    override func setUpWithError() throws {
        cloudKitManager = CloudKitManagerMock()
    }
    
    // MARK: - Test User Auth
    func testUserIsLoggedIn() {
        let authExpectation = expectation(description: "AuthStatus Expectation")
        var currentStatus = cloudKitManager.accountStatus
        
        cloudKitManager.requestCKAccountStatus {
            XCTAssertTrue(currentStatus == .couldNotDetermine, "CK Account Status changed from '.couldNotDetermine'")
            authExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3) { (error) in
            guard let error = error else { return }
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // MARK: - Test Fetching
    func testCloudKitFetch() {
        let fetchExpectation = expectation(description: "User Logged In Fetch")
        
        let predicate = NSPredicate(format: "name == %@", "Tan Lines")
        
        cloudKitManager.fetchRecords(matching: predicate) { (result) in
            switch result {
            case .success(let records):
                XCTAssertFalse(records.count == 0, "")
                fetchExpectation.fulfill()
                
            case .failure(let ckError):
                XCTAssertNotNil(ckError, "Error is nil")
                fetchExpectation.fulfill()
            }
        }
    
        waitForExpectations(timeout: 3) { (error) in
            guard let error = error else { return }
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // MARK: - Teardown Code
    override func tearDownWithError() throws {
        cloudKitManager = nil
    }
}
