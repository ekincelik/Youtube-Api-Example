//
//  ItemCollectionView.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 11.07.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import Foundation
import UIKit

open class ItemCollectionView: CollectionView<MediaItemCell, VideoItem> {
    public init(layout: UICollectionViewLayout, items: [VideoItem]) {
        super.init(itemArray: items, layout: layout) { cell, item, _ in
            cell.configure(item: item)
        }
        backgroundColor = UIColor.collectionViewBackgroundColor
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemAtIndexPath(indexPath)!
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        if let cell = cell as? MediaItemCell {
            cellConfigure(cell, item, indexPath)
        }
        return cell
    }
}
