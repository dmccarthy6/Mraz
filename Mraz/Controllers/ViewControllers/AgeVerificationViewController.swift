//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class AgeVerificationViewController: UIViewController {
    // MARK: - Properties
    private lazy var ageVerificationView: AgeVerificationView = {
        let view = AgeVerificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var ageHasBeenVerified: EmptyClosure?
    var userNotOfAge: EmptyClosure?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
    }
    
    private func setupView() {
        view.addSubview(ageVerificationView)
        
        NSLayoutConstraint.activate([
            ageVerificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ageVerificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ageVerificationView.topAnchor.constraint(equalTo: view.topAnchor),
            ageVerificationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        yesButtonTapped()
        noButtonTapped()
    }
    
    private func yesButtonTapped() {
        ageVerificationView.yesButtonTapped = { [weak self] in
            self?.ageHasBeenVerified?()
        }
    }
    
    private func noButtonTapped() {
        ageVerificationView.noButtonTapped = { [weak self] in
            self?.userNotOfAge?()
        }
    }
    
    // MARK: - Interface
    #warning("TODO - Do I need this?")
//    func createAgeViewController() {
//        let controller = AgeVerificationViewController()
//    }
}
