//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

class BeerListCell: UICollectionViewCell, WriteToCoreData {
    //MARK: - Properties
    private let beerNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .title1, weight: .bold)
        label.textColor = .label
        return label
    }()
    private let typeLabel: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.numberOfLines = 0
           label.adjustsFontForContentSizeCategory = true
           label.font = .preferredFont(for: .title2, weight: .regular)
           label.textColor = .systemGray
           return label
       }()
    private let abvLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .largeTitle, weight: .bold)
        label.textColor = .systemGray3
        return label
    }()
    private var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(SystemImages.favoriteButton, for: .normal)
        button.tintColor = .gray
        return button
    }()
    var setAsFavorite: (() -> Void)!
    
    
    //MARK: View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCell()
        setupCardView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - Layout
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
            
            typeLabel.topAnchor.constraint(equalToSystemSpacingBelow: beerNameLabel.bottomAnchor, multiplier: 1),
            typeLabel.leadingAnchor.constraint(equalTo: beerNameLabel.leadingAnchor),
            
            abvLabel.topAnchor.constraint(equalToSystemSpacingBelow: typeLabel.bottomAnchor, multiplier: 1),
            abvLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: BeerCellConstants.favIcon),
            favoriteButton.heightAnchor.constraint(equalToConstant: BeerCellConstants.favIcon),
            favoriteButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func setupCardView() {
        contentView.layer.cornerCurve = .circular
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.masksToBounds = true
        
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }
    
    //MARK: - Interface
    func configureBeerCell(beerName: String?, type: String?, abv: String?, isFavorite: Bool, isOnTap: Bool) {
        self.beerNameLabel.text = beerName
        self.abvLabel.text = abv
        self.typeLabel.text = type
        favoriteButton.tintColor = isFavorite ? .systemYellow : .systemGray3
        favoriteButton.setImage(isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"), for: .normal)
    }
    
    /// Save new favorite status to Core Data
    func setFavorite(_ objectAtIndex: Beers) {
        updateFavoriteStatusOn(objectAtIndex)
    }
    
    /// Set button function to the closure passed in by the VC
    func setFavoriteStatus(_ function: @escaping () -> Void) {
        self.setAsFavorite = function
    }
    
    //MARK: - Button Functions
    @objc private func favoriteButtonTapped() {
        setAsFavorite()
    }
    
}
