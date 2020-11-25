//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
import CloudKit
@testable import Mraz

class CloudKitTests: XCTestCase {
    var cloudKitManager: CloudKitManager!
    
    // MARK: - Setup
    override func setUpWithError() throws {
        cloudKitManager = CloudKitManager(container: CKContainer(identifier: MrazSyncConstants.containerIdentifier))
    }
    
    // MARK: - Test User Auth
    func testUserIsLoggedIn() {
        let authExpectation = expectation(description: "AuthStatus Expectation")
        let container = cloudKitManager.ckContainer
        var currentStauts: CKAccountStatus = .couldNotDetermine
        
        container.accountStatus { (ckStatus, error) in
            XCTAssertNil(error, "")
            
            XCTAssertNotEqual(currentStauts, ckStatus)
            
            currentStauts = ckStatus
            
            XCTAssertEqual(ckStatus, currentStauts)
            
            authExpectation.fulfill()
        }
 
        waitForExpectations(timeout: 2.0) { (error) in
            guard let error = error else { return }
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // MARK: - Test Fetching
    func testCloudKitFetch() {
        let fetchExpectation = expectation(description: "User Logged In Fetch")
        
        let predicate = NSPredicate(format: "name == %@", "Tan Lines")
        
        cloudKitManager.fetchRecords(predicate, qos: .background, fetch: .subsequent) { records in
            XCTAssertNotNil(records, "Fetch Records Nil")
            
            records.forEach { (record) in
                let name = record[.name] as! String
                let sec = record[.sectionType] as! String
                
                XCTAssertEqual(name, "Tan Lines")
                XCTAssertEqual(sec, "Ale")
                fetchExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2.0) { (error) in
            guard let error = error else { return }
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // MARK: - Teardown Code
    override func tearDownWithError() throws {
        cloudKitManager = nil
    }
}
