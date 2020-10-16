//  Created by Dylan  on 8/21/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

extension UIViewController {
    func openBeerInfoVC(from objectID: NSManagedObjectID, context: NSManagedObjectContext) {
        let beerInfoVC = BeerInfoViewController(context: context)
        beerInfoVC.objectID = objectID
        let navController = UINavigationController(rootViewController: beerInfoVC)
        present(navController, animated: true)
    }
    
    ///
    func showAlertOnMain(title: String, message: String, buttonTitle: String, _ completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alertViewController = MZAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertViewController.modalPresentationStyle = .overFullScreen
            alertViewController.modalTransitionStyle = .crossDissolve
            alertViewController.buttonFunc = {
                completion?()
            }
            self.present(alertViewController, animated: true)
        }
    }
    
    func verifyUsersAge() {
        let settings = MrazSettings()
        let isOFAge = settings.readBool(for: .userIsOfAge)
        
        if !isOFAge {
            showAlertOnMain(title: "Age Verification", message: "Are you over 21?", buttonTitle: "Yes") {
                settings.set(true, for: .userIsOfAge)
            }
        }
    }
}
