//
//  CollectionView.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 11.07.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import Foundation
import UIKit

open class CollectionView<Cell: UICollectionViewCell, VideoItem>: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public typealias configureCellClosure = (Cell, VideoItem, IndexPath) -> Void
    open var didSelectAction: ((IndexPath) -> Void)?
    open var didDeselectAction: ((IndexPath) -> Void)?
    open var itemArray: [VideoItem]
    open var cellReuseIdentifier: String
    open var cellConfigure: configureCellClosure
    public var checkShouldLoadNextPageCalled: (() -> Void)?

    public var loadedCount: Int {
        itemArray.count
    }

    public init(itemArray: [VideoItem] = [], layout: UICollectionViewLayout, cellReuseIdentifier: String = "VideoItemCell", cellConfig: @escaping (Cell, VideoItem, IndexPath) -> Void) {
        self.itemArray = itemArray
        self.cellReuseIdentifier = cellReuseIdentifier
        cellConfigure = cellConfig

        super.init(frame: .zero, collectionViewLayout: layout)
        registerClass(Cell.self)
        backgroundColor = UIColor.collectionViewBackgroundColor
        delegate = self
        dataSource = self
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func registerClass(_ cellType: AnyClass) {
        register(cellType, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    open func itemAtIndexPath(_ indexPath: IndexPath) -> VideoItem? {
        return itemArray[indexPath.row]
    }

    // MARK: UICollectionViewDelegateFlowLayout

    open func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectAction?(indexPath)
    }

    open func collectionView(_: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectAction?(indexPath)
    }

    // MARK: UICollectionViewDataSource

    open func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return itemArray.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        return cell
    }

    open func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: frame.size.width, height: 100)
    }

    open func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt _: IndexPath) {
        checkShouldLoadNextPage()
    }

    public func checkShouldLoadNextPage() {
        guard let lastIndexPath = indexPathsForVisibleItems.sorted(by: { $0.row < $1.row }).last, lastIndexPath.row >= self.loadedCount - 1 else { return }
        checkShouldLoadNextPageCalled?()
    }
}

public extension CollectionView {
    func reload(_ items: [VideoItem]) {
        itemArray = items
        reloadData()
    }
}
