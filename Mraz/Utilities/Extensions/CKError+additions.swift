//  Created by Dylan  on 5/5/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import CloudKit

extension CKError {
    public func isRecordNotFound() -> Bool {
        return isZoneNotFound() || isUnknownItem()
    }
    
    public func isZoneNotFound() -> Bool {
        return isSpecificError(code: .zoneNotFound)
    }
    
    public func isUnknownItem() -> Bool {
        return isSpecificError(code: .unknownItem)
    }
    
    public func isSpecificError(code: CKError.Code) -> Bool {
        var match = false
        if self.code == code {
            match = true
        } else if self.code == .partialFailure {
                // Multiple issue error. Check the underlying
                // Array of errors to see if it contains a match for the error.
            guard let errors = partialErrorsByItemID else { return false }
            for (_, error) in errors {
                if let cloudKitError = error as? CKError {
                    if cloudKitError.code == code {
                        match = true
                        break
                    }
                }
            }
        }
        return match
    }
}
