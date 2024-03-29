//
//  UserPlaylistViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 01/06/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import RealmSwift
import UIKit

enum CellModel {
    case simple(videoSearch: VideoItem)
    case availableToDropAtEnd
}

class UserPlaylistViewController: BaseTabbarViewController {
    private lazy var sections = 1

    private lazy var data: [[CellModel]] = [[]]

    var itemList: [VideoItem] = [] {
        didSet {
            data = {
                var count = -1
                return (0 ..< sections).map { _ in
                    (0 ..< itemList.count).map { _ -> CellModel in
                        count += 1
                        return .simple(videoSearch: itemList[count])
                    }
                }
            }()
        }
    }

    var localPlaylistIdString: Int
    var localPlaylistTitle: String
    var editingEnabled: Bool = false
    var currentEditingType: CellEditingType = .none
    lazy var itemListWrapper: UIView = {
        let view = UIView()
        return view
    }()

    /// The list view
    fileprivate var mediaItemCollectionView: ItemCollectionView?

    private var selectedIndexes = Set<IndexPath>()

    init(localPlaylistIdString: Int, title: String) {
        localPlaylistTitle = title
        self.localPlaylistIdString = localPlaylistIdString
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        editingEnabled = false
        customNavBar.doneEditButton()
        updateCells(editEnabled: false, editType: .none)
        mediaItemCollectionView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEditButton()
        customNavBar.searchButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let listView = mediaItemCollectionView {
            itemList = RealmManager.shared.getPlaylistItems(playlistId: localPlaylistIdString)
            listView.reload(itemList)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setNeedsStatusBarAppearanceUpdate()
        setNavigationTitle(title: localPlaylistTitle)
        itemList = RealmManager.shared.getPlaylistItems(playlistId: localPlaylistIdString)
        configureCollectionViewList(responseArray: itemList)
        customNavBarSetup()
    }

    private func customNavBarSetup() {
        customNavBar.editButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.editingEnabled = !self.editingEnabled
            if self.editingEnabled {
                self.customNavBar.editButton.setTitle("Done", for: .normal)
                self.customNavBar.showEditButton()
                self.displayEditOptions()
            } else {
                self.customNavBar.editButton.setTitle("Edit", for: .normal)
                self.customNavBar.doneEditButton()
                self.selectedIndexes = []
                self.mediaItemCollectionView?.dragInteractionEnabled = false
                self.updateCells(editEnabled: false)
            }
        }

        customNavBar.removeButtonTapped = { [weak self] in
            guard let self = self else { return }
            guard !self.selectedIndexes.isEmpty,!self.itemList.isEmpty else { return }
            let removeItems = self.selectedIndexes.map { self.itemList[$0.item] }
            RealmManager.shared.removeVideoDataFromPlaylist(playlistID: self.localPlaylistIdString, searchDataArray: removeItems)
            self.selectedIndexes = []
            self.loadData()
        }
    }

    func updateCells(editEnabled _: Bool, editType: CellEditingType = .none) {
        currentEditingType = editType
        mediaItemCollectionView?.cellConfigure = { cell, item, _ in
            cell.configureCell(
                item: item,
                allowSelection: self.editingEnabled,
                editType: editType
            )
        }
        mediaItemCollectionView?.reloadData()
    }

