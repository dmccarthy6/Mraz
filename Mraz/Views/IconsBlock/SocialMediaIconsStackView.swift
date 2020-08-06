//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class SocialMediaView: UIStackView {
    // MARK: - Properties
    private var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.axis = .horizontal
        return stack
    }()
    private var facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Facebook"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .white
        return button
    }()
    private var instagramButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Instagram"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemPink
        return button
    }()
    private var twitterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Twitter"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setButtonTargets()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupView() {
        addArrangedSubview(facebookButton)
        addArrangedSubview(instagramButton)
        addArrangedSubview(twitterButton)
        
        self.spacing = 35
        
        NSLayoutConstraint.activate([
            facebookButton.heightAnchor.constraint(equalToConstant: SocialConstants.iconHeight),
            facebookButton.widthAnchor.constraint(equalToConstant: SocialConstants.iconWidth),
            
            instagramButton.heightAnchor.constraint(equalToConstant: SocialConstants.iconHeight),
            instagramButton.widthAnchor.constraint(equalToConstant: SocialConstants.iconWidth),
            
            twitterButton.heightAnchor.constraint(equalToConstant: SocialConstants.iconHeight),
            twitterButton.widthAnchor.constraint(equalToConstant: SocialConstants.iconWidth),
            
            widthAnchor.constraint(equalToConstant: 145),
            heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    /// Set the targets on the buttons.
    private func setButtonTargets() {
        facebookButton.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        instagramButton.addTarget(self, action: #selector(instagramButtonTapped), for: .touchUpInside)
        twitterButton.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Targets
    /// Function called when the Facebook button tapped.
    @objc private func facebookButtonTapped() {
        ApplicationHook.openIn(.facebook)
    }
    /// Method called when Instagram button tapped
    @objc private func instagramButtonTapped() {
        ApplicationHook.openIn(.instagram)
    }
    /// Method called when Twitter button tapped.
    @objc private func twitterButtonTapped() {
        ApplicationHook.openIn(.twitter)
    }
}
