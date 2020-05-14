//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
@testable import Mraz

struct LocationService {
    let network: Networking
    
    func fetchLocations(urlRequest: NearbyRestaurantsGP, _ completion: @escaping (Result<RootLocal, Error>) -> Void) {
        guard let url = urlRequest.urlRequest.url else {
            fatalError("Couldnt get url in tests")
        }
        
        network.fetch(url) { (data, urlResponse, error) in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let data = data,
                let response = try? decoder.decode(RootLocal.self, from: data) else {
                    completion(.failure(error!))
                    return
            }
            completion(.success(response))
        }
    }
}
