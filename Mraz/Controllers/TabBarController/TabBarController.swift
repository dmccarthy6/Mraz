//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

class MrazTabBarController: UITabBarController {
    // MARK: - Properties
    private var mrazTabBar = UITabBarController()
    var cloudKitManager: CloudKitManager
    
    // MARK: - Lifecyce
    init(cloudKitManager: CloudKitManager) {
        self.cloudKitManager = cloudKitManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBarController()
        setIconColors()
    }
    
    private func setUpTabBarController() {
        self.tabBar.barTintColor = .systemRed
        
        let homeController = HomeViewController(cloudKitManager: cloudKitManager)
        homeController.tabBarItem = UITabBarItem(title: "On Tap", image: SystemImages.houseImage, tag: 0)
        
        let beerListViewController = BeerListViewController()
        beerListViewController.tabBarItem = UITabBarItem(title: "Beers", image: TabBarImages.beerMug, tag: 1)
        
        let mapController = MapViewController()
        mapController.tabBarItem = UITabBarItem(title: "Food", image: SystemImages.mapImage, tag: 2)
        
        let controllers = [homeController, beerListViewController, mapController]
       
        viewControllers = controllers.map({
            let navController = UINavigationController(rootViewController: $0)
            navController.navigationBar.barTintColor = .systemRed
            navController.navigationBar.prefersLargeTitles = true
            return navController
        })
    }
    
    private func setIconColors() {
        self.tabBar.unselectedItemTintColor = .white
    }
}
