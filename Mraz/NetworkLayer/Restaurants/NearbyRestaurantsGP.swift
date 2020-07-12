//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

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
/* API Search Parameters:
// NEARBY SEARCH REQ
//https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
// PARAMETERS:
// key: API Key
// location: lat/long specified as latitude,longitude
// radius: distance in meters

 Examplea nearby search request for places of type 'restaurant' within 15000m radiys of a point in Sydney Australia containing word 'cruise'
 https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=1500&type=restaurant&keyword=cruise&key=YOUR_API_KEY
 */

/*
Data Used/Needed for search parameters:
 
 My Google Places API Key: AIzaSyCdusZ1mwdOgk3M7s1l2N_MH_PZYhDWQ70
 Mraz Lat: 38.710252
 Mraz Lng: -121.086191
 
 */
