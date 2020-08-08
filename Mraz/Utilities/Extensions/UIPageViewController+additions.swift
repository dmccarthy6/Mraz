//  Created by Dylan  on 8/7/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

// MARK: - Page View Controller Extension -- Page Control
extension UIPageViewController {
    /// Safely jump to the next ViewController in the flow(if any).
    func goToNextPage() {
        guard let currentVC = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentVC) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    /// Safely return to previous ViewController in the flow(if any).
    func goToPreviousPage() {
        guard let currentVC = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentVC) else { return }
        setViewControllers([previousViewController], direction: .forward, animated: true, completion: nil)
    }
}
