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
}
