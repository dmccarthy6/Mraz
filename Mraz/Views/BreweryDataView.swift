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
    private var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.
        return stack
    }()
    private var mapImageView: UIImageView = {
        let mapImageView = UIImageView()
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        mapImageView.image = SystemImages.mapPin
        mapImageView.contentMode = .scaleAspectFill
        return mapImageView
    }()
    private var phoneImageView: UIImageView = {
        let phoneImageView = UIImageView()
        phoneImageView.translatesAutoresizingMaskIntoConstraints = false
        phoneImageView.image = SystemImages.phoneCircleFill
        phoneImageView.contentMode = .scaleAspectFill
        return phoneImageView
    }()
    private var websiteImageView: UIImageView = {
        let webImageView = UIImageView()
        webImageView.translatesAutoresizingMaskIntoConstraints = false
        webImageView.contentMode = .scaleAspectFill
        webImageView.image = SystemImages.linkCircleFill
        return webImageView
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemRed
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupViews() {
        addSubview(nameLabel)
        addSubview(addressLabel)
        addSubview(mapImageView)
        addSubview(phoneImageView)
        addSubview(websiteImageView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            addressLabel.topAnchor.constraint(equalToSystemSpacingBelow: nameLabel.bottomAnchor, multiplier: 1),
            
            mapImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 4),
            mapImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mapImageView.widthAnchor.constraint(equalToConstant: 25),
            mapImageView.heightAnchor.constraint(equalToConstant: 25),
            
            phoneImageView.leadingAnchor.constraint(equalTo: mapImageView.trailingAnchor),
            phoneImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            phoneImageView.widthAnchor.constraint(equalToConstant: 25),
            phoneImageView.heightAnchor.constraint(equalToConstant: 25),
            
            websiteImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: phoneImageView.trailingAnchor, multiplier: 1),
            websiteImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            websiteImageView.widthAnchor.constraint(equalToConstant: 25),
            websiteImageView.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
}

enum BreweryInfo {
    static let name = "Mraz Brewing Company"
    static let address = "222 Francisco Drive \nEl Dorado Hills, CA 95762"
    static let phone = "916-"
}
