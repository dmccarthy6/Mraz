//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

struct RootLocal: Codable {
    let htmlAttributions: [String]?
    let nextPageToken: String
    let results: [SearchResult]
    let status: String
}

struct SearchResult: Codable {
    let businessStatus: String
    let geometry: Geometry
    let icon: String
    let id: String?
    let name: String
    let photos: [Photos]
    let placeId: String
    let rating: Double
    let reference: String
    let types: [String]
    let vicinity: String
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Photos: Codable {
    let height: Double
    let htmlAttributions: [String]
    let photoReference: String
    let width: Double
}
