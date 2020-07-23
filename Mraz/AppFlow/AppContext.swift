//  Created by Dylan  on 7/16/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class AppContext: NSObject {
    // MARK: - Instance of State
    private(set) lazy var state: State = {
        determineAppState()
    }()
    
    let userSettings: MrazSettings
    
    // MARK: - Initializer
    init(userSettings: MrazSettings = .init()) {
        self.userSettings = userSettings
    }
    
    // MARK: - State Management
    
    /// Return user state to determine how the user should be directed
    ///
    /// - Returns: The app state for the current user
    private func determineAppState() -> State {
        if userSettings.readBool(for: .didFinishOnboarding) {
            return .session
        } else {
            return .onboarding
        }
    }
}

extension AppContext {
    enum State {
        case onboarding
        case session
    }
}
