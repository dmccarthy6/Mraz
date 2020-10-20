//  Created by Dylan  on 10/20/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log
@testable import Mraz

final class CloudKitManagerMock {
    // MARK: - Properties
    let ckManagerMockLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: CloudKitManagerMock.self))
    
    var publicCloudKitDatabase: CKDatabase {
        let container = CKContainer(identifier: MrazSyncConstants.containerIdentifier)
        return container.database(with: .public)
    }
    
    var defaultContainer: CKContainer {
        return CKContainer.default()
    }
    
    var accountStatus: CKAccountStatus = .couldNotDetermine
    
    // MARK: - CloudKit Operations
    func fetchRecords(matching predicate: NSPredicate, qos: QualityOfService = .userInitiated, fetch: FetchType = .subsequent, _ completion: @escaping (Result<[CKRecord], CKError>) -> Void) {
        var fetchedRecords: [CKRecord] = []
        let sortDescriptors = Beers.defaultSortDescriptors
        let query = CKQuery(recordType: CKRecordType.beers, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        let fetchTestRecordsOperation = CKQueryOperation(query: query)
        
        fetchTestRecordsOperation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }
        
        fetchTestRecordsOperation.queryCompletionBlock = { (cursor, error) in
            if let error = error as? CKError {
                print("HERES THE ERROR CODE: \(error.code)")
                completion(.failure(error))
                os_log("Error fetching records from cloudkit - %@", log: self.ckManagerMockLog, type: .error, error.localizedDescription)
            }
            if fetch == .subsequent {
                completion(.success(fetchedRecords))
            }
        }
        fetchTestRecordsOperation.resultsLimit = 1
        fetchTestRecordsOperation.qualityOfService = qos
        publicCloudKitDatabase.add(fetchTestRecordsOperation)
    }
    
    // MARK: - CloudKit Status
    func requestCKAccountStatus(_ completion: @escaping () -> Void) {
        defaultContainer.accountStatus { (status, error) in
            if let error = error {
                os_log("Error getting account status: %@", log: self.ckManagerMockLog, type: .error, error.localizedDescription)
            }
            self.accountStatus = status
            completion()
        }
    }
}
