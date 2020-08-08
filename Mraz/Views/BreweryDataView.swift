//  Created by Dylan  on 5/8/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class BreweryDataView: UIView {
    // MARK: - Properties
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        label.font = .preferredFont(for: .title1, weight: .bold)
        label.text = BreweryInfo.name
        return label
    }()
    private var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .body, weight: .medium)
        label.text = BreweryInfo.address
        return label
    }()
    private var allIconsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 25
        return stackView
    }()
    private var socialIcons: SocialMediaView = {
        let view = SocialMediaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var contactIcons: ContactIconsStackView = {
        let contactIconsView = ContactIconsStackView()
        contactIconsView.translatesAutoresizingMaskIntoConstraints = false
        return contactIconsView
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray3
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(allIconsStackView)
        
        allIconsStackView.addArrangedSubview(socialIcons)
        allIconsStackView.addArrangedSubview(contactIcons)

        NSLayoutConstraint.activate([
            allIconsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            allIconsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func setContactButtonActions() {
        contactIcons.mapButtonTapped = {
            Contact.contact(contactType: .directions, value: BreweryInfo.name)
        }
        
        contactIcons.phoneButtonTapped = {
            Contact.contact(contactType: .phone, value: BreweryInfo.phone)
        }
        contactIcons.webButtonTapped = {
            Contact.contact(contactType: .web, value: BreweryInfo.website)
        }
    }
}
