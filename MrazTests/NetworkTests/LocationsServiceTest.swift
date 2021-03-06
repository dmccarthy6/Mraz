//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
@testable import Mraz

class LocationsServiceTest: XCTestCase {
    // MARK: - Properties
    var mockNetwork: MockNetworking?
    var searchResults: [SearchResult]?
    var token: String?
    var status: String?
    
    // MARK: - Set Up
    override func setUpWithError() throws {
        setUpData()
    }
    
    func setUpData() {
        mockNetwork = MockNetworking()
        let searchResult = Location(lat: 38.7098907, lng: -121.0859951)
        let geometry = Geometry(location: searchResult)
        searchResults = [
            SearchResult(businessStatus: "OPERATIONAL",
                         geometry: geometry,
                         icon: "https://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
                         id: "17241e7d34195fa6021cdbc6fb8d418442c05ef3",
                         name: "La Cascada Restaurante & Cantina", photos: [],
                         placeId: "ChIJpxIbu1bjmoARcMhUi6othBo",
                         rating: 4.3,
                         reference: "ChIJpxIbu1bjmoARcMhUi6othBo",
                         types: [ "restaurant", "bar", "food", "point_of_interest", "establishment" ],
                         vicinity: "2222 Francisco Drive, El Dorado Hills")
        ]
        token = "CqQCHwEAAP9aphLPzBZSiVHIuVUpwBmR8rfofIV94S0_Ojnc_iaX4C91TD9e5Fcp2lqUhkJ95G2KqgZL2ry1VvHlUxpLRd8xMl7KaO-_NrQ9RyqhaBFjsDQR5E4X1fylPSgxdQfVkCAHBp4RcPTXPmL_U9o_bgmY99z7nF1I2SjERUaoBDy5r22qw7mCZ6UEd_Zr1eaUaH2cJ_B6Tq4AtVhGBgrYJeTSHw1JXsFm5ai_KTP6TVLbEz4_AT8QTvHrO77UGNzLNVPtZ3rc4INp4agGp1eGsy14k-GraIkfgf8xTzXMl5E8cA1ioflCLOa9usC2s5LnEAZhju00n9-Wbg0XsGWZyXCP9xQ65YdsU0zaqZXCbokyPJeM9qzUlXmwJmZfkAk34BIQrRe6EMlQyXbMHlQIaRc9ahoUHTPrjbmFjaiOzAeK-92oqePUMVI"
        status = "OK"
    }
    
    // MARK: - Network Tests
    func testReceiveLocalRestaurantsResponse() {
        let expect = expectation(description: "Expected test to complete")
        let response = NearbyResponseFactory.createResponseWithLocations(searchResults!, status: status!)
        mockNetwork?.responseData = response.dataValue
        let service = LocationService(network: mockNetwork!)
        
        service.fetchLocations(urlRequest: .restaurant) { (result) in
            guard case .success(let response) = result else {
                XCTFail("Expected Locations to be fetched")
                return
            }
            XCTAssertNotNil(response.results.count)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testURLResponseValid() {
        let response = NearbyResponseFactory.createResponseWithLocations(searchResults!, status: status!)
        mockNetwork?.responseData = response.dataValue
        
    }
    
    // MARK: - Teardown
    override func tearDownWithError() throws {
        mockNetwork = nil
        searchResults = nil
        status = nil
        token = nil
    }
}
