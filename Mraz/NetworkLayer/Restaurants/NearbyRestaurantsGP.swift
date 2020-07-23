//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

/*  API
    * Endpoint: https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    * Example: https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=1500&type=restaurant&keyword=cruise&key=YOUR_API_KEY
    *Search Requirements:
        * Key: API Key
        * Location: Lat/Long
        * Radius: Distance (meters)
    * Data for Mraz Search:
        *Key: AIzaSyCdusZ1mwdOgk3M7s1l2N_MH_PZYhDWQ70
        *Lat: 38.710252 / Long: -121.086191
 */
enum NearbyRestaurantsGP: Endpoint {
    case restaurant
}

extension NearbyRestaurantsGP {
    var scheme: String {
        return "https"
    }
    var host: String {
        return "maps.googleapis.com"
    }
    var path: String {
        return "/maps/api/place/nearbysearch/json"
    }
    
    var nearbyRestaurantQueryItems: [URLQueryItem] {
        switch self {
        case .restaurant:
            return [
            URLQueryItem(name: "location", value: "38.710252,-121.086191"),
            URLQueryItem(name: "radius", value: "8047"),
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "key", value: "AIzaSyCdusZ1mwdOgk3M7s1l2N_MH_PZYhDWQ70")
            ]
        }
    }
    
    var components: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = nearbyRestaurantQueryItems
        return components
    }
    
    var urlRequest: URLRequest {
        guard let url = components.url else {
            fatalError("Endpoint -- Error getting url ")
        }
        return URLRequest(url: url)
    }
}
