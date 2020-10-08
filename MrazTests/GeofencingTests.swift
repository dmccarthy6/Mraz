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
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        let usersStatus = localNotificationManager.getCurrentNotificationStatus()
        XCTAssertTrue(usersStatus, "GeofencingTests -- User has not authorized Notifications")
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
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
