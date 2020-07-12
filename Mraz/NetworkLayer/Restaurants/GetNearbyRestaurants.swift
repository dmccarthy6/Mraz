//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

typealias Network = SearchNearbyRestaurants & Networking

protocol SearchNearbyRestaurants {
    var network: Networking { get }
    func fetchNearbyRestaurants(_ completion: @escaping (Result<RootLocal, APIError>) -> Void)
}

extension SearchNearbyRestaurants {
    func fetchNearbyRestaurants(_ completion: @escaping (Result<RootLocal, APIError>) -> Void) {
        network.execute(NearbyRestaurantsGP.restaurant, completion: completion)
    }
}
