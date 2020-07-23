//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

class MrazTabBarController: UITabBarController {
    // MARK: - Properties
    private var mrazTabBar = UITabBarController()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBarController()
    }
    
    private func setUpTabBarController() {
        //
        mrazTabBar = UITabBarController()
        
        //Set Up Tabs
        // Home View Controller
        let homeController = HomeViewController()
        homeController.tabBarItem = UITabBarItem(title: "Home", image: SystemImages.houseImage, tag: 0)
        
        //Beer List Controller
        let beerListViewController = BeerListViewController()
        let beerImage = UIImage(systemName: "star")
        beerListViewController.tabBarItem = UITabBarItem(title: "Beer", image: beerImage, tag: 1)
        
        //MapKit Controller
        let mapController = MapViewController()
        mapController.tabBarItem = UITabBarItem(title: "Map", image: SystemImages.mapImage, tag: 2)
        
        ///Add View Controllers to the tab bar
        let controllers = [homeController, beerListViewController, mapController]
       
        viewControllers = controllers.map({
            UINavigationController(rootViewController: $0)
        })
        
    }
}
