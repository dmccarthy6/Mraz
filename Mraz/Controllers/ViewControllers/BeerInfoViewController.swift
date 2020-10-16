//  Created by Dylan  on 5/12/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

final class BeerInfoViewController: UIViewController {
    // MARK: - Properties
    private var beerInfoView: BeerInfoView = {
        let view = BeerInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var objectID: NSManagedObjectID?
    var context: NSManagedObjectContext
    
    // MARK: - Life Cycle
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        configureBeerInfoView()
    }
    
    // MARK: - Layout
    private func setupView() {
        view.addSubview(beerInfoView)
        
        NSLayoutConstraint.activate([
            beerInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            beerInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            beerInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            beerInfoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    /// Configure the navigation bar for this screen.
    private func setupNavigation(with title: String?) {
        navigationItem.title = title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissVC))
    }
    
    private func configureBeerInfoView() {
        
        guard let safeObjectID = objectID else { return }
        let managedObjectIDPredicate = NSPredicate(format: "objectID == %@", safeObjectID)
        guard let safeBeerObject = Beers.findOrFetch(in: context, matching: managedObjectIDPredicate) else { return }
        beerInfoView.createBeerInfoView(title: safeBeerObject.name, type: safeBeerObject.beerType, abv: safeBeerObject.abv, description: safeBeerObject.beerDescription)
        setupNavigation(with: safeBeerObject.name ?? "")
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
