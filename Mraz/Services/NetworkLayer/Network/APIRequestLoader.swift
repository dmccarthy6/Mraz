//  Created by Dylan  on 11/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

class APIRequestLoader<T: APIRequest> {
    let apiRequest: T
    let urlSession: URLSession
    
    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }
    
    func loadAPIRequest(requestData: T.RequestDataType, completionHandler: @escaping (T.ResponseDataType?, Error?) -> Void) {
        do {
            let urlRequest = try apiRequest.makeRequest(from: requestData)
            
            urlSession.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data else { return completionHandler(nil, error) }
                
                do {
                    let parsedResponse = try self.apiRequest.parseResponse(data: data)
                    completionHandler(parsedResponse, nil)
                } catch {
                    completionHandler(nil, error)
                }
            }.resume()
        } catch {
            return completionHandler(nil, error)
        }
    }
}
