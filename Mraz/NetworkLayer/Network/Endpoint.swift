//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

protocol Endpoint: RequestProviding {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
}

