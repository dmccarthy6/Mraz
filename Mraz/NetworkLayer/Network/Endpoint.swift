//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

/*
 My Google Places API Key: AIzaSyCdusZ1mwdOgk3M7s1l2N_MH_PZYhDWQ70
 */
protocol Endpoint: RequestProviding {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
}

