//  Created by Dylan  on 5/4/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit

final class CloudKitSync: CloudKitAPI, CoreDataAPI {
    // MARK: - Properties
    private let userDef = UserDefaults.standard
    var changedRecords: [CKRecord]
    var deletedRecordIDs: [CKRecord.ID]
    var recordZoneChangesOP: CKFetchRecordZoneChangesOperation
    weak var recordsChangedDelegate: CloudKitRecordsChangedDelegate?
    
    // MARK: - Initializer
    init() {
        self.changedRecords = []
        self.deletedRecordIDs = []
        self.recordZoneChangesOP = CKFetchRecordZoneChangesOperation()
        setRecordChangeBlocks()
    }
    
    // MARK: - Set Operation Blocks
    func setRecordChangeBlocks() {
//        let zone = CKRecordZone.default()
//        let zoneID = zone.zoneID
//        recordZoneChangesOP = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneID, configurationsByRecordZoneID: <#T##[CKRecordZone.ID : CKFetchRecordZoneChangesOperation.ZoneConfiguration]?#>)
        recordZoneChangesOP.recordChangedBlock = { [unowned self] (record: CKRecord) in
            print("CKSync - This record was changed: \(record[.name] as? String ?? "NIL CHD RECORD")")
            self.changedRecords.append(record)
        }
        
        recordZoneChangesOP.recordWithIDWasDeletedBlock = { [unowned self] (recordID: CKRecord.ID, recordType: CKRecord.RecordType) in
            self.deletedRecordIDs.append(recordID)
            print("This record was deleted: \(recordID)")
        }
        
        recordZoneChangesOP.fetchRecordZoneChangesCompletionBlock = { [unowned self] (error) in
            if let error = error {
                print("cKSync -- Error -> FetchedrecordzonechangesCompletionBlock : \(error.localizedDescription)")
                //Do Something with the error
            } else {
                self.handleChanges(in: self.changedRecords)
                // To-DO: Pass these records to CD
            }
        }
        
        recordZoneChangesOP.recordZoneFetchCompletionBlock = { [unowned self] (recordZone, changeToken, data, moreComing, error) in
            if let error = error {
                print("CKSync -- Error in Fetch Completion Block: \(error.localizedDescription)")
            }
            self.updateChangeToken(changeToken)
        }
        publicDatabase.add(recordZoneChangesOP)
    }
    
    
    // MARK: - Change Token Methods
    
    /// Set the initial CKChangeToken before anything is received from
    /// the server.
    func setInitialServerChangeToken() {
        userDef.setValue(self.cloudKitChangeToken, forKey: Key.serverChangeToken.rawValue)
    }
    
    /// Obtains the current CloudKitChangeToken from UserDefaults.
    func getCurrentServerChangeToken() -> CKServerChangeToken? {
        guard let currentToken = userDef.value(forKey: Key.serverChangeToken.rawValue) as? CKServerChangeToken else {
            return nil
        }
        return currentToken
    }
    
    /// Update the Change Token in User Defaults.
    func updateChangeToken(_ serverChangeToken: CKServerChangeToken?) {
        if let serverChangeToken = serverChangeToken {
            userDef.setValue(serverChangeToken, forKey: Key.serverChangeToken.rawValue)
        } else {
            userDef.setValue(nil, forKey: Key.serverChangeToken.rawValue)
        }
    }
    
    // MARK: - Helpers
    /// Delegate method called when records are changed.
    private func handleChanges(in records: [CKRecord]) {
        recordsChangedDelegate?.processChanged(records)
    }
}

/*
 enum CloudKitZone: String {
     case CarZone = "CarZone"
     case TruckZone = "TruckZone"
     case BusZone = "BusZone"
     
     init?(recordType: String) {
         switch recordType {
         case ModelObjectType.Car.rawValue : self = .CarZone
         case ModelObjectType.Truck.rawValue : self = .TruckZone
         case ModelObjectType.Bus.rawValue : self = .BusZone
         default : return nil
         }
     }
     
     func serverTokenDefaultsKey() -> String {
         return rawValue + "ServerChangeTokenKey"
     }
     
     func recordZoneID() -> CKRecordZoneID {
         return CKRecordZoneID(zoneName: rawValue, ownerName: CKOwnerDefaultName)
     }
     
     func recordType() -> String {
         switch self {
         case .CarZone : return ModelObjectType.Car.rawValue
         case .TruckZone : return ModelObjectType.Truck.rawValue
         case .BusZone : return ModelObjectType.Bus.rawValue
         }
     }
     
     func cloudKitSubscription() -> CKSubscription {
         
         // options must be set to 0 per current documentation
         // https://developer.apple.com/library/ios/documentation/CloudKit/Reference/CKSubscription_class/index.html#//apple_ref/occ/instm/CKSubscription/initWithZoneID:options:
         let subscription = CKSubscription(zoneID: recordZoneID(), options: CKSubscriptionOptions(rawValue: 0))
         subscription.notificationInfo = notificationInfo()
         return subscription
     }
     
     func notificationInfo() -> CKNotificationInfo {
         
         let notificationInfo = CKNotificationInfo()
         notificationInfo.alertBody = "Subscription notification for \(rawValue)"
         notificationInfo.shouldSendContentAvailable = true
         notificationInfo.shouldBadge = false
         return notificationInfo
     }
     
     static let allCloudKitZoneNames = [
         CloudKitZone.CarZone.rawValue,
         CloudKitZone.TruckZone.rawValue,
         CloudKitZone.BusZone.rawValue
     ]
 }

 enum CloudKitUserDefaultKeys: String {
     
     case CloudKitEnabledKey = "CloudKitEnabledKey"
     case SuppressCloudKitErrorKey = "SuppressCloudKitErrorKey"
     case LastCloudKitSyncTimestamp = "LastCloudKitSyncTimestamp"
 }

 enum CloudKitPromptButtonType: String {
     
     case OK = "OK"
     case DontShowAgain = "Don't Show Again"
     
     func performAction() {
         switch self {
         case .OK:
             break
         case .DontShowAgain:
             NSUserDefaults.standardUserDefaults().setBool(true, forKey: CloudKitUserDefaultKeys.SuppressCloudKitErrorKey.rawValue)
         }
     }
     
     func actionStyle() -> UIAlertActionStyle {
         switch self {
         case .DontShowAgain: return .Destructive
         default: return .Default
         }
     }
 }
 */
