//  Created by Dylan  on 5/13/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

struct RootLocal: Codable {
    let nextPageToken: String?
    let results: [SearchResult]
    let status: String?
}

struct SearchResult: Codable {
    let geometry: Geometry
    let icon: String?
    let name: String?
    let photos: [Photos]?
    let placeId: String?
    let rating: Double?
    let reference: String?
    let types: [String]?
    let vicinity: String?
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Photos: Codable {
    let height: Int?
    let photoReference: String?
    let width: Int?
}
