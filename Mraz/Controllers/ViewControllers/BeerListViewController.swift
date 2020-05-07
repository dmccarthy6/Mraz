//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

class BeerListViewController: UIViewController, CoreDataAPI, ReadFromCloudKit, CloudKitRecordsChangedDelegate {
    // MARK: - Properties
    typealias Element = Beers
    typealias BeersSnapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias BeersDiffableDatasource = UICollectionViewDiffableDataSource<Section, Element>
    private let defaults = UserDefaults.standard

    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
            
            let inset = CGFloat(16)
            let isCompact = environment.container.effectiveContentSize.width < 450
            let columns = isCompact ? 2 : 4
            
            let section = NSCollectionLayoutSection
                .list(estimatedHeight: 150)
                .withSectionHeader(estimatedHeight: 65, kind: BeerListHeader.viewReuseIdentifier)
                .withContentInsets(leading: inset, bottom: inset, trailing: inset)
            return section
        }
        return layout
    }()
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.registerCell(cellClass: BeerListCell.self)
        collectionView.registerSupplementaryView(viewClass: BeerListHeader.self)
        return collectionView
    }()
    private lazy var beersDiffableDatasource: BeersDiffableDatasource = {
        /// Set Up CollectionView Cells
        let diffableDatasource = BeersDiffableDatasource(collectionView: collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            let cell: BeerListCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureBeerCell(beerName: element.name ?? "NIL", type: element.beerType, abv: element.abv ?? "0.0", isFavorite: element.isFavorite, isOnTap: element.isOnTap)
            cell.setFavoriteStatus { cell.setFavorite(element) }
            
            // TO-DO: Properly set Cell color based on 'isOnTap' boolean val
            cell.setOnTapCellColor(element: element)
            return cell
        }
        /// Configure section headers
        diffableDatasource.supplementaryViewProvider = { [weak self]
            collectionView, kind, indexPath -> UICollectionReusableView? in
            let section = diffableDatasource.snapshot().sectionIdentifiers[indexPath.section]
            let header: BeerListHeader = collectionView.dequeueReusableView(indexPath: indexPath)
            header.configureHeader(with: "title" )//section?.title
            return header
        }
        return diffableDatasource
    }()
    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let controller = configureFetchedResultsController(for: .beers, key: "name", searchText: currentSearchText, ascending: true)
        controller.delegate = self
        return controller
    }()
    private var currentSearchText = ""
    private var dataSource = [Beers]()
    private var activityIndicator: UIActivityIndicatorView?
    private let refreshControl = UIRefreshControl()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupView()
        setDatasource()
        pullToRefresh()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startActivityIndicator()
    }
    
    // MARK: - Snapshot
    func deleteAllItemsFromSnapshot() {
        var snapshot = BeersSnapshot()
        snapshot.deleteAllItems()
    }
    
    /// Create the snapshot
    private func buildSnapshot(with dataSource: [Beers]) -> BeersSnapshot {
        var snapShot = BeersSnapshot()
        snapShot.appendSections([.ale, .amber, .belgian, .blonde, .ipa, .lager, .mosaic, .porter, .saison, .sour])
        
        for section in snapShot.sectionIdentifiers {
            let items = dataSource.filter({ $0.section == section.title })
            snapShot.appendItems(items, toSection: section)
        }
        return snapShot
    }
    
    /// Update Snapshot
    private func updateSnapshot() {
        var updatedSnapshot = BeersSnapshot()
        updatedSnapshot.appendSections([.ale, .amber, .belgian, .blonde, .ipa, .lager, .mosaic, .porter, .saison, .sour])

        for section in updatedSnapshot.sectionIdentifiers {
            guard let objects = fetchedResultsController.fetchedObjects as? [Beers] else { return }
            let items = objects.filter({ $0.section == section.title })
            updatedSnapshot.appendItems(items, toSection: section)
            beersDiffableDatasource.apply(updatedSnapshot)
            refreshControl.endRefreshing()
        }
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
    
    /// Use the fetchedResultsController to set the diffable data source.
    func setDatasource() {
        let fetchedObjects = fetchedResultsController.fetchedObjects as? [Beers]
        guard let beers = fetchedObjects else {
            return
        }
        let snapshot = buildSnapshot(with: beers)
        beersDiffableDatasource.apply(snapshot)
        stopActivityIndicator()
    }
 
    // MARK: - Activity indicator methods
    /// Initializer the activity indicator view
    private func startActivityIndicator() {
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        self.activityIndicator?.center = self.view.center
        self.activityIndicator?.color = .systemGray
        self.activityIndicator?.startAnimating()
    }
    
    /// Stop the activity indicator
    private func stopActivityIndicator() {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.stopAnimating()
        }
    }
    
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
        updateSnapshot()
    }
    
    // MARK: - Search
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Beers"
        navigationItem.searchController = searchController
    }
    
    // MARK: - Delegate
    func notificationReceived(_ notification: CKDatabaseNotification) {
        CloudKitManager.shared.performCloudKitFetch(date: <#T##Date?#>, <#T##completion: (Result<Bool, Error>) -> Void##(Result<Bool, Error>) -> Void#>)
    }
}

extension BeerListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        
        for change in diff {
            switch change {
            case .insert(offset: let newPosition, element: let element, associatedWith: let oldPosition):
                if let oldPosition = oldPosition {
                    if oldPosition == newPosition {
                        // Object Updated
                        return
                    }
                    // Objct Moved
                    let beer = dataSource.remove(at: oldPosition)
                    dataSource.insert(beer, at: newPosition)
                } else {
                    // Object Added
                    guard let beerObj = fetchedResultsController.object(at: IndexPath(item: newPosition, section: 0)) as? Beers else {
                        return
                    }
                    dataSource.insert(beerObj, at: newPosition)
                }
                
            case .remove(offset: let offset, element: let element, associatedWith: let associatedWith):
                if associatedWith == nil {
                    _ = dataSource.remove(at: offset)
                }
            }
        }
    }
}

extension BeerListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        //Do something with text
        currentSearchText = searchText
        //Call FRC with current search text in it?
        print(searchText)
    }
}
