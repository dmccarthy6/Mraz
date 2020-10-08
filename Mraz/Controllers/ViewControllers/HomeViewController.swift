//  Created by Dylan  on 5/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

import CoreData

final class HomeViewController: UIViewController, CoreDataAPI, ReadFromCloudKit {
    // MARK: - Types
    enum Section: CaseIterable {
        case onTap
    }
    // MARK: - Properties
    typealias Element = Beers
    typealias OnTapSnapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias OnTapDatasource = UICollectionViewDiffableDataSource<Section, Element>
    private var breweryInfoView: BreweryDataView = {
        let view = BreweryDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
     private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
            let inset = CGFloat(10)
            let isCompact = environment.container.effectiveContentSize.width < 450
            let columns = isCompact ? 2 : 2
            
            let section = NSCollectionLayoutSection
                .grid(itemHeight: .estimated(200), itemSpacing: inset, groupWidthDimension: 1.0, numberOfColumns: columns)//.absolute(375)
                .withSectionHeader(estimatedHeight: 50, kind: OnTapHeaderView.viewReuseIdentifier)
                .withContentInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            return section
        }
        
        return layout
    }()
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.registerCell(cellClass: OnTapCell.self)
        collectionView.registerSupplementaryView(viewClass: OnTapHeaderView.self)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    private lazy var onTapDiffDatasource: OnTapDatasource = {
        /// Cell
        let diffDatasource = OnTapDatasource(collectionView: collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            let cell: OnTapCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureOnTapCell(name: element.name, type: element.beerType, beerABV: element.abv)
            return cell
        }
        /// Header
        diffDatasource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            let staticHeader: OnTapHeaderView = collectionView.dequeueReusableView(indexPath: indexPath)
            return staticHeader
        }
        return diffDatasource
    }()
    private lazy var onTapResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let controller = configureOnTapFetchedResultsController(for: .beers)
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "What's On Tap"
<<<<<<< Updated upstream
        setupView()
=======
        configureView()
        syncOnTapBeers()
>>>>>>> Stashed changes
        createSnapshot()
    }
    
    // MARK: -
    private func setupView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createSnapshot() {
        guard let onTap = onTapResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: onTap)
    }
    
    private func updateSnapshot(with datasource: [Beers], animated: Bool = true) {
        var snapshot = OnTapSnapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(datasource)
        onTapDiffDatasource.apply(snapshot, animatingDifferences: animated)
    }
}
// MARK: - CollectionView Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedBeer = onTapDiffDatasource.itemIdentifier(for: indexPath) else { return }
        let selectedID = selectedBeer.objectID
        let beerInfoVC = BeerInfoViewController()
        beerInfoVC.objectID = selectedID
        let navController = UINavigationController(rootViewController: beerInfoVC)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - NSFetchedResultsController Delegate
extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let beers = onTapResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: beers)
    }
}
