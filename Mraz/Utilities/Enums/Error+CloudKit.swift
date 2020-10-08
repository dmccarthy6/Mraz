//  Created by Dylan  on 10/3/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import CloudKit
import os.log

public extension Error {
    // MARK: - CloudKit Errors
    /// Retries a CloudKit operation if the error suggests
    /// - Parameter log: The logger to use for logging information about error handling, uses the default
    /// - Parameter block: The block that will execute the operation later if it can be retried
    /// - Returns: Boolean indicating if the operation can be retried or not
    @discardableResult
    func retryCloudKitOperationIfSuggested(_ log: OSLog? = nil, with block: @escaping () -> Void) -> Bool {
        let effectiveLog: OSLog = log ?? .default
        guard let effectiveError = self as? CKError else { return false }
        
        guard let retryDelay: Double = effectiveError.retryAfterSeconds else {
            os_log("Error is not recoverable", log: effectiveLog, type: .error)
            return false
        }
        
        os_log("Error is recoverable. Will try after %{public}f seconds", log: effectiveLog, type: .error, retryDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            block()
        }
        return true
    }
    
}
