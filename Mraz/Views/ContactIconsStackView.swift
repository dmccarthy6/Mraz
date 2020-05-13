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
    private var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.mapPin!, for: .normal)
        button.tintColor = .systemBackground
        return button
    }()
    private var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.linkCircleFill!, for: .normal)
        button.tintColor = .systemBackground
        return button
    }()
    private var phoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.phoneCircleFill!, for: .normal)
        button.tintColor = .systemBackground
        return button
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addButtonFunctions()
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
    
    /// Set the button targets for each of the buttons.
    private func addButtonFunctions() {
        mapButton.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        websiteButton.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
        phoneButton.addTarget(self, action: #selector(phoneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Targets
    /// Function called when the Map button tapped.
    @objc private func mapButtonTapped() {
        print("ContactBlockView -- Map Button Tapped")
        Contact.showBreweryLocationOnMap()
    }
    /// Method called when Website button tapped
    @objc private func webButtonTapped() {
        print("ContactBlockView -- Web Button Tapped")
        Contact.openBreweryWebsite()
    }
    /// Method called when Phone button tapped.
    @objc private func phoneButtonTapped() {
        print("ContactBlockView -- Phone Button Tapped")
        Contact.callBrewery()
    }
}
