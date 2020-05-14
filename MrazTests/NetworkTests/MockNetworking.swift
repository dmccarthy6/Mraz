//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
@testable import Mraz

class MockNetworking: Networking {
    // MARK: - Properties
    var responseData: Data?
    var error: Error?
    
    func fetch(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        completion(responseData, nil, error)
    }
}
