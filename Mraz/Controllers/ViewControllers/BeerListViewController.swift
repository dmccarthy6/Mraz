//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

class BeerListViewController: UIViewController {
    // MARK: - Properties
    typealias Element = Beers
    typealias BeersSnapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias BeersDiffableDatasource = UICollectionViewDiffableDataSource<Section, Element>
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
            let inset = CGFloat(10)
            let isCompact = environment.container.effectiveContentSize.width < 450
            let columns = isCompact ? 1 : 2
            
            let section = NSCollectionLayoutSection
                .grid(itemHeight: .estimated(85), itemSpacing: inset, groupWidthDimension: 1.0, numberOfColumns: columns)
                .withSectionHeader(estimatedHeight: 40, kind: BeerListHeader.viewReuseIdentifier)
                .withContentInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            return section
        }
        return layout
    }()
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.registerCell(cellClass: BeerListCell.self)
        collectionView.registerSupplementaryView(viewClass: BeerListHeader.self)
        return collectionView
    }()
    private lazy var beersDiffableDatasource: BeersDiffableDatasource = {
        /// Set Up CollectionView Cells
        let diffableDatasource = BeersDiffableDatasource(collectionView: collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            let cell: BeerListCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureBeerCell(beerName: element.name, type: element.beerType, abv: element.abv, isFavorite: element.isFavorite)
            cell.makeBeerFavorite = { [weak self] in
                cell.configureFavoritesButton(forElement: element)
                let beerCurrentStatus = element.isFavorite
                element.isFavorite = !beerCurrentStatus
                self?.coreDataManager.updateLocalFavoriteStatus(element)
            }
            return cell
        }
        /// Configure section headers
        diffableDatasource.supplementaryViewProvider = {
            collectionView, kind, indexPath -> UICollectionReusableView? in
            let section = diffableDatasource.snapshot().sectionIdentifiers[indexPath.section]
            let header: BeerListHeader = collectionView.dequeueReusableView(indexPath: indexPath)
            header.configureHeader(with: section.title )
            return header
        }
        return diffableDatasource
    }()
    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        coreDataManager.frcPredicate = NSPredicate(value: true)
        let controller = coreDataManager.configureFetchedResultsController(for: .beers, key: "name", searchText: currentSearchText, ascending: true)
        controller.delegate = self
        return controller
    }()
    lazy var coreDataManager = CoreDataManager.shared
    private var currentSearchText = ""
    private var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Our Beers"
        setupView()
        createSnapshot()
        setupSearchController()
    }
    
    // MARK: - Snapshot
    func deleteAllItemsFromSnapshot() {
        var snapshot = beersDiffableDatasource.snapshot()
        snapshot.deleteAllItems()
    }
    
    /// Create the snapshot using the FetchedResultsController as datasource.
    private func createSnapshot() {
        guard let beers = fetchedResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: beers)
    }
    
    ///
    private func updateSnapshot(with datasource: [Beers], animate: Bool = true) {
        var snapshot = BeersSnapshot()
        snapshot.appendSections(Section.allCases)
        
        for section in snapshot.sectionIdentifiers {
            let items = datasource.filter({ $0.section == section.title })
            snapshot.appendItems(items, toSection: section)
        }
        beersDiffableDatasource.apply(snapshot, animatingDifferences: animate)
    }

    // MARK: - Helpers
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Search
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Beers"
        navigationItem.searchController = searchController
    }
}
//
extension BeerListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let beerItem = self.beersDiffableDatasource.itemIdentifier(for: indexPath) else { return }
        let selectedBeerObjectID = beerItem.objectID
        self.openBeerInfoVC(from: selectedBeerObjectID)
    }
}

// MARK: - Fetched Results Controller Delegate
extension BeerListViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let updatedBeers = fetchedResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: updatedBeers)
    }
}

// MARK: - UISearch Controller
extension BeerListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        currentSearchText = searchText
        
        let searchTextPredicate = NSPredicate(format: "name CONTAINS[c] %@", currentSearchText)
        let manager = CoreDataManager(predicate: searchTextPredicate)
        let controller = manager.configureFetchedResultsController(for: .beers, key: "name", searchText: searchText, ascending: true)
        fetchedResultsController = controller
        guard let beers = fetchedResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: beers)
    }
}
