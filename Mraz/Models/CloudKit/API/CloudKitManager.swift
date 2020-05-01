//  Created by Dylan  on 4/28/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit


typealias CloudKitAPI = ReadFromCloudKit & WriteToCloudKit

struct CloudKitManager: CloudKitAPI, CoreDataAPI {
    
    //MARK: - Properties
    static let shared = CloudKitManager()
    
    
    //MARK: -
    func fetchBeerListFromCloud(_ completion: @escaping (Result<[Beers], Error>) -> Void) {
        /// Predicate & Sort Descriptor for CK objects
        let allRecordsPredicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        /// Create the query
        let query = CKQuery(recordType: CKRecordType.beers.name, predicate: allRecordsPredicate)
        query.sortDescriptors = [sortDescriptor]
        
        /// Create the Operation
        let operation = CKQueryOperation(query: query)
        
        /// The record fetched block that gets called for each record fetched.
        /// Saving these records to Core Data here.
        operation.recordFetchedBlock = { record in
            ///The 'isFavorite' and 'isOnTap' values are Int64 in CloudKit.
            /// 1 is true and 0 is false. Casting these values at Int64 to obtain the boolean value in order to save to CD
            let favorite = record[.isFavorite] as! Int64
            let onTap = record[.isOnTap] as! Int64
            
            let id = record.recordID
            let section = record[.sectionType] as! String
            let beerType = record[.type] as! String
            let chgTag = record.recordChangeTag ?? ""
            let beerName = record[.name] as! String
            let beerDescription = record[.description] as! String
            let beerABV = record[.abv] as! String
            let isFavorite = favorite.boolValue
            let isOnTap = onTap.boolValue
            let createdDate = record.creationDate ?? Date()
            let modifiedDate = record.modificationDate ?? Date()
            
            /// Save to Core Data
            self.saveBeerObject(id: id, section: section, tag: chgTag, name: beerName, description: beerDescription, abv: beerABV, type: beerType, createdDate: createdDate, modDate: modifiedDate, isFav: isFavorite, isTap: isOnTap)
        }

        ///Query Completion Block. Called when all records have been downloaded from CloudKit
        operation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                completion(.failure(error))
            }
            else {
                let defaults = Storage()
                //TO-DO: Set fetch successful User Defauts Key
                
                let ckBeers = self.fetchAllBeerObjects()
                print("CloudKitMGR - BeersCt: \(ckBeers.count)")
                completion(.success(ckBeers))
            }
        }
        database.add(operation)
    }
    
    
    
    
}
