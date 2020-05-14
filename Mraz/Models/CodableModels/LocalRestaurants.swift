//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

struct RootLocal: Codable {
//    let htmlAttributions: [String]?
//    let nextPageToken: String
    let results: [SearchResult]
    let status: String
}

struct SearchResult: Codable {
    let businessStatus: String
    let geometry: Geometry
    let icon: String
    let id: String
    let name: String
//    let openingHours: [String: Bool]
//    let photos: [Photo]
    let placeId: String
//    let plusCode: [String: String]
//    let priceLevel: Double
//    let rating: Double
    let reference: String
    let scope: String
    let types: [String]
    let userRatingsTotal: Double
    let vicinity: String
}

struct Geometry: Codable {
    let location: Location
    let viewport: Viewport
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Viewport: Codable {
    let northeast: Location
    let southwest: Location
}

struct Photo: Codable {
    let height: Double
    let htmlAttributions: [String]
    let photoReference: String
    let width: Double
}

/*
 API Response from Local Search
 {
    "html_attributions" : [],
    "results" : [
       {
          "business_status" : "OPERATIONAL",
          "geometry" : {
             "location" : {
                "lat" : 38.7098907,
                "lng" : -121.0859951
             },
             "viewport" : {
                "northeast" : {
                   "lat" : 38.71124573029149,
                   "lng" : -121.0845670697085
                },
                "southwest" : {
                   "lat" : 38.7085477697085,
                   "lng" : -121.0872650302915
                }
             }
          },
          "icon" : "https://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
          "id" : "17241e7d34195fa6021cdbc6fb8d418442c05ef3",
          "name" : "La Cascada Restaurante & Cantina",
          "opening_hours" : {
             "open_now" : true
          },
          "photos" : [
             {
                "height" : 3024,
                "html_attributions" : [
                   "\u003ca href=\"https://maps.google.com/maps/contrib/103332373655537370829\"\u003eGina Bussie\u003c/a\u003e"
                ],
                "photo_reference" : "CmRaAAAASgAoTd_UZ1eATXf7WuOR9zIvD23kI9Rzk6LNerTRL3pMIs81E1PpVAoruDX-tclalyF1NXHe1ak0EgJnweWu85f0oQ9DBBZDBtO81guKTx9fqD7IX99wwK-0CB5vnK3dEhBudnz-GxBfONDh9NZmWWNSGhTKqR8CLD-Kvxb53FixZ0bN13PO3g",
                "width" : 4032
             }
          ],
          "place_id" : "ChIJpxIbu1bjmoARcMhUi6othBo",
          "plus_code" : {
             "compound_code" : "PW57+XJ El Dorado Hills, CA, United States",
             "global_code" : "84CWPW57+XJ"
          },
          "price_level" : 2,
          "rating" : 4.3,
          "reference" : "ChIJpxIbu1bjmoARcMhUi6othBo",
          "scope" : "GOOGLE",
          "types" : [ "restaurant", "bar", "food", "point_of_interest", "establishment" ],
          "user_ratings_total" : 153,
          "vicinity" : "2222 Francisco Drive, El Dorado Hills"
       }
    ],
    "status" : "OK"
 }
 */
