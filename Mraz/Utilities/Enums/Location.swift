//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CoreLocation

///
enum LocationTitle: String {
    case mraz = "Mraz Brewery"
    case mountainMikes = "Mountain Mike's Pizza"
    case cascada = "Cascada Mexican Restaurant"
    case asianBistro = "Asian Bistro"
    case purplePlace = "Purple Place"
    case saloon = "Saloon"
    case sourdough = "Sourdough & Co."
    case authenticTaco = "Authentic Street Taco"
}

/// Get the CLLocation value for each location
enum Coordinates {
    case mraz
    case mountainMikes
    case cascada
    case asianBistro
    case purplePlace
    case saloon
    case sourdough
    case authenticStreetTaco
    
    var location: CLLocationCoordinate2D {
        switch self {
        case .mraz: return CLLocationCoordinate2D(latitude: LocationCoordinates.mrazLat,
                                                  longitude: LocationCoordinates.mrazLong)
        case .mountainMikes: return CLLocationCoordinate2D(latitude: LocationCoordinates.mountainMikesLat,
                                                           longitude: LocationCoordinates.mountainMikesLong)
        case .cascada: return CLLocationCoordinate2D(latitude: LocationCoordinates.cascadaLat,
                                                     longitude: LocationCoordinates.cascadaLong)
        case .asianBistro: return CLLocationCoordinate2D(latitude: LocationCoordinates.asianBistroLat,
                                                         longitude: LocationCoordinates.asianBistroLong)
        case .purplePlace: return CLLocationCoordinate2D(latitude: LocationCoordinates.purplePlaceLat,
                                                         longitude: LocationCoordinates.purplePlaceLong)
        case .saloon: return CLLocationCoordinate2D(latitude: LocationCoordinates.saloonLat,
                                                    longitude: LocationCoordinates.saloonLong)
        case .sourdough: return CLLocationCoordinate2D(latitude: LocationCoordinates.sourdoughLat,
                                                       longitude: LocationCoordinates.sourdoughLong)
        case .authenticStreetTaco: return CLLocationCoordinate2D(latitude: LocationCoordinates.authenticStreetTacoLat,
                                                                 longitude: LocationCoordinates.authenticStreetTacoLong)
        }
    }
}

/// Obtain the Latitude & Longitude values for each location
enum LocationCoordinates {
    static let mrazLat = Double(38.710252)
    static let mrazLong = Double(-121.086191)
    static let mountainMikesLat = Double(38.710825)
    static let mountainMikesLong = Double(-121.086331)
    static let cascadaLat = Double(38.709916)
    static let cascadaLong = Double(-121.085992)
    static let asianBistroLat = Double(38.710717)
    static let asianBistroLong = Double(-121.086915)
    static let purplePlaceLat = Double(38.703291)
    static let purplePlaceLong = Double(-121.104221)
    static let saloonLat = Double(38.709319)
    static let saloonLong = Double(-121.085052)
    static let sourdoughLat = Double(38.709319)
    static let sourdoughLong = Double(-121.084742)
    static let authenticStreetTacoLat = Double(38.708672)
    static let authenticStreetTacoLong = Double(-121.084520)
}
