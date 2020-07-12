//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

enum ContainerID: String {
    case beers = "iCloud.com.dylanmccarthyios.Mraz"
}

enum CKRecordType {
    static let beers = "Beers"
    static let onTap = "OnTap"
}

enum CloudKitKey: String {
    //Beers
    case abv
    case description
    case type
    case name
    case isOnTap
    case isFavorite
    case sectionType
    
    //OnTap
    case beerABV
    case beerDescription
    case beerName
}

// MARK: - CloudKit Status Enums
enum CloudKitStatus: String {
    case available
    case noAccount
    case couldNotDetermine
    case restricted
}

enum CloudKitStatusError: Error {
    case failedConnection
    
    var localizedDescription: String {
        switch self {
        case .failedConnection: return "Error reaching iCloud Service. Check your internet connection and try again."
        }
    }
}
