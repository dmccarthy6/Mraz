<<<<<<< HEAD
<<<<<<< HEAD
//
//  MZAlertVC.swift
//  Mraz
//
//  Created by Dylan  on 9/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.
//

import Foundation
=======
=======
>>>>>>> 9ebc40cf2474a42d9adc9be1aee45bbe317d507c
//  Created by Dylan  on 9/17/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class MZAlertVC: UIViewController {
    // MARK: - Properties
    private let alertContainer = MrazAlertContainer()
    private let alertTitleLabel = MZAlertTitleLabel(textAlignment: .center, fontSize: 20)
    private let messageLabel = MZAlertBodyLabel(textAlignment: .center)
    let alertActionButton = MZButton(backgroundColor: .systemRed, title: "OK")
    var alertTitle: String?
    var alertMessage: String?
    var alertButtonTitle: String?
    private let padding: CGFloat = 20.0
    var buttonFunc: EmptyClosure?
    
    // MARK: - Lifecycle
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.alertMessage = message
        self.alertButtonTitle = buttonTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.90)
        view.isOpaque = false
        configureContainerView()
        configureActionButton()
        configureTitleLabel()
        configureBodyLabel()
        
    }
    
    // MARK: - Configure Views
    
    private func configureContainerView() {
        view.addSubview(alertContainer)
        
        NSLayoutConstraint.activate([
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertContainer.widthAnchor.constraint(equalToConstant: 300),
            alertContainer.heightAnchor.constraint(equalToConstant: 320)
        ])
    }
    
    // MARK: - Helpers
    private func configureTitleLabel() {
        view.addSubview(alertTitleLabel)
        alertTitleLabel.text = alertTitle
        
        NSLayoutConstraint.activate([
            alertTitleLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: padding),
            alertTitleLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -padding),
            alertTitleLabel.topAnchor.constraint(equalTo: alertContainer.topAnchor, constant: padding),
            alertTitleLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func configureBodyLabel() {
        view.addSubview(messageLabel)
        messageLabel.text = alertMessage
        messageLabel.numberOfLines = 4
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -padding),
            messageLabel.topAnchor.constraint(equalTo: alertTitleLabel.bottomAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: alertActionButton.topAnchor, constant: -11)
        ])
    }
    
    private func configureActionButton() {
        view.addSubview(alertActionButton)
        alertActionButton.setTitle(alertButtonTitle, for: .normal)
        alertActionButton.addTarget(self, action: #selector(actionButtonFunction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            alertActionButton.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: padding),
            alertActionButton.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -padding),
            alertActionButton.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -padding),
            alertActionButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    @objc func actionButtonFunction() {
        buttonFunc?()
        self.dismiss(animated: true)
    }
}
<<<<<<< HEAD
>>>>>>> eb747e9dbd62572f5834cbaac5f70489824757f8
=======
>>>>>>> 9ebc40cf2474a42d9adc9be1aee45bbe317d507c
