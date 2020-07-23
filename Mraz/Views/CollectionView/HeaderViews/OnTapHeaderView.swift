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
        label.font = .preferredFont(for: .title2, weight: .bold)
        return label
    }()
    private var breweryDataView: BreweryDataView = {
        let view = BreweryDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        addSubview(breweryDataView)
        addSubview(onTapHeaderLabel)
        
        NSLayoutConstraint.activate([
            breweryDataView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            //breweryDataView.heightAnchor.constraint(equalToConstant: 50),
            breweryDataView.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor),
            breweryDataView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            
            onTapHeaderLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            onTapHeaderLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            onTapHeaderLabel.topAnchor.constraint(equalTo: breweryDataView.bottomAnchor),
            onTapHeaderLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Interface
    func configureHeader(with title: String?) {
        onTapHeaderLabel.text = title
    }
}
