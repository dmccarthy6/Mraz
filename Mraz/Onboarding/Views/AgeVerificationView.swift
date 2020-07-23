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
    private var ageTextView: UITextView = {
       let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        textView.font = .preferredFont(for: .title2, weight: .medium)
        textView.textColor = .systemRed
        return textView
    }()
    private var yesButton: UIButton = {
        let yesButton = UIButton(type: .system)
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.backgroundColor = .red
        yesButton.setTitle("YES", for: .normal)
        yesButton.tintColor = .secondarySystemBackground
        yesButton.layer.cornerRadius = 10
        yesButton.addTarget(self, action: #selector(_didTapYesButton), for: .touchUpInside)
        yesButton.isUserInteractionEnabled = true
        return yesButton
    }()
    private var noButton: UIButton = {
        let noButton = UIButton(type: .system)
        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.backgroundColor = .red
        noButton.setTitle("NOT YET", for: .normal)
        noButton.tintColor = .secondarySystemBackground
        noButton.layer.cornerRadius = 10
        return noButton
    }()
    private let defaults = UserDefaults.standard
    private let authVerificationCode = "verifiedAge"
    var yesButtonTapped: EmptyClosure?
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layer.shadowColor = UIColor.label.resolvedColor(with: traitCollection).cgColor
//        layer.shadowOpacity = traitCollection.userInterfaceStyle == .some(.dark) ? 0.1 : 0.5
//    }
    
    // MARK: - Layout
    private func setupView() {
        addSubview(ageVerificationLabel)
        addSubview(yesButton)
        addSubview(noButton)
        addSubview(ageTextView)
        
        NSLayoutConstraint.activate([
            ageVerificationLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            ageVerificationLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ageVerificationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            ageVerificationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            ageTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            ageTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 105),
            ageTextView.bottomAnchor.constraint(equalTo: ageVerificationLabel.topAnchor, constant: -2),
            
            yesButton.topAnchor.constraint(equalTo: ageVerificationLabel.bottomAnchor, constant: 5),
            yesButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            yesButton.widthAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonWidthAnchors),
            
            noButton.topAnchor.constraint(equalTo: yesButton.bottomAnchor, constant: 15),
            noButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            noButton.widthAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonWidthAnchors)
        ])
        
        //Button Targets
        
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Functions
    @objc
    private func _didTapYesButton() {
        yesButtonTapped?()
        ageVerificationLabel.text = "Welcome To Our App"
        
        print("YES BUTTON TAPPED!")
        let mrazSettings = MrazSettings()
        mrazSettings.set(true, for: .userIsOfAge)
        
        //dismissView()
    }
    
    @objc
    func noButtonTapped() {
        let mrazSettings = MrazSettings()
        mrazSettings.set(false, for: .userIsOfAge)
        setTextViewForUnderage()
    }
    
    private func setTextViewForUnderage() {
        ageTextView.text = "Thank you for downloading our application. Because the content of this app is geared towards prople that are over 21 we ask that you come back on or after your 21st birthday!"
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
    
    private func dismissView() {
        UIView.animate(withDuration: 2.5) {
            self.removeFromSuperview()
        }
    }
}

/*
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
 */
