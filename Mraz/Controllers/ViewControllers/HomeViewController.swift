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
    private lazy var onTapResultsController: NSFetchedResultsController<Beers> = {
        let onTapPredicate = NSPredicate(format: "isOnTap == %d", true)
        let controller = MrazFetchResultsController.configureMrazFetchedResultsController(for: .beers, matching: onTapPredicate, in: manager.mainContext)
        controller.delegate = self
        return controller
    }()
    private var manager = CoreDataManager()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "What's On Tap"

        configureView()
//        syncOnTapBeers()
        createSnapshot()
    }
    
    // MARK: -
    #warning("TODO - Fix SyncCloudKitChanges then re implement this (pull to refresh)")
    /// Fetch beers currently on tap.
//    private func syncOnTapBeers() {
//        let ckSync = SyncCloudKitChanges(databaseManager: databaseManager, cloudKitManager: CloudKitManager())
//        ckSync.performOnTapSyncOperation()
//    }
    
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
        guard let onTap = onTapResultsController.fetchedObjects else { return }
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
        self.openBeerInfoVC(from: selectedID, context: self.manager.mainContext)
    }
}

// MARK: - NSFetchedResultsController Delegate
extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let beers = onTapResultsController.fetchedObjects else { return }
        updateSnapshot(with: beers)
    }
}
