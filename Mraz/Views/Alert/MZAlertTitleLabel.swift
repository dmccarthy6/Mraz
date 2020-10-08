<<<<<<< HEAD
<<<<<<< HEAD
//
//  MZAlertTitleLabel.swift
//  Mraz
//
//  Created by Dylan  on 9/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.
//

import Foundation
=======
=======
>>>>>>> 9ebc40cf2474a42d9adc9be1aee45bbe317d507c
//  Created by Dylan  on 9/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class MZAlertTitleLabel: UILabel {
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    private func configureTitleLabel() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
        font = .preferredFont(for: .title1, weight: .regular)
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        lineBreakMode = .byTruncatingTail
    }
}
<<<<<<< HEAD
>>>>>>> eb747e9dbd62572f5834cbaac5f70489824757f8
=======
>>>>>>> 9ebc40cf2474a42d9adc9be1aee45bbe317d507c
