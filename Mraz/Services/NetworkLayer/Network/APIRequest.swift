//  Created by Dylan  on 11/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType
     
    func makeRequest(from data: RequestDataType) throws -> URLRequest
    func parseResponse(data: Data) throws -> ResponseDataType
}
