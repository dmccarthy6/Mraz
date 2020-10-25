//  Created by Dylan  on 10/22/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

@available(iOS 14.0, *)
final class SideBarViewController: UIViewController {
    enum SideBarSection: CaseIterable {
        case all
    }
    
    // MARK: - Properties
    typealias Element = TabsViewModel
    typealias SideBarSnapshot = NSDiffableDataSourceSnapshot<SideBarSection, Element>
    typealias SideBarDatasource = UICollectionViewDiffableDataSource<SideBarSection, Element>
    private var breweryInfoView: BreweryDataView = {
        let view = BreweryDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
            let new = environment
            let section = NSCollectionLayoutSection.list(using: .init(appearance: .sidebar), layoutEnvironment: environment)
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
    
    private lazy var sideBarDiffableDatasource: SideBarDatasource = {
        /// Cell
        let diffDatasource = SideBarDatasource(collectionView: collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.configuredSideBarCell(), for: indexPath, item: element)
            return cell
        }
        return diffDatasource
    }()
    
    private lazy var secondaryVCs = [
        UINavigationController(rootViewController: HomeViewController(cloudKitManager: cloudKitManager, coreDataManager: coreDataManager)),
        UINavigationController(rootViewController: BeerListViewController()),
        UINavigationController(rootViewController: MapViewController())
    ]
    var coreDataManager: CoreDataManager
    var cloudKitManager: CloudKitManager
    
    // MARK: - Lifecycle
    init(coreDataManager: CoreDataManager, cloudKitManager: CloudKitManager) {
        self.coreDataManager = coreDataManager
        self.cloudKitManager = cloudKitManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        applySnapshot(with: Element.allCases)
        setInitialSecondaryView()
    }
    
    // MARK: - View
    func configureView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        configureNavigationController()
    }
    
    func configureNavigationController() {
        navigationItem.title = "Mraz"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Snapshot
    private func applySnapshot(with datasource: [TabsViewModel], animated: Bool = true) {
        var snapshot = SideBarSnapshot()
        
        snapshot.appendSections(SideBarSection.allCases)
        snapshot.appendItems(datasource)
        
        sideBarDiffableDatasource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Split View Controller Methods
    private func setInitialSecondaryView() {
        // Select the first item in the list (on Tap here)
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredVertically)
        splitViewController?.setViewController(secondaryVCs[0], for: .secondary)
    }
    
    // Create and configure the List Cell
    private func configuredSideBarCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, TabsViewModel> {
        UICollectionView.CellRegistration<UICollectionViewListCell, TabsViewModel> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.icon
            content.imageProperties.tintColor = .white
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
    }
}

@available(iOS 14.0, *)
extension SideBarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        splitViewController?.setViewController(secondaryVCs[indexPath.row], for: .secondary)
        splitViewController?.hide(.primary)
    }
}
