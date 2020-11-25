//  Created by Dylan  on 4/27/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit

protocol ReadFromCloudKit: CloudKitAuthorizations {
    var publicCloudKitDatabase: CKDatabase { get }
    var ckContainer: CKContainer { get }
    
    func fetchRecords(matching predicate: NSPredicate, qualityOfService: QualityOfService, completion: @escaping ([BeerModel]) -> Void)
}

extension ReadFromCloudKit {
    var subscriptionDispatchGroup: DispatchGroup {
        return DispatchGroup()
    }
    
    // MARK: - Account Status
    /// Check the users iCloud Account Status returning a result type with the status or an error if one occurs. Utilize this method to
    /// Handle any iCloud status changes the user may perform.
    /// - Returns: Result type with a CloudKit Status enum value and a CloudKitError enum value.
    func getUsersCurrentAuthStatus(completion: @escaping (Result<CloudKitStatus, CloudKitStatusError>) -> Void) {
        ckContainer.accountStatus { (status, error) in
            if error != nil {
                completion(.failure(.failedConnection))
                return
            }
            
            switch status {
            case .available://Logged in -- good to go
                completion(.success(.available))
            case .noAccount: //User Not Logged In
                completion(.success(.noAccount))
            case .couldNotDetermine://For some reason status couldn't be determined, try again
                completion(.success(.couldNotDetermine))
            case .restricted://iCloud settings restricted by parental controls or configuration profile
                completion(.success(.restricted))
            default: ()
            }
        }
    }

    // MARK: - CloudKit Query
    /// Creates a CloudKit Query
    /// - Parameter predicate: Predicate to 
    /// - Parameter sortDescriptors:
    /// - Returns: A CKQuery object
    func mrazCloudKitQuery(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> CKQuery {
        let query = CKQuery(recordType: CKRecordType.beers, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        return query
    }
}
