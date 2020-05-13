//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

class BeerListViewController: UIViewController, CoreDataAPI, ReadFromCloudKit {
    // MARK: - Properties
    typealias Element = Beers
    typealias BeersSnapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias BeersDiffableDatasource = UICollectionViewDiffableDataSource<Section, Element>
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
            let inset = CGFloat(15)
            let isCompact = environment.container.effectiveContentSize.width < 450
            let columns = isCompact ? 1 : 2
            
            let section = NSCollectionLayoutSection
                .grid(itemHeight: .estimated(160), itemSpacing: inset, groupWidthDimension: 1.0, numberOfColumns: columns)
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
            cell.configureBeerCell(beerName: element.name, type: element.beerType, abv: element.abv, isFavorite: element.isFavorite, isOnTap: element.isOnTap)
            cell.setFavoriteStatus { cell.setFavorite(element) }
            
            // TO-DO: Properly set Cell color based on 'isOnTap' boolean val
//            cell.setOnTapCellColor(element: element)
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
        let controller = configureAllBeersFetchedResultsController(for: .beers, key: "name", searchText: currentSearchText, ascending: true)
        controller.delegate = self
        return controller
    }()
    private var currentSearchText = ""
    private var activityIndicator: UIActivityIndicatorView?
    private let refreshControl = UIRefreshControl()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Our Beers"
        setupView()
        createSnapshot()
        pullToRefresh()
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
//        stopActivityIndicator()
        refreshControl.endRefreshing()
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

//    // MARK: - Activity indicator methods
//    /// Create the activity indicator view and start animating.
//    private func startActivityIndicator() {
//        self.activityIndicator = UIActivityIndicatorView(style: .large)
//        self.activityIndicator?.center = self.view.center
//        self.activityIndicator?.color = .systemGray
//        self.activityIndicator?.startAnimating()
//    }
//
//    /// Stop animating the activity indicator.
//    private func stopActivityIndicator() {
//        if let activityIndicator = self.activityIndicator {
//            activityIndicator.stopAnimating()
//        }
//    }

    // MARK: - Refresh Methods
    private func pullToRefresh() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .systemGray
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray
        ]
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Beers", attributes: attributes)
    }
    
    @objc func refresh() {
        CloudKitManager.shared.fetchUpdatedRecordsFromCloud()
        refreshControl.endRefreshing()
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
        let beerInfoVC = BeerInfoViewController()
        beerInfoVC.objectID = selectedBeerObjectID
        let navController = UINavigationController(rootViewController: beerInfoVC)
        present(navController, animated: true, completion: nil)
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
        fetchedResultsController = configureAllBeersFetchedResultsController(for: .beers, key: "name", searchText: searchText, ascending: true)
        guard let beers = fetchedResultsController.fetchedObjects as? [Beers] else { return }
        updateSnapshot(with: beers)
    }
}
