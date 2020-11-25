//  Created by Dylan  on 11/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import XCTest
@testable import Mraz

class APILoaderTests: XCTestCase {
    var loader: APIRequestLoader<RestaurantsRequest>!
    var searchResults: [SearchResult] = [
        SearchResult( geometry: Geometry(location: Location(lat: 38.123, lng: -120.123)),
                     icon: "",
                     name: "My Restaurant",
                     photos: [],
                     placeId: "123", rating: 10.0, reference: "", types: [], vicinity: "")
    ]
    
    override func setUp() {
        let request = RestaurantsRequest()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        loader = APIRequestLoader(apiRequest: request, urlSession: urlSession)
    }
    
    func testLoaderSuccess() {
        let inputCoordinate = Coordinates.mraz.location
        let rootLocal = RootLocal(nextPageToken: "123", results: searchResults, status: "Open")
        let mockJsonData = rootLocal.dataValue
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.query?.contains("lat=38.710252"), true)
            return (HTTPURLResponse(), mockJsonData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        loader.loadAPIRequest(requestData: inputCoordinate) { (root, error) in
            let results = root?.results
            
            XCTAssertEqual(results![0].name, self.searchResults[0].name, "Fetched data does not match input data")
            
            XCTAssertNil(error, "Error calling loadAPIRequest test. Error not nil, \(error?.localizedDescription ?? "")")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
