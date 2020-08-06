//  Created by Dylan  on 8/6/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

enum AppHook {
    case facebook
    case instagram
    case twitter
    
    var appHook: String {
        switch self {
        case .facebook:     return "fb://profile/MrazBrewingCompany"
        case .instagram:    return "instagram://user?username=mrazbrewingco"
        case .twitter:      return "twitter://user?screen_name=mrazbrewing"
        }
    }
    
    var webURL: String {
        switch self {
        case .facebook:     return "https://facebook.com/MrazBrewingCompany"
        case .instagram:    return "https://instagram.com/mrazbrewingco"
        case .twitter:      return "https://twitter.com/mrazbrewing"
        }
    }
}
