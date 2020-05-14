//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

protocol Networking {
    func execute<T: Decodable>(_ requestProvider: Endpoint, completion: @escaping (Result<T, APIError>) -> Void)
}

extension Networking {
    func execute<T: Decodable>(_ requestProvider: Endpoint, completion: @escaping (Result<T, APIError>) -> Void) {
        let urlRequest = requestProvider.urlRequest
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.httpRequestFailed))
                return
            }
            if httpResponse.statusCode == 200 {
                print("Networking -- 200 response from server.")
                // Successful response from the server
                guard let data = data else {
                    preconditionFailure("Networking Protocol -- No Error thrown, but there is no data...")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedModelObject = try decoder.decode(T.self, from: data)
                    
                    completion(.success(decodedModelObject))
                } catch {
                    completion(.failure(.httpResponseUnsuccessful))
                }
            } else {
                print("NETWORKING -- UNSUCCESSFUL NETWORK RESPONSE")
                // Did not get a 200 response from server, handle unsuccessful response
                completion(.failure(.httpResponseUnsuccessful))
            }
        }.resume()
    }
    
    /// Method used for testing
    func fetch(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void){}
}
