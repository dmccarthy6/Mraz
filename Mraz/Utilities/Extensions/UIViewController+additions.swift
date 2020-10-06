//  Created by Dylan  on 8/21/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

extension UIViewController {
    func openBeerInfoVC(from objectID: NSManagedObjectID) {
        let beerInfoVC = BeerInfoViewController()
        beerInfoVC.objectID = objectID
        let navController = UINavigationController(rootViewController: beerInfoVC)
        present(navController, animated: true)
    }
    
    ///
    func showAlertOnMain(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertViewController = MZAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertViewController.modalPresentationStyle = .overFullScreen
            alertViewController.modalTransitionStyle = .crossDissolve
            self.present(alertViewController, animated: true)
        }
    }
}
