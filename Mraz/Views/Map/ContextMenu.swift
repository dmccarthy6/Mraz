//  Created by Dylan  on 5/15/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

protocol MapContextMenu {
    
}
extension MapContextMenu {
    
    func makeMrazMapContextMenu() -> UIMenu {
        let directions = UIAction(title: "Directions", image: SystemImages.squareAndUpArrow, state: .on) { (action) in
            print("Directions")
        }
        
        let call = UIAction(title: "Call", image: SystemImages.phoneCircleFillImage, state: .off) { (action) in
            print("Call")
        }
        
        return UIMenu(title: "", children: [directions, call])
    }
}
