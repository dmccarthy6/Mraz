//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

protocol Networking {
    func execute<T: Decodable>(_ requestProvider: Endpoint, completion: @escaping (Result<T, APIError>) -> Void)
}

extension Networking {
    /// Method that executes a urlSession method on the network. This method
    ///  - Parameter requestProvider: Endpoint enum value used to create the urlRequest.
    ///  - Parameter completion: Completion handler that returns a resut type of a Decodable object and an API Error upon failure.
    func execute<T: Decodable>(_ requestProvider: Endpoint, completion: @escaping (Result<T, APIError>) -> Void) {
        let urlRequest = requestProvider.urlRequest
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let _ = error {
                completion(.failure(.httpRequestFailed))
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.httpRequestFailed))
                return
            }
            if httpResponse.statusCode == 200 {
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
                // Response other than 200
                completion(.failure(.httpResponseUnsuccessful))
            }
        }.resume()
    }
    
    /// Method used to mock the networking protocol and test the url session performance. Only use this method for testing.
    /// - Parameter url: URL value used to test the Networking protocol.
    /// - Parameter completion: Completion handler returning Data, URLResponse, and Error.
    func fetch(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) { }
}
