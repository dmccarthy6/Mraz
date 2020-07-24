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
        textView.font = .preferredFont(for: .body, weight: .medium)
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
            
            yesButton.topAnchor.constraint(equalTo: ageVerificationLabel.bottomAnchor, constant: 25),
            yesButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            yesButton.widthAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonWidthAnchors),
            
            noButton.topAnchor.constraint(equalTo: yesButton.bottomAnchor, constant: 35),
            noButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            noButton.widthAnchor.constraint(equalToConstant: AgeVerificationConstants.buttonWidthAnchors)
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
        ageTextView.backgroundColor = .systemGray3
    }
    
    // MARK: - Interface
    func setTextViewForUnderage() {
        ageTextView.text = "Thank you for downloading our application. \n\n The content of this application is intended for adults over the age of 21. \n\n We encourage you to come back on or after your 21st birthday."
    }
}
