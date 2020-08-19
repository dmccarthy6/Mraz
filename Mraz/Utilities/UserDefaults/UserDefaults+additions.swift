//  Created by Dylan  on 7/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation

final class MrazSettings {
    // MARK: - Properties
    private let defaults: UserDefaults
    
    // MARK: - Life Cycle
    init() {
        self.defaults = UserDefaults.standard
    }
    
    ///Setting a value for a specified Key
    ///
    /// - Parameters
    ///     - value: The new value to be saved
    ///     - key: The key that is being updated
    func set(_ value: Any, for key: MrazSettingsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    ///Read the value for a specified key
    ///
    /// - Parameter key: The key that should be read
    /// - Returns: The value for the specified key
    func readValue(for key: MrazSettingsKey) -> Any? {
        return defaults.value(forKey: key.rawValue)
    }
    
    /// Reads the value for a specified key and returns the boolean value
    ///
    /// - Parameter key: The key that should be read
    /// - Returns: The value of the specified key as a boolean. Returns false if the value
    ///            can not be cast as a boolean.
    func readBool(for key: MrazSettingsKey) -> Bool {
        return readValue(for: key) as? Bool ?? false
    }
}

extension MrazSettings {
    ///All possible keys for user defaults
    enum MrazSettingsKey: String {
        case didFinishOnboarding
        case userIsOfAge
        case suppressCloudKitError
        case isUserLoggedIntoCK
        case initialFetchSuccessful
        case mrazCloudKitSubscriptionID
    }
}
