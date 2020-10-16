//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

struct BeerModel {
    let id: String
    let section: String
    let changeTag: String
    let name: String
    let beerDescription: String
    let abv: String
    let type: String
    let createdDate: Date
    let modifiedDate: Date
    let isOnTap: Bool
    let isFavorite: Bool
}

extension BeerModel {
    
    static func createBeerModel(from beer: Beers) -> BeerModel {
        return BeerModel(id: beer.id ?? "nil", section: beer.section ?? "", changeTag: beer.changeTag ?? "", name: beer.name ?? "", beerDescription: beer.description, abv: beer.abv ?? "", type: beer.beerType ?? "", createdDate: beer.ckCreatedDate ?? Date(), modifiedDate: beer.ckModifiedDate ?? Date(), isOnTap: beer.isOnTap, isFavorite: beer.isFavorite)
        
    }
    
    static func createBeerModel(from record: CKRecord, isFavorite: Bool?) -> BeerModel {
        let isOnTap = record[.isOnTap] as? Int64 ?? 0
        
        return BeerModel(id: record.recordID.recordName,
                                section: record[.sectionType] as? String ?? "",
                                changeTag: record.recordChangeTag ?? "",
                                name: record[.name] as? String ?? "",
                                beerDescription: record[.description] as? String ?? "",
                                abv: record[.abv] as? String ?? "",
                                type: record[.type] as? String ?? "",
                                createdDate: record.creationDate ?? Date(),
                                modifiedDate: record.modificationDate ?? Date(),
                                isOnTap: isOnTap.boolValue,
                                isFavorite: isFavorite ?? false)
    }
}
