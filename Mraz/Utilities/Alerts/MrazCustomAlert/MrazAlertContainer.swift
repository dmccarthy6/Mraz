//  Created by Dylan  on 9/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class MrazAlertContainer: UIView {
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContainerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContainerView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
}
