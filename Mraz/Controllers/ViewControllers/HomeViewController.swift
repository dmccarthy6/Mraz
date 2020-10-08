//  Created by Dylan  on 5/2/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

import CoreData

final class HomeViewController: UIViewController {
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
                .grid(itemHeight: .estimated(200), itemSpacing: inset, groupWidthDimension: 1.0, numberOfColumns: columns)
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
        let onTapPredicate = NSPredicate(format: "isOnTap == %d", true)
        manager.frcPredicate = onTapPredicate
        let controller = manager.configureFetchedResultsController(for: .beers, key: "name", ascending: true)
        controller.delegate = self
        return controller
    }()
    private let manager = CoreDataManager.shared
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "What's On Tap"
<<<<<<< HEAD
<<<<<<< HEAD
        
        configureView()
        syncOnTapBeers()
=======
<<<<<<< Updated upstream
        setupView()
=======
        configureView()
        syncOnTapBeers()
>>>>>>> Stashed changes
>>>>>>> eb747e9dbd62572f5834cbaac5f70489824757f8
=======
        
        configureView()
        syncOnTapBeers()
>>>>>>> 9ebc40cf2474a42d9adc9be1aee45bbe317d507c
        createSnapshot()
    }
    
    // MARK: -
    /// Fetch beers currently on tap.
    private func syncOnTapBeers() {
        SyncCloudKitChanges.shared.performOnTapSyncOperation()
    }
    
    // MARK: - Configure
    private func configureView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Snapshot
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
        self.openBeerInfoVC(from: selectedID)
    }
}

// MARK: - NSFetchedResultsController Delegate
extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let beers = onTapResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: beers)
    }
}
