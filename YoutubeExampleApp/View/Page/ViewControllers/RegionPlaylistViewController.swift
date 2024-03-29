//
//  RegionPlaylistViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 01/06/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import RealmSwift
import UIKit

class RegionPlaylistViewController: BaseTabbarViewController {
    var itemList: [VideoItem] = []
    let playlistName: String
    var nextPlaylistPageToken: String?
    /// The wrapper for the list view
    lazy var itemListWrapper: UIView = {
        let view = UIView()
        return view
    }()

    var deviceCountryCode: String {
        (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "us"
    }

    let musicCategoryId = 10

    /// The list view
    fileprivate var mediaItemCollectionView: ItemCollectionView?

    init(playlistTitle: String) {
        playlistName = playlistTitle
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let listView = mediaItemCollectionView {
            listView.reloadData()
        }
        setNavigationTitle(title: playlistName)
        customNavBar.searchButton.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        getPlaylistId()
    }

    func getPlaylistId() {
        LoadingViewController.shared.startLoading()
        Task {
            do {
                let youtubeResponse = try await YoutubeApiManager.shared.youtubeApiGetPlaylistByRegion(regionCode: deviceCountryCode, videoCategoryID: musicCategoryId)
                self.nextPlaylistPageToken = youtubeResponse.nextPageToken
                self.itemList = youtubeResponse.allItems
                self.configureCollectionViewList(responseArray: youtubeResponse.allItems)
            } catch let error as APIError {
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }

    private func configureCollectionViewList(responseArray: [VideoItem]) {
        itemListWrapper.backgroundColor = UIColor.backgroundColor
        view.addSubview(itemListWrapper)
        itemListWrapper.easy.layout(
            Top().to(customNavBar, .bottom),
            Left(),
            Right(),
            Bottom()
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        mediaItemCollectionView = ItemCollectionView(layout: layout, items: responseArray)
        guard let mediaItemCollectionView = mediaItemCollectionView else { return }
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
            if let item = self.mediaItemCollectionView?.itemAtIndexPath(indexPath) {
                NavigationManager.shared.playItem(item: item, itemList: self.itemList, completion: { _ in })
            }
        }
        mediaItemCollectionView.checkShouldLoadNextPageCalled = { [weak self] in
            guard let self = self else { return }
            self.checkShouldLoadNextPage()
        }
    }
}

extension RegionPlaylistViewController {
    public func checkShouldLoadNextPage() {
        guard let nxtPlaylistPageToken = nextPlaylistPageToken else { return }
        LoadingViewController.shared.startLoading()
        Task {
            do {
                let youtubeResponse = try await YoutubeApiManager.shared.youtubeApiGetPlaylistByRegion(regionCode: deviceCountryCode, videoCategoryID: musicCategoryId, nextPageToken: nxtPlaylistPageToken)
                self.nextPlaylistPageToken = youtubeResponse.nextPageToken
                self.itemList += youtubeResponse.allItems
                self.mediaItemCollectionView?.itemArray = self.itemList
                self.mediaItemCollectionView?.reloadData()
            } catch let error as APIError {
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }
}
