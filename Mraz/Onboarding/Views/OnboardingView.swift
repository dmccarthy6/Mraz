//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreLocation

protocol DismissViewDelegate: class {
    func dismissOnboardingViews()
}

enum ButtonType {
    case geofencing
    case notifications
    case launch
}

final class MrazOnboardingView: UIView {
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .title2, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .subheadline, weight: .medium)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemRed
        button.tintColor = .label
        return button
    }()
    private var mrazSettings = MrazSettings()
    private lazy var locationProvider = CurrentLocationProvider()
    weak var dismissDelegate: DismissViewDelegate?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(imageView)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 75),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -75),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])

    }
    
    // MARK: - Interface
    func setData(title: String, description: String, image: UIImage?, buttonTitle: String, buttonType: ButtonType) {
        titleLabel.text = title
        descriptionLabel.text = description
        imageView.image = image
        actionButton.setTitle(buttonTitle, for: .normal)
        
        // Set Button Actions
        switch buttonType {
        case .notifications:
            actionButton.addTarget(self, action: #selector(localNotificationsAction), for: .touchUpInside)
            
        case .geofencing:
            actionButton.addTarget(self, action: #selector(geofencingNotificationsAction), for: .touchUpInside)
            
        case .launch:
            actionButton.addTarget(self, action: #selector(launchAction), for: .touchUpInside)
        }
    }
    
    // MARK: - Button Functions
    @objc
    private func localNotificationsAction() {
        LocalNotificationManger().promptUserForLocalNotifications()
    }
    
    @objc
    private func geofencingNotificationsAction() {
        locationProvider.checkLocationAuthStatus()
    }

    @objc
    private func launchAction() {
        dismissDelegate?.dismissOnboardingViews()
    }
}
