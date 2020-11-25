//  Created by Dylan  on 10/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit
import os.log

final class FetchCKRecodsOperation: Operation {
    // MARK: - Properties
    let ckRecordOPLog = OSLog(subsystem: MrazSyncConstants.subsystemName, category: String(describing: FetchCKRecodsOperation.self))
    
    private let cloudKitManager: CloudKitManager
    
    private let predicate: NSPredicate
    
    var fetchedRecords: [BeerModel]
    
    var recordIDSet = Set<String>()
    
    var managedObjectIDs: Set<String>
    
    var syncType: SyncType
    
    private let lockQueue = DispatchQueue(label: "Lock Queue", attributes: .concurrent)
    private var syncIsExecuting: Bool = false
    private var syncIsFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return syncIsFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync {
                syncIsFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return syncIsExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync {
                syncIsExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    // MARK: - Lifecycle
    init(cloudKitManager: CloudKitManager, predicate: NSPredicate, syncType: SyncType, managedObjectIDs: Set<String>) {
        self.cloudKitManager = cloudKitManager
        self.predicate = predicate
        self.syncType = syncType
        self.managedObjectIDs = managedObjectIDs
        
        self.fetchedRecords = []
        super.init()
    }
    
    override func main() {
        fetchCloudKitRecords {
            os_log("Executing CK Fetch", log: self.ckRecordOPLog, type: .debug)
            self.finish()
        }
    }
    
    override func start() {
        os_log("Starting CK Fetch", log: self.ckRecordOPLog, type: .debug)
        isExecuting = true
        isFinished = false
        main()
    }
    
    func finish() {
        os_log("Finishing CK Fetch", log: self.ckRecordOPLog, type: .debug)
        isExecuting = false
        isFinished = true
    }
    
    func fetchCloudKitRecords(_ completion: @escaping () -> Void) {
        cloudKitManager.fetchRecords(matching: predicate, qualityOfService: .userInitiated) { (records) in
            records.forEach { [weak self] record in
                guard let self = self else { return }
                
                let recordID = record.id
                self.recordIDSet.insert(recordID)
                
                if !self.recordIDSet.contains(recordID) {
                    self.fetchedRecords.append(record)
                }
            }
            completion()
        }
    }
}
