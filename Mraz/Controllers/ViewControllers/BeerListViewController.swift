//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit
import CoreData

class BeerListViewController: UIViewController, CoreDataAPI {
    //MARK: - Properties
    typealias Element = Beers
    typealias BeersSnapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias BeersDiffableDatasource = UICollectionViewDiffableDataSource<Section, Element>
    private let defaults = UserDefaults.standard

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.registerCell(cellClass: BeerListCell.self)
        collectionView.registerSupplementaryView(viewClass: BeerListHeader.self)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout {
            section, environment -> NSCollectionLayoutSection in
            
            let inset = CGFloat(16)
            let isCompact = environment.container.effectiveContentSize.width < 450
            let columns = isCompact ? 2 : 4
            
            let section = NSCollectionLayoutSection
                .list(estimatedHeight: 200)
                .withSectionHeader(estimatedHeight: 65, kind: BeerListHeader.viewReuseIdentifier)
                .withContentInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            return section
        }
        return layout
    }()
    private lazy var beersDiffableDatasource: BeersDiffableDatasource = {
        /// Set Up CollectionView Cells
        let diffableDatasource = BeersDiffableDatasource(collectionView: collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            let cell: BeerListCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configureBeerCell(beerName: element.name ?? "NIL", type: element.beerType, abv: element.abv ?? "0.0", isFavorite: element.isFavorite, isOnTap: element.isOnTap)
            return cell
        }
        return diffableDatasource
    }()
    private var dataSource = [Beers]()
    private var activityIndicator: UIActivityIndicatorView?
    private let refreshControl = UIRefreshControl()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
//        deleteAllItemsFromSnapshot()
        
        setupView()
        setDel()
        PresentAgeVerificationView(viewController: self)
        setupDatasource()
        pullToRefresh()
    }
    
    func deleteAllItemsFromSnapshot() {
        var snapshot = BeersSnapshot()
        snapshot.deleteAllItems()
    }
    
    //MARK: - Build Snapshot
    
    /// Set the snapshot
    private func setupDatasource() {
        startActivityIndicator()
        CloudKitManager.shared.fetchBeerListFromCloud { [unowned self] (result) in
            switch result {
            case .success(let beersArray):
                DispatchQueue.main.async {
                    self.dataSource = beersArray
                    let snapShot = self.buildSnapshot(with: self.dataSource)
                    self.beersDiffableDatasource.apply(snapShot)
                    self.stopActivityIndicator()
                    self.refreshControl.endRefreshing()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                }
                print("There was an error with CK: \(error)")
            }
        }
    }
    
    /// Create the snapshot
    private func buildSnapshot(with dataSource: [Beers]) -> BeersSnapshot {
        var snapShot = BeersSnapshot()
        snapShot.appendSections([.Ale, .Amber, .Belgian, .Blonde, .IPA, .Lager, .Mosaic, .Porter, .Saison, .Sour])
        
        for section in snapShot.sectionIdentifiers {
            let items = dataSource.filter({ $0.section == section.title })
            snapShot.appendItems(items, toSection: section)
            
            /// Configure section headers
            beersDiffableDatasource.supplementaryViewProvider = { [weak self]
                collectionView, kind, indexPath -> UICollectionReusableView? in
                let section = self?.beersDiffableDatasource.snapshot().sectionIdentifiers[indexPath.section]
                let header: BeerListHeader = collectionView.dequeueReusableView(indexPath: indexPath)
                print("BeersListVC - This is title: \(section?.title)")
                header.configureHeader(with: section?.title)
                return header
            }
        }
        return snapShot
    }
    
    private func updateSnapshot() {
        var updatedSnapshot = BeersSnapshot()
        updatedSnapshot.appendSections([.Ale, .Amber, .Belgian, .Blonde, .IPA, .Lager, .Mosaic, .Porter, .Saison, .Sour])
        
        for section in updatedSnapshot.sectionIdentifiers {
            let objects = fetchedResultsController.fetchedObjects as! [Beers]
            let items = objects.filter({ $0.section == section.title })
            updatedSnapshot.appendItems(items, toSection: section)
//        updatedSnapshot.appendItems(fetchedResultsController.fetchedObjects as? [Beers] ?? [])
        beersDiffableDatasource.apply(updatedSnapshot)
            refreshControl.endRefreshing()
        }
    }
    
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
    
    
    //MARK: - Activity indicator methods
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
        
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.systemGray
        ]
        refreshControl.attributedTitle = NSAttributedString(string: "Updating Beers", attributes: attributes)
    }
    
    @objc func refresh() {
        updateSnapshot()
    }
    
    private func setDel() {
        let controller = fetchedResultsController
        controller.delegate = self
    }
    
    //Check CK STATUS
    
}

extension BeerListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        updateSnapshot()
    }
}


