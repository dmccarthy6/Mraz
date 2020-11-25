//
//  CloudKitSync.swift
//  Mraz
//
//  Created by Dylan  on 11/20/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.
//

import CloudKit

protocol CloudKitSync {
    func syncRemoteChangedRecords()
}
