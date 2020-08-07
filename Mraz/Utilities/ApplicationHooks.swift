//  Created by Dylan  on 8/6/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

struct ApplicationHook {
    // MARK: - Properties
    private static let application = UIApplication.shared
    
    // MARK: -
    static func openIn(_ appHook: AppHook) {
        var hook = ""
        switch appHook {
        case .facebook: hook = appHook.appHook
        case .instagram: hook = appHook.appHook
        case .twitter: hook = appHook.appHook
        }
        guard let hookURL = URL(string: hook) else { return }
        guard let webURL = URL(string: appHook.webURL) else { return }
        
        if application.canOpenURL(hookURL) {
            application.open(hookURL, options: [:], completionHandler: nil)
        } else {
            application.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
