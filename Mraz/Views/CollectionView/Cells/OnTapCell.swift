//  Created by Dylan  on 5/8/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class OnTapCell: UICollectionViewCell {
    // MARK: - Properties
    private let beerNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .title3, weight: .bold)
        return label
    }()
    private let beerTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .body, weight: .medium)
        return label
    }()
    private let beerABVLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .caption1, weight: .medium)
        return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCardView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.label.resolvedColor(with: traitCollection).cgColor
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .some(.dark) ? 0.0 : 0.3
    }
    
    // MARK: - Helpers
    private func setupLayout() {
        contentView.addSubview(beerNameLabel)
        contentView.addSubview(beerTypeLabel)
        contentView.addSubview(beerABVLabel)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            beerNameLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            beerNameLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            beerNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1),
            
            beerTypeLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            beerTypeLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            beerTypeLabel.topAnchor.constraint(equalTo: beerNameLabel.bottomAnchor),
            
            beerABVLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            beerABVLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            beerABVLabel.topAnchor.constraint(equalToSystemSpacingBelow: beerTypeLabel.bottomAnchor, multiplier: 1)
        ])
        contentView.layer.cornerRadius = 20
    }
    
    private func setupCardView() {
        contentView.layer.cornerCurve = .circular
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.masksToBounds = true
        
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }
    
    // MARK: - Interface
    func configureOnTapCell(name: String?, type: String?, beerABV: String?) {
        beerNameLabel.text = name
        beerTypeLabel.text = type
        beerABVLabel.text = ("\(beerABV ?? "") ABV")
    }
}
