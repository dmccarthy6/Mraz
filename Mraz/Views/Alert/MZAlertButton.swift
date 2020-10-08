<<<<<<< HEAD
<<<<<<< HEAD
//
//  MZAlertButton.swift
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

final class MZButton: UIButton {
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(backgroundColor: UIColor, title: String) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
    }
    
    // MARK: - Helpers
    private func configureButton() {
        layer.cornerRadius = 10
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .preferredFont(for: .headline, weight: .bold)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Interface
    func set(backgroundColor: UIColor, title: String) {
        self.backgroundColor = backgroundColor
        setTitle(title, for: .normal)
    }
}
<<<<<<< HEAD
>>>>>>> eb747e9dbd62572f5834cbaac5f70489824757f8
=======
>>>>>>> 9ebc40cf2474a42d9adc9be1aee45bbe317d507c
