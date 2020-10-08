//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class BeerListCell: UICollectionViewCell {
    // MARK: - Properties
    private let beerNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .title3, weight: .semibold)
        label.textColor = .label
        return label
    }()
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .callout, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    private let abvLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .callout, weight: .bold)
        label.textColor = .label
        return label
    }()
    private var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.starImage, for: .normal)
        return button
    }()
    var makeBeerFavorite: EmptyClosure?
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCell()
        setupCardView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layoutCell() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(beerNameLabel)
        contentView.addSubview(abvLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(typeLabel)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            beerNameLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            beerNameLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            beerNameLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
            beerNameLabel.bottomAnchor.constraint(equalTo: typeLabel.topAnchor, constant: -2),
 
            typeLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            
            abvLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 2),
            abvLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            abvLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: BeerCellConstants.favIcon),
            favoriteButton.heightAnchor.constraint(equalToConstant: BeerCellConstants.favIcon),
            favoriteButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func setupCardView() {
        contentView.layer.cornerCurve = .circular
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.masksToBounds = true
        
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }
    
    // MARK: - Interface
    func configureBeerCell(beerName: String?, type: String?, abv: String?, isFavorite: Bool) {
        self.beerNameLabel.text = beerName
        self.abvLabel.text = "Abv: \(abv ?? "0.0")"
        self.typeLabel.text = type
        favoriteButton.tintColor = isFavorite ? .systemYellow : .systemBlue
        favoriteButton.setImage(isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), for: .normal)
    }
    
    /// Save new favorite status to Core Data
    func configureFavoritesButton(forElement: Beers) {
        let currentStatus = forElement.isFavorite
        favoriteButton.tintColor = currentStatus ? .systemBlue : .systemYellow
        favoriteButton.setImage(currentStatus ? UIImage(systemName: "star") : UIImage(systemName: "star.fill"), for: .normal)
    }
    
    // MARK: - Button Functions
    @objc private func favoriteButtonTapped() {
        makeBeerFavorite?()
    }
}

// MARK: - Accessibility
extension BeerListCell {
    func applyAccessibility(_ beers: Beers) {
        favoriteButton.accessibilityIdentifier = "Star button"
    }
}
