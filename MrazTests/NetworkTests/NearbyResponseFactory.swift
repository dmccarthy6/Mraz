//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
@testable import Mraz

class NearbyResponseFactory {
    static func createResponseWithLocations(_ results: [SearchResult], status: String) -> RootLocal {
        return RootLocal(htmlAttributions: nil, nextPageToken: "", results: results, status: status)
    }
}

/// Extension on Codable Model to convert Codable data back to JSON for testing.
extension RootLocal {
    var dataValue: Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try! encoder.encode(self)
    }
}
