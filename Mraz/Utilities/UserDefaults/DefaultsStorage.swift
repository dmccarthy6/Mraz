//  Created by Dylan  on 5/1/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

/// The keys for User Defaults
extension Key {
    ///CloudKit
    static let serverChangeToken: Key = "cloudKitServerChangeToken"
    static let isUserLoggedIntoCK: Key = "loggedIntoCloud"
    static let suppressCloudError: Key = "suppress"
    static let cloudSubscription: Key = "beersSubscription"
    ///
    static let userIsOfAge: Key = "userAgeVerified"
    static let initialFetchSuccessful: Key = "initialFetchSuccessful"
}

struct Storage {
    // Age Verification
    @UserDefault(key: .userIsOfAge)
    var userIsOfAge: Bool?
    
    // MARK: - CloudKit
    @UserDefault(key: .suppressCloudError)
    var suppressError: Bool?
    
    @UserDefault(key: .isUserLoggedIntoCK)
    var isUserLoggedIntoCK: Bool?
    
    ///Initial CK Fetch Successful
    @UserDefault(key: .initialFetchSuccessful)
    var initialFetchSuccessful: Bool?
    
    @UserDefault(key: .cloudSubscription)
    var cloudSubscription: Bool?
}

/*
 Usage ---
 var storage = Storage()
 storage.hasFetchBeenPErformed = true
 */
