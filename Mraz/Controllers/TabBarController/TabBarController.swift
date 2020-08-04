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
        setIconColors()
    }
    
    private func setUpTabBarController() {
        self.tabBar.barTintColor = .systemRed
        
        // Home View Controller
        let homeController = HomeViewController()
        homeController.tabBarItem = UITabBarItem(title: "On Tap", image: SystemImages.houseImage, tag: 0)
        
        //Beer List Controller
        let beerListViewController = BeerListViewController()
        let beerImg = TabBarImages.beerMug!
        beerImg.withTintColor(.green)
//        let beerImage = UIImage(systemName: "star")
        beerListViewController.tabBarItem = UITabBarItem(title: "Beers", image: beerImg, tag: 1)
        
        
        //MapKit Controller
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
        self.tabBar.unselectedItemTintColor = .black
        
    }
}
