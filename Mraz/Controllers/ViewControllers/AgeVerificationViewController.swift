//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class AgeVerificationViewController: UIViewController {
    //MARK: - Properties
    private lazy var ageVerificationView: AgeVerificationView = {
        let view = AgeVerificationView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
//        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        presentView()
    }
    
    //MARK: - Layout
//    func setupView() {
//        view.addSubview(ageVerificationView)
//
//        NSLayoutConstraint.activate([
//            ageVerificationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            ageVerificationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//
//        ])
//    }
    
    func presentView() {
        
        UIView.animate(withDuration: 0.5) {
            self.ageVerificationView.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: AgeVerificationConstants.viewWidthAnchor, height: AgeVerificationConstants.viewHeightAnchor)
            self.ageVerificationView.center = self.view.center
            self.ageVerificationView.alpha = 1
            self.view.addSubview(self.ageVerificationView)
        }
        NSLayoutConstraint.activate([
            ageVerificationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ageVerificationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        ])
        
    }
    
    func dismissView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.ageVerificationView.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
            self.ageVerificationView.isHidden = true
        }) { (true) in
            self.ageVerificationView.removeFromSuperview()
        }
    }
}
