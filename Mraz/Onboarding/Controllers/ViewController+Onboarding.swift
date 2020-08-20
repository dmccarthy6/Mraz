//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class MrazOnboardingViewController: UIViewController {
    // MARK: Properties
    var onBoardingView: MrazOnboardingView = {
        let view = MrazOnboardingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        onBoardingView.backgroundColor = .systemBackground
        setupView()
    }
 
    // MARK: - Helpers
    private func setupView() {
        view.addSubview(onBoardingView)
        
        NSLayoutConstraint.activate([
            onBoardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onBoardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onBoardingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            onBoardingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
