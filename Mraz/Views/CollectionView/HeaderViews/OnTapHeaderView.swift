//  Created by Dylan  on 5/8/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class OnTapHeaderView: UICollectionReusableView {
    // MARK: - Properties
    private var breweryDataView: BreweryDataView = {
        let view = BreweryDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupHeader() {
        addSubview(breweryDataView)
        
        NSLayoutConstraint.activate([
            breweryDataView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            breweryDataView.heightAnchor.constraint(equalToConstant: 50),
            breweryDataView.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor),
            breweryDataView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        ])
        breweryDataView.setContactButtonActions()
    }
}
