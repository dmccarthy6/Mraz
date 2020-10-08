//  Created by Dylan  on 9/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class MZAlertBodyLabel: UILabel {
    // MARK: - Type
    enum LabelType {
        case body, title
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAlertView()
    }
    
    convenience init(type: LabelType) {
        self.init(frame: .zero)
        
        switch type {
        case .title: configureTitleLabel()
        case .body: configureAlertView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    func configureAlertView() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
        //font = .prefer
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
        lineBreakMode = .byWordWrapping
    }
    
    func configureTitleLabel() {
        
    }
}