    func displayEditOptions() {
        let alert = UIAlertController(title: "Edit Options", message: "", preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "Reorder List", style: UIAlertAction.Style.default) { _ in
            self.mediaItemCollectionView?.dragInteractionEnabled = true
            self.updateCells(editEnabled: true, editType: .reorderMode)
        }
        let addPlaylist = UIAlertAction(title: "Remove Item From List", style: UIAlertAction.Style.default) { _ in
            self.updateCells(editEnabled: true, editType: .deleteMode)
        }
        let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in
            self.editingEnabled = false
            self.mediaItemCollectionView?.dragInteractionEnabled = false
            self.customNavBar.editButton.setTitle("Edit", for: .normal)
            self.customNavBar.doneEditButton()
            self.selectedIndexes = []
        }
        alert.addAction(shareAction)
        alert.addAction(addPlaylist)
        alert.addAction(alertAction)
        NavigationManager.shared.rootVC()?.present(alert, animated: true)
    }

    private func loadData(isReOrder: Bool = false) {
        itemList = RealmManager.shared.getPlaylistItems(playlistId: localPlaylistIdString)
        if !isReOrder {
            editingEnabled = false
            customNavBar.editButton.setTitle("Edit", for: .normal)
            customNavBar.doneEditButton()
            mediaItemCollectionView?.cellConfigure = { cell, item, _ in
                cell.configureCell(
                    item: item,
                    allowSelection: self.editingEnabled,
                    editType: .none
                )
            }
        }
        mediaItemCollectionView?.reload(itemList)
        mediaItemCollectionView?.reloadData()
        selectedIndexes = []
    }

    private func configureCollectionViewList(responseArray: [VideoItem]) {
        itemListWrapper.backgroundColor = UIColor.backgroundColor
        view.addSubview(itemListWrapper)
        itemListWrapper.easy.layout(
            Top(navBarHeightAnchor).to(view.safeAreaLayoutGuide, .top),
            Left(),
            Right(),
            Bottom()
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        mediaItemCollectionView = ItemCollectionView(layout: layout, items: responseArray)
        guard let mediaItemCollectionView = mediaItemCollectionView else { return }
        mediaItemCollectionView.allowsMultipleSelection = true
        mediaItemCollectionView.registerClass(MediaItemCell.self)
        mediaItemCollectionView.indicatorStyle = .white
        itemListWrapper.addSubview(mediaItemCollectionView)
        mediaItemCollectionView.easy.layout(
            Left(5),
            Right(5),
            Top(5),
            Bottom(5)
        )
        mediaItemCollectionView.didSelectAction = { indexPath in
            self.didSelectAction(indexPath: indexPath)
        }
        mediaItemCollectionView.didDeselectAction = { [weak self] indexPath in
            guard let self = self else { return }
            guard self.editingEnabled, currentEditingType == .deleteMode else { return }
            self.selectedIndexes.remove(indexPath)
            self.updateRemoveButtonView()
        }
        mediaItemCollectionView.dropDelegate = self
        mediaItemCollectionView.dragDelegate = self
    }

    func updateRemoveButtonView() {
        selectedIndexes.isEmpty ? customNavBar.hideRemoveButtonEnabled() : customNavBar.showRemoveButtonEnabled()
    }
}

extension UserPlaylistViewController {
    func didSelectAction(indexPath: IndexPath) {
        if itemList.count > indexPath.row {
            if editingEnabled {
                if currentEditingType == .deleteMode {
                    selectedIndexes.insert(indexPath)
                    updateRemoveButtonView()
                }
                return
            }
            let item = itemList[indexPath.row]
            NavigationManager.shared.playItem(item: item, itemList: itemList, completion: { _ in })
        }
    }
}

extension UserPlaylistViewController: UICollectionViewDragDelegate {
    func collectionView(_: UICollectionView, itemsForBeginning _: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = itemList[indexPath.row]
        return [dragItem]
    }

    func collectionView(_: UICollectionView, itemsForAddingTo _: UIDragSession, at indexPath: IndexPath, point _: CGPoint) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = itemList[indexPath.row]
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, session _: UIDragSession) {
        var itemsToInsert = [IndexPath]()
        (0 ..< data.count).forEach {
            itemsToInsert.append(IndexPath(item: data[$0].count, section: $0))
            data[$0].append(.availableToDropAtEnd)
        }
        collectionView.insertItems(at: itemsToInsert)
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd _: UIDragSession) {
        var removeItems = [IndexPath]()
        for section in 0 ..< data.count {
            for item in 0 ..< data[section].count {
                switch data[section][item] {
                case .availableToDropAtEnd:
                    removeItems.append(IndexPath(item: item, section: section))
                case .simple:
                    break
                }
            }
        }
        collectionView.deleteItems(at: removeItems)
    }
}

extension UserPlaylistViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath, case UIDropOperation.move = coordinator.proposal.operation {
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }

    func collectionView(_: UICollectionView, canHandle _: UIDropSession) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate _: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag, let destinationIndexPath = destinationIndexPath {
            switch data[destinationIndexPath.section][destinationIndexPath.row] {
            case .simple:
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            case .availableToDropAtEnd:
                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
        } else { return UICollectionViewDropProposal(operation: .forbidden) }
    }

    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView _: UICollectionView) {
        let items = coordinator.items
        if items.count == 1, let item = items.first,
           let sourceIndexPath = item.sourceIndexPath,
           let _ = item.dragItem.localObject as? VideoItem
        {
            LoadingViewController.shared.startLoading()
            var destinationRow = destinationIndexPath.row
            if sourceIndexPath.row > destinationIndexPath.row, destinationRow != 0 {
                destinationRow = destinationIndexPath.row - 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let sourceItem = self.itemList[sourceIndexPath.row]
                let destinationItem = self.itemList[destinationRow]

                RealmManager.shared.swapVideoData(first: sourceItem, destination: destinationItem, playlistId: self.localPlaylistIdString, isFirstItem: destinationIndexPath.row == 0 ? true : false)
                self.loadData(isReOrder: true)
                LoadingViewController.shared.stopLoading()
            }
        }
    }
}
