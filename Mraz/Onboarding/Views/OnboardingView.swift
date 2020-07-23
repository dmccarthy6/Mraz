//  Created by Dylan  on 7/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class MrazOnboardingView: UIView, NotificationManager {
    // MARK: - Communication
    var didTapSkipButton: (() -> Void)?
    var didTapAcceptButton: (() -> Void)?
    var didTapDenyButton: (() -> Void)?
    var didTapOpenAppButton: (() -> Void)?
    
    // MARK: - Subviews
    private var dataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    private let nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(_didTapSkipButton), for: .touchUpInside)
        nextButton.titleLabel?.font = .preferredFont(for: .body, weight: .semibold)
        nextButton.setTitleColor(.systemBlue, for: .normal)
        nextButton.titleLabel?.textColor = .systemBlue
        return nextButton
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(for: .title1, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.automaticallyAdjustsScrollIndicatorInsets = false
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .preferredFont(for: .body, weight: .medium)
        textView.textColor = .label
        textView.textAlignment = .center
        textView.isEditable = false
        return textView
    }()
    private let agreeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(_didTapAcceptButton), for: .touchUpInside)
        button.layer.cornerRadius = 15
        return button
    }()
    private lazy var denyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(_didTapDenyButton), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 15
        return button
    }()
    private let showAppButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 15
        button.setTitle("Show App", for: .normal)
        button.addTarget(self, action: #selector(_didTapOpenAppButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    private func layoutView() {
        addSubview(dataView)
        dataView.addSubview(nextButton)
        dataView.addSubview(imageView)
        dataView.addSubview(textView)
        dataView.addSubview(agreeButton)
        dataView.addSubview(denyButton)
        dataView.addSubview(showAppButton)
        dataView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            dataView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            dataView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            dataView.topAnchor.constraint(equalTo: topAnchor),
            dataView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: dataView.leadingAnchor, constant: 2),
            imageView.trailingAnchor.constraint(equalTo: dataView.trailingAnchor, constant: -2),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: dataView.topAnchor, multiplier: 5),

            titleLabel.leadingAnchor.constraint(equalTo: dataView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: dataView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 1),
            
            textView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
            textView.heightAnchor.constraint(equalToConstant: 190),
            textView.leadingAnchor.constraint(equalTo: dataView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: dataView.trailingAnchor),
            
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            nextButton.topAnchor.constraint(equalToSystemSpacingBelow: dataView.topAnchor, multiplier: 1),
            
            //BOTTOM VIEW
            agreeButton.leadingAnchor.constraint(equalTo: dataView.leadingAnchor, constant: 35),
            agreeButton.trailingAnchor.constraint(equalTo: dataView.trailingAnchor, constant: -35),
            agreeButton.topAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 3),
            
            showAppButton.leadingAnchor.constraint(equalTo: dataView.leadingAnchor, constant: 35),
            showAppButton.trailingAnchor.constraint(equalTo: dataView.trailingAnchor, constant: -35),
            showAppButton.topAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 3),
            
            denyButton.leadingAnchor.constraint(equalTo: dataView.leadingAnchor, constant: 35),
            denyButton.trailingAnchor.constraint(equalTo: dataView.trailingAnchor, constant: -35),
            denyButton.topAnchor.constraint(equalToSystemSpacingBelow: agreeButton.bottomAnchor, multiplier: 2)
        ])
    }
    
    // MARK: - Button Actions
    @objc
    private func _didTapDenyButton() {
        didTapDenyButton?()
    }
    
    @objc
    private func _didTapAcceptButton() {
        didTapAcceptButton?()
    }
    
    @objc
    private func _didTapSkipButton() {
        didTapSkipButton?()
    }
    
    @objc
    private func _didTapOpenAppButton() {
        didTapOpenAppButton?()
    }
    
    // MARK: - Interface
    func configureOnboardingScreen(title: String?, descriptionText: String?, image: UIImage) {
        titleLabel.text = title
        textView.text = descriptionText ?? "Nil"
        imageView.image = image
    }
    
    func configureButton(addButtonTitle: String, denyButtonTitle: String) {
        agreeButton.setTitle(addButtonTitle, for: .normal)
        denyButton.setTitle(denyButtonTitle, for: .normal)
        denyButton.setTitleColor(.systemRed, for: .normal)
    }
    
    func setButton(agreeHidden: Bool, denyHidden: Bool, skipHidden: Bool = false, showAppHidden: Bool = false) {
        agreeButton.isHidden = agreeHidden
        denyButton.isHidden = denyHidden
        nextButton.isHidden = skipHidden
        showAppButton.isHidden = showAppHidden
    }
}
