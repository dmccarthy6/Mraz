//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

enum APIError: Error {
    case httpRequestFailed
    case httpResponseUnsuccessful
    
    var localizedDescription: String {
        switch self {
            
        case .httpRequestFailed:                    return "No response from the server. Check your internet connection"
        case .httpResponseUnsuccessful:              return "Unsuccessful response from server"
        }
    }
}

enum NetworkingError: String, Error {
    case requestFailed = "Http request failed"
    case responseUnsuccessful = "Http respnse unsuccessful"
}

extension NetworkingError: LocalizedError {
    var errorDescription: String? { return NSLocalizedString(rawValue, comment: "") }
}
