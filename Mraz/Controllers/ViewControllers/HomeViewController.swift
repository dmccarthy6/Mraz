//  Created by Dylan  on 5/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class HomeViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        PresentAgeVerificationView(viewController: self)
        view.backgroundColor = .yellow
    }
    
    //USE THIS CLASS TO SHOW THE ON TAP BEERS & BREWERY INFO?
    //THIS SHOULD BE THE FIRST VIEW IN THE TAB BAR CONTROLLER
}
