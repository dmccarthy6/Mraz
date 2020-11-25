//  Created by Dylan  on 9/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
@testable import Mraz
import CoreLocation

class GeofencingTests: XCTestCase {
    var manager: LocationManager!
    var localNotificationManager: LocalNotificationManger!
    
    override func setUpWithError() throws {
        manager = LocationManager()
        localNotificationManager = LocalNotificationManger()
    }

    // MARK: - Location Manager Tests
    func testLocationManager() {
        XCTAssertNotNil(manager.locationManager, "Something's wrong - location manager is Nil")
    }

    func testLocationMgrSvcsEnabled() {
        XCTAssertTrue(CLLocationManager.locationServicesEnabled(), "GeofencingTests -- Location Services are not enabled")
    }
    
    // MARK: - Authorizaton Tests
    func testNoficationsAuth() {
        let authExpectation = expectation(description: "Notification Status")
        
        localNotificationManager.getLocalNotificationStatus { granted in
            XCTAssertTrue(granted)
            authExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Notification status could not be determined")
        }
    }
    
    func testWhenInUseAuthStatus() {
        let status = CLLocationManager.authorizationStatus()
        
        XCTAssertEqual(status, .authorizedAlways, "GeofencingTests -- Status is not Authorized Always; it is: \(status)")
    }
    
    // MARK: - Teardown
    override func tearDownWithError() throws {
        manager = nil
        localNotificationManager = nil
    }

}
