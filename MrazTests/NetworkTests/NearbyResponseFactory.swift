//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.
@testable import Mraz
import Foundation

class NearbyResponseFactory {
    static func createResponseWithLocations(_ results: [SearchResult], token: String, status: String) -> RootLocal {
        return RootLocal(results: results, status: status)
        //return RootLocal(htmlAttributions: [], nextPageToken: token, results: results, status: status)
    }
}

extension RootLocal {
    var dataValue: Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try! encoder.encode(self)
    }
}
