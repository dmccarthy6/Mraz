//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation


enum ContainerID: String {
    case beers = "iCloud.com.dylanmccarthyios.Mraz"
}

enum CKRecordType {
    case beers
    
    var name: String {
        switch self {
        case .beers: return "Beers"
        }
    }
}

enum BeerRecordKey: String {
    case abv
    case description
    case type
    case name
    case isOnTap
    case isFavorite
    case sectionType
}

//MARK: - CloudKit Status Enums
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
