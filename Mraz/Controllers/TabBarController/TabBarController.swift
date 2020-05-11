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
    
    // MARK: -
    /// Age has been verified, show the Tab Bar
    private func setUpTabBarController() {
        //
        mrazTabBar = UITabBarController()
        
        //Set Up Tabs
        // -> This is the home controller
        let homeController = HomeViewController()
        let homeTabBarImage = UIImage(systemName: "house")
        homeController.tabBarItem = UITabBarItem(title: "Home", image: homeTabBarImage, tag: 0)
        
        //Beer List Controller
        let beerListViewController = BeerListViewController()
        let beerImage = UIImage(systemName: "star")
        beerListViewController.tabBarItem = UITabBarItem(title: "Beer", image: beerImage, tag: 1)
        
        //MapKit Controller
        
        //Ritual Controller?
        
        ///Add View Controllers to the tab bar
        let controllers = [homeController, beerListViewController]
       
        viewControllers = controllers.map({
            UINavigationController(rootViewController: $0)
        })
        
    }
}
