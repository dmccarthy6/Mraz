//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class AgeVerificationView: UIView {
    // MARK: - Properties
    private var ageVerificationLabel: UILabel = {
        let ageLabel = UILabel()
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.textColor = .label
        ageLabel.text = "Are you over 21?"
        ageLabel.backgroundColor = .clear
        ageLabel.textAlignment = .center
        ageLabel.font = UIFont(name: "Zapfino", size: 25)
        return ageLabel
    }()
    private var yesButton: UIButton = {
        let yesButton = UIButton(type: .system)
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.backgroundColor = .red
        yesButton.setTitle("Yes, I am", for: .normal)
        yesButton.tintColor = .secondarySystemBackground
        yesButton.layer.cornerRadius = 10
        yesButton.isUserInteractionEnabled = true
        return yesButton
    }()
    private var noButton: UIButton = {
        let noButton = UIButton(type: .system)
        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.backgroundColor = .red
        noButton.setTitle("No, not yet", for: .normal)
        noButton.tintColor = .secondarySystemBackground
        noButton.layer.cornerRadius = 10
        return noButton
    }()
    private let defaults = UserDefaults.standard
    private let authVerificationCode = "verifiedAge"
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0
        setupView()
        addShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowColor = UIColor.label.resolvedColor(with: traitCollection).cgColor
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .some(.dark) ? 0.1 : 0.5
    }
    
    // MARK: - Layout
    private func setupView() {
        addSubview(ageVerificationLabel)
        addSubview(yesButton)
        addSubview(noButton)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: AgeVerificationConstants.viewWidthAnchor), //370
            heightAnchor.constraint(equalToConstant: AgeVerificationConstants.viewHeightAnchor), //350
            
            ageVerificationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            ageVerificationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 2),
            
            yesButton.topAnchor.constraint(equalToSystemSpacingBelow: ageVerificationLabel.bottomAnchor, multiplier: 4),
            yesButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            yesButton.widthAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonWidthAnchors), //300
            
            noButton.topAnchor.constraint(equalToSystemSpacingBelow: yesButton.bottomAnchor, multiplier: 2),
            noButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            noButton.widthAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonWidthAnchors) //300
        ])
        
        //Button Targets
        yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
    }
    
    private func addShadow() {
        layer.cornerCurve = .circular
        layer.cornerRadius = 20
        backgroundColor = .secondarySystemBackground
        
        layer.shadowRadius = 10.0
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }
    
    //TO-DO: Implement these buttons
    // MARK: - Button Functions
    @objc func yesButtonTapped() {
        print("YES BUTTON TAPPED!")
        var userDefaults = Storage()
        userDefaults.userIsOfAge = true
        self.alpha = 0
        dismissView()
    }
    
    @objc func noButtonTapped() {
        var userDefaults = Storage()
        userDefaults.userIsOfAge = false
        print("NO BUTTON TAPPED!")
    }
    
    // MARK: - Interface
    func present(_ onView: UIViewController) {
        UIView.animate(withDuration: 0.5) {
            let viewX = onView.view.center.x
            let viewY = onView.view.center.y
            
            self.frame = CGRect(x: viewX,
                                y: viewY,
                                width: AgeVerificationConstants.viewWidthAnchor,
                                height: AgeVerificationConstants.viewHeightAnchor)
            self.center = onView.view.center
            self.alpha = 1
        }
    }
    
    func dismissView() {
        UIView.animate(withDuration: 2.5) {
            self.removeFromSuperview()
            //self.defaults.set(true, forKey: UserDefaultsKeys.ageVerification)
        }
    }
}
