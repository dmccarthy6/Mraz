//  Created by Dylan  on 11/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Mraz

class LocationManagerTests: XCTestCase {
    
    struct MockLocationFetcher: LocationFetcher {
        weak var locationFetcherDelegate: LocationFetcherDelegate?
        var desiredAccuracy: CLLocationAccuracy = 0
        var handleRequestLocation: (() -> CLLocation)?
        weak var delegate: CLLocationManagerDelegate? 
        
        func requestLocation() {
            guard let location = handleRequestLocation?() else { return }
            locationFetcherDelegate?.locationFetcher(self, didUpdateLocations: [location])
        }
        
    }
    
    var locationFetcher = MockLocationFetcher()
    
    override func setUpWithError() throws {
        
    }
    
    func testCurrentLocation() throws {
        
        let requestLocationExpectation = expectation(description: "Request Location")
        locationFetcher.handleRequestLocation = {
            requestLocationExpectation.fulfill()
            return CLLocation(latitude: 38.723440, longitude: -121.084080)
        }
        let provider = CurrentLocationProvider(locationFetcher: locationFetcher)
        let completionExpectation = expectation(description: "completion")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}

/*
 func testCheckCurrentLocation() {
     var locationFetcher = MockLocationFetcher()
     let requestLocationExpectation = expectation(description: "request location")
     locationFetcher.handleRequestLocation = {
         requestLocationExpectation.fulfill()
         return CLLocation(latitude: 37.3293, longitude: -121.8893)
     }
     let provider = CurrentLocationProvider(locationFetcher: locationFetcher)
     let completionExpectation = expectation(description: "completion")
     provider.checkCurrentLocation { isPointOfInterest in
         XCTAssertTrue(isPointOfInterest)
         completionExpectation.fulfill()
     }
     //   Can mock the current location
     wait(for: [requestLocationExpectation, completionExpectation], timeout: 1)
 }
 */
