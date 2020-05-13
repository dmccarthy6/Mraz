//  Created by Dylan  on 4/24/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

extension NSCollectionLayoutSection {
    
    /*
     The list group
     */
    static func list(estimatedHeight: CGFloat, itemSpacing: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        group.interItemSpacing = .fixed(itemSpacing)
        return section
    }
    
    /*
     Grid Layout
     */
    static func grid(itemHeight: NSCollectionLayoutDimension, itemSpacing: CGFloat, groupWidthDimension: CGFloat, numberOfColumns: Int) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupWidthDimension), heightDimension: itemHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfColumns)
        
        group.interItemSpacing = .fixed(itemSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = itemSpacing
        
        return section
    }
    
    /*
     
     */
    @discardableResult
    func withSectionHeader(estimatedHeight: CGFloat, kind: String) -> NSCollectionLayoutSection {
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .estimated(estimatedHeight))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: kind, alignment: .top)
        self.boundarySupplementaryItems = [sectionHeader]
        return self
    }
    
    @discardableResult
    func withContentInsets(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> NSCollectionLayoutSection {
        self.contentInsets = NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        return self
    }
}
