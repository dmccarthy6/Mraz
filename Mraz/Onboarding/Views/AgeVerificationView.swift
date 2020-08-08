//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class AgeVerificationView: UIView {
    // MARK: - Properties
    private var ageVerificationLabel: UILabel = {
        let ageLabel = UILabel()
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.adjustsFontForContentSizeCategory = true
        ageLabel.numberOfLines = 0
        ageLabel.textColor = .label
        ageLabel.text = "Are you over 21?"
        ageLabel.backgroundColor = .systemBackground
        ageLabel.textAlignment = .natural
        ageLabel.font = .preferredFont(for: .title3, weight: .semibold)
        return ageLabel
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .label
        label.text = "The content of this application is desiged for adults."
        label.font = .preferredFont(for: .subheadline, weight: .medium)
        return label
    }()
    private var yesButton: UIButton = {
        let yesButton = UIButton(type: .system)
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.backgroundColor = .systemRed
        yesButton.setTitle("YES", for: .normal)
        yesButton.tintColor = .label
        yesButton.layer.cornerRadius = 20
        yesButton.addTarget(self, action: #selector(_didTapYesButton), for: .touchUpInside)
        yesButton.isUserInteractionEnabled = true
        return yesButton
    }()
    private var noButton: UIButton = {
        let noButton = UIButton(type: .system)
        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.backgroundColor = .systemBlue
        noButton.setTitle("NO", for: .normal)
        noButton.tintColor = .label
        noButton.layer.cornerRadius = 20
        noButton.addTarget(self, action: #selector(_didTapNoButton), for: .touchUpInside)
        return noButton
    }()
    private let mrazSettings = MrazSettings()
    var yesButtonTapped: EmptyClosure?
    var noButtonTapped: EmptyClosure?
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    // MARK: - Layout
    private func setupView() {
        addSubview(ageVerificationLabel)
        addSubview(descriptionLabel)
        addSubview(yesButton)
        addSubview(noButton)
        
        NSLayoutConstraint.activate([
            ageVerificationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            ageVerificationLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ageVerificationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),

            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(equalTo: ageVerificationLabel.bottomAnchor, constant: 10),

            yesButton.bottomAnchor.constraint(equalTo: noButton.topAnchor, constant: -12),
            yesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 75),
            yesButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -75),
            yesButton.heightAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonHeightAnchors),
            
            noButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -125),
            noButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 75),
            noButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -75),
            noButton.heightAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonHeightAnchors)
        ])
    }
    
    // MARK: - Button Functions
    @objc
    private func _didTapYesButton() {
        yesButtonTapped?()
        mrazSettings.set(true, for: .userIsOfAge)
    }
    
    @objc
    private func _didTapNoButton() {
        noButtonTapped?()
        mrazSettings.set(false, for: .userIsOfAge)
    }
}
