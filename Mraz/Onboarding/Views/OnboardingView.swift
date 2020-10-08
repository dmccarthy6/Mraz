//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

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
    private let nextButton: NextButton = {
        let button = NextButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    private let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemRed
        button.tintColor = .label
        button.addTarget(self, action: #selector(_actionButtonTapped), for: .touchUpInside)
        return button
    }()
    private var mrazSettings = MrazSettings()
    var nextButtonTapped: EmptyClosure?
    var actionButtonTapped: EmptyClosure?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        configureNextButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureNextButton()
    }
    
    // MARK: -
    private func setupView() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(imageView)
        addSubview(nextButton)
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
            actionButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 30),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            nextButton.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -175),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        actionButton.addTarget(self, action: #selector(_actionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Functions
    private func configureNextButtonAction() {
        nextButton.nextButtonTapped = { [weak self] in
            self?.nextButtonTapped?()
        }
    }
    
    private func configureNextButton() {
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.clipsToBounds = true
    }
    
    @objc
    private func _actionButtonTapped() {
        actionButtonTapped?()
    }
    
    // MARK: - Interface
    func setData(title: String, buttonTitle: String, description: String, image: UIImage?) {
        titleLabel.text = title
        descriptionLabel.text = description
        imageView.image = image
        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    func nextButton(isEnabled: Bool, isHidden: Bool) {
        self.nextButton.isHidden = isHidden
        self.nextButton.isEnabled = isEnabled
    }
    
    func dismissOnboardingView(from viewController: UIViewController) {
        #warning("Uncomment below to enable onboarding flow only once for users")
        //mrazSettings.set(true, for: .didFinishOnboarding)
        viewController.dismiss(animated: true)
    }
}
