//  Created by Dylan  on 4/30/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import Foundation
import UIKit

final class BeerListHeader: UICollectionReusableView {
    // MARK: - Properties
    private let sectionHeaderLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(for: .title1, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // MARK: - View Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        addSubview(sectionHeaderLabel)
        
        NSLayoutConstraint.activate([
            sectionHeaderLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            sectionHeaderLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            sectionHeaderLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            sectionHeaderLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Interface
    func configureHeader(with title: String?) {
        sectionHeaderLabel.text = title
    }
}
