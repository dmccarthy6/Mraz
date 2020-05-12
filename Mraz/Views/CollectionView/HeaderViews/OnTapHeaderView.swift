//  Created by Dylan  on 5/8/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class OnTapHeaderView: UICollectionReusableView {
    // MARK: - Properties
    private var onTapHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .preferredFont(for: .title1, weight: .bold)
        return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupHeader() {
        addSubview(onTapHeaderLabel)
        
        NSLayoutConstraint.activate([
            onTapHeaderLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            onTapHeaderLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            onTapHeaderLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            onTapHeaderLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Interface
    func configureHeader(with title: String?) {
        onTapHeaderLabel.text = title
    }
}
