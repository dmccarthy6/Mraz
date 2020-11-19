//  Created by Dylan  on 11/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreLocation
import os.log

/*  API
    * Endpoint: https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    * Example: https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=1500&type=restaurant&keyword=cruise&key=YOUR_API_KEY
    *Search Requirements:
        * Key: API Key
        * Location: Lat/Long
        * Radius: Distance (meters)
    * Data for Mraz Search:
        *Key: **AIzaSyCdusZ1mwdOgk3M7s1l2N_MH_PZYhDWQ70**
        *Lat: 38.710252 / Long: -121.086191
 */

struct RestaurantsRequest: Endpoint, APIRequest {
    typealias RequestDataType = CLLocationCoordinate2D
    typealias ResponseDataType = RootLocal
    
    // MARK: - Properties
    // Endpoint Conformance
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "maps.googleapis.com"
    }
    
    var path: String {
        return "/maps/api/place/nearbysearch/json"
    }
    
    func makeRequest(from coordinate: CLLocationCoordinate2D) -> URLRequest {
        var components = URLComponents()
        components.path = path
        components.host = host
        components.scheme = scheme
        components.queryItems = [
            URLQueryItem(name: "location", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "8047"),
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "key", value: "AIzaSyCdusZ1mwdOgk3M7s1l2N_MH_PZYhDWQ70")
        ]
        
        guard let url = components.url else {
            fatalError("")
        }
        return URLRequest(url: url)
    }
    
    func parseResponse(data: Data) throws -> RootLocal {
        return try JSONDecoder().decode(RootLocal.self, from: data)
    }
}
