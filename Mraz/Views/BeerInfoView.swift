//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class BeerInfoView: UIView {
    // MARK: - Properties
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .title3, weight: .bold)
        return label
    }()
    private var typeABVLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .headline, weight: .medium)
        return label
    }()
    private var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.automaticallyAdjustsScrollIndicatorInsets = false
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label
        textView.textAlignment = .center
        textView.backgroundColor = .systemBackground
        textView.isEditable = false
        textView.font = .preferredFont(for: .body, weight: .light)
        return textView
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupView() {
        addSubview(titleLabel)
        addSubview(typeABVLabel)
        addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            
            typeABVLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            typeABVLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            typeABVLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            descriptionTextView.topAnchor.constraint(equalToSystemSpacingBelow: typeABVLabel.bottomAnchor, multiplier: 3),
            descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Interface
    func createBeerInfoView(title: String?, type: String?, abv: String?, description: String?) {
        titleLabel.text = title
        typeABVLabel.text = "\(type ?? ""), \(abv ?? "") ABV"
        descriptionTextView.text = description
    }
}
