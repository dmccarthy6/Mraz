//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

/// The Contact Stack View that includes the Map, Website, & Phone buttons.
final class ContactIconsStackView: UIStackView {
    // MARK: - Properties
    private var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        return stack
    }()
    private lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.mapPinImage, for: .normal)
        button.tintColor = .systemBackground
        button.addTarget(self, action: #selector(_mapButtonTapped), for: .touchUpInside)
        return button
    }()
    private var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.linkCircleFillImage, for: .normal)
        button.tintColor = .systemBackground
        button.addTarget(self, action: #selector(_webButtonTapped), for: .touchUpInside)
        return button
    }()
    private var phoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.phoneCircleFillImage, for: .normal)
        button.tintColor = .systemBackground
        button.addTarget(self, action: #selector(_phoneButtonTapped), for: .touchUpInside)
        return button
    }()
    var mapButtonTapped: EmptyClosure?
    var phoneButtonTapped: EmptyClosure?
    var webButtonTapped: EmptyClosure?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupView() {
        addArrangedSubview(mapButton)
        addArrangedSubview(websiteButton)
        addArrangedSubview(phoneButton)
        
        self.spacing = 15
        
        NSLayoutConstraint.activate([
            mapButton.heightAnchor.constraint(equalToConstant: SocialConstants.iconHeight),
            mapButton.widthAnchor.constraint(equalToConstant: SocialConstants.iconWidth),
            
            websiteButton.heightAnchor.constraint(equalToConstant: SocialConstants.iconHeight),
            websiteButton.widthAnchor.constraint(equalToConstant: SocialConstants.iconWidth),
            
            phoneButton.heightAnchor.constraint(equalToConstant: SocialConstants.iconHeight),
            phoneButton.widthAnchor.constraint(equalToConstant: SocialConstants.iconWidth),
            
            widthAnchor.constraint(equalToConstant: 105),
            heightAnchor.constraint(equalToConstant: 25)
        ])
    }

    // MARK: - Button Targets
    /// Function called when the Map button tapped.
    @objc private func _mapButtonTapped() {
        self.mapButtonTapped?()
        //Contact.getDirections()
    }
    /// Method called when Website button tapped
    @objc private func _webButtonTapped() {
        self.webButtonTapped?()
        //Contact.open()
    }
    /// Method called when Phone button tapped.
    @objc private func _phoneButtonTapped() {
        self.phoneButtonTapped?()
        //Contact.placePhoneCall()
    }
}
