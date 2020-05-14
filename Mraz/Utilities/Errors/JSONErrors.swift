//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

enum JsonError: Error {
    case jsonConversionFailure
    case jsonParsingFailure
    case imageFailedToLoad
    
    var localizedDescription: String {
        switch self {
            
        case .jsonConversionFailure: return "Failed to property convert JSON data from the server"
        case .jsonParsingFailure: return "JSON Parsing Failed"
        case .imageFailedToLoad: return "Failed to load image from JSON"
        }
    }
}
