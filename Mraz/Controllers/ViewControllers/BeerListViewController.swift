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
                guard let self = self else { return }
                cell.configureFavoritesButton(forElement: element)
                let beerCurrentStatus = element.isFavorite
                element.isFavorite = !beerCurrentStatus
                self.manager.update(beer: element)
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
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Beers> = {
        let controller = MrazFetchResultsController.configureMrazFetchedResultsController(for: .beers,
                                                                                    matching: NSPredicate(value: true),
                                                                                    in: manager.mainContext)
        controller.delegate = self
        return controller
    }()
    
    let manager = CoreDataManager()
    private let beersRefresh = UIRefreshControl()
    private var currentSearchText = ""
    private var activityIndicator: UIActivityIndicatorView?
    private var favoritesShowing: Bool = false
    private var currentlySearching: Bool = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureView()
        createSnapshot()
        setupSearchController()
        refresh()
    }
    
    // MARK: - Configure View
    private func configureView() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setUpNavigation()
    }
    
    private func setUpNavigation() {
        navigationItem.title = "Our Beers"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: SystemImages.starFilledImage,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showFavorites))
    }
    
    // MARK: - Snapshot
    /// Create the snapshot using the FetchedResultsController as datasource.
    private func createSnapshot() {
        guard let beers = fetchedResultsController.fetchedObjects else { return }
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
    
    private func updateSnapshotWithFilterData(with beers: [Beers], animate: Bool = true) {
        var snapshot = BeersSnapshot()
        snapshot.appendSections([Section.filter])
        snapshot.appendItems(beers)
        beersDiffableDatasource.apply(snapshot)
    }

    // MARK: - Filtering
    func filterResults(matching predicate: NSPredicate, value: Bool) {
        let controller = MrazFetchResultsController.configureMrazFetchedResultsController(for: .beers, matching: predicate, in: self.manager.mainContext, key: "name", ascending: value)
        fetchedResultsController = controller
        guard let beers = fetchedResultsController.fetchedObjects else { return }
        value ? updateSnapshotWithFilterData(with: beers) : updateSnapshot(with: beers)
    }
    
    /// Button function to filter Core Data by favorite beers and update snapshot.
    @objc private func showFavorites() {
        favoritesShowing = !favoritesShowing
        let showFavorites = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        let showAll = NSPredicate(value: true)
        let favPredicate = favoritesShowing ?  showFavorites : showAll
        filterResults(matching: favPredicate, value: favoritesShowing)
    }
    
    // MARK: - Search
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Beers"
        navigationItem.searchController = searchController
    }
    
    // MARK: - Refresh
    func refresh() {
        collectionView.refreshControl = beersRefresh
        beersRefresh.addTarget(self, action: #selector(refreshAllBeers), for: .valueChanged)
    }
    
    @objc func refreshAllBeers() {
        guard let lastFetch = MrazSettings().readLastSyncDate() else {
            beersRefresh.endRefreshing()
            return
        }
        let cdPred = NSPredicate(format: "ckModifiedDate > %@", lastFetch as CVarArg)
        let ckPred = NSPredicate(format: "Modified > %@", lastFetch as CVarArg)
        let sync = SyncBeers(coreDataPredicate: cdPred, cloudKitPredicate: ckPred, syncType: .allBeers)
        sync.performSync()
        beersRefresh.endRefreshing()
    }
}

// MARK: - UICollectionView Delegate
extension BeerListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let beerItem = self.beersDiffableDatasource.itemIdentifier(for: indexPath) else { return }
        let selectedBeerObjectID = beerItem.objectID
        self.openBeerInfoVC(from: selectedBeerObjectID, context: self.manager.mainContext)
    }
}

// MARK: - Fetched Results Controller Delegate
extension BeerListViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let updatedBeers = fetchedResultsController.fetchedObjects else { return }
        updateSnapshot(with: updatedBeers)
    }
}

// MARK: - UISearch Controller
extension BeerListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        currentSearchText = searchText
        
        let searchTextCleared = searchText == ""
        let searchPredicate = searchTextCleared ? NSPredicate(value: true) : NSPredicate(format: "name CONTAINS[c] %@", currentSearchText)
        filterResults(matching: searchPredicate, value: !searchTextCleared)
    }
}
