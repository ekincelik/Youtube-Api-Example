//
//  SearchResultViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 19.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

class SearchResultViewController: BaseTabbarViewController {
    let segmentedControl = UISegmentedControl()
    let searchString: String
    var nextPageToken: String?
    var nextPlaylistPageToken: String?
    var videoItemList: [VideoItem] = []
    var playlistItemList: [VideoItem] = []

    /// The wrapper for the list view
    lazy var itemListWrapper: UIView = {
        let view = UIView()
        return view
    }()

    enum segmentedIndex: Int {
        case videos = 0
        case playlists
    }

    /// The list view
    fileprivate var mediaItemCollectionView: ItemCollectionView!

    init(searchString: String) {
        self.searchString = searchString
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        itemListWrapper.backgroundColor = UIColor.backgroundColor
        segmentedControl.insertSegment(withTitle: "Video", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Playlist", at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .lightGray
        segmentedControl.tintColor = .white
        segmentedControl.addTarget(self, action: #selector(updateSegmentedControl), for: .valueChanged)
        // Add the segmented control to the container view
        view.addSubview(segmentedControl)
        view.addSubview(itemListWrapper)
        setNavigationTitle(title: searchString)
        getVideoResult(searchString: searchString)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let listView = mediaItemCollectionView {
            listView.reloadData()
        }
    }

    func layout() {
        segmentedControl.easy.layout(
            Top(10).to(customNavBar, .bottom),
            Left(20),
            Right(20),
            Height(40)
        )
        itemListWrapper.easy.layout(
            Top(10).to(segmentedControl, .bottom),
            Left(10),
            Right(10),
            Bottom()
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        layout()
    }

    func getVideoResult(searchString: String) {
        RealmManager.shared.addSearchText(searchText: searchString)
        guard let encodedString = searchString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        LoadingViewController.shared.startLoading()
        Task {
            do {
                let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiSearchVideosResult(videoSearchString: encodedString)
                self.nextPageToken = youtubeApiResponse.nextPageToken
                self.videoItemList = youtubeApiResponse.allItems
                self.configureCollectionViewItems(responseItems: youtubeApiResponse.allItems)
            } catch let error as APIError {
                self.configureCollectionViewItems(responseItems: [])
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }

    func getPlaylistResult(searchString: String) {
        guard let encodedString = searchString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        LoadingViewController.shared.startLoading()
        Task {
            do {
                let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiSearchPlaylistResult(playlistSearchString: encodedString)
                self.nextPlaylistPageToken = youtubeApiResponse.nextPageToken
                self.playlistItemList = youtubeApiResponse.allItems
                self.configureCollectionViewItems(responseItems: youtubeApiResponse.allItems)
            } catch let error as APIError {
                self.configureCollectionViewItems(responseItems: [])
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }

    private func configureCollectionViewItems(responseItems: [VideoItem]) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        if let listView = mediaItemCollectionView {
            listView.removeFromSuperview()
        }
        mediaItemCollectionView = ItemCollectionView(layout: layout, items: responseItems)
        mediaItemCollectionView.registerClass(MediaItemCell.self)
        mediaItemCollectionView.indicatorStyle = .white
        itemListWrapper.addSubview(mediaItemCollectionView)
        mediaItemCollectionView.easy.layout(
            Left(),
            Top(),
            Bottom(),
            Right()
        )
        mediaItemCollectionView.didSelectAction = { indexPath in
            self.didSelectAction(indexPath: indexPath)
        }
        mediaItemCollectionView.checkShouldLoadNextPageCalled = { [weak self] in
            guard let self = self else { return }
            self.checkShouldLoadNextPage()
        }
    }

    @objc func updateSegmentedControl() {
        if segmentedControl.selectedSegmentIndex == segmentedIndex.videos.rawValue {
            if videoItemList.count > 0 {
                configureCollectionViewItems(responseItems: videoItemList)
            } else {
                getVideoResult(searchString: searchString)
            }
        } else if segmentedControl.selectedSegmentIndex == segmentedIndex.playlists.rawValue {
            if playlistItemList.count > 0 {
                configureCollectionViewItems(responseItems: playlistItemList)
            } else {
                getPlaylistResult(searchString: searchString)
            }
        }
    }
}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    func didSelectAction(indexPath: IndexPath) {
        if videoItemList.count > indexPath.row, segmentedControl.selectedSegmentIndex == segmentedIndex.videos.rawValue {
            let item = videoItemList[indexPath.row]
            NavigationManager.shared.playItem(item: item, itemList: videoItemList, completion: { _ in })
        }

        if playlistItemList.count > indexPath.row, segmentedControl.selectedSegmentIndex == segmentedIndex.playlists.rawValue {
            if let playlistId = playlistItemList[indexPath.row].playlistId, let playlistTitle = playlistItemList[indexPath.row].title {
                let playlistVC = PlaylistViewController(playlistIdString: playlistId, playlistTitle: playlistTitle)
                navigationController?.pushViewController(playlistVC, animated: true)
            }
        }
    }

    public func checkShouldLoadNextPage() {
        guard let encodedString = searchString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        if segmentedControl.selectedSegmentIndex == segmentedIndex.videos.rawValue {
            LoadingViewController.shared.startLoading()
            Task {
                do {
                    let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiSearchVideosResult(videoSearchString: encodedString, nextPageToken: nextPageToken)
                    self.nextPageToken = youtubeApiResponse.nextPageToken
                    self.videoItemList += youtubeApiResponse.allItems
                    self.mediaItemCollectionView.itemArray = self.videoItemList
                    self.mediaItemCollectionView.reloadData()
                } catch let error as APIError {
                    NavigationManager.shared.presentErrorViewController(apiError: error)
                }
                LoadingViewController.shared.stopLoading()
            }
        } else if segmentedControl.selectedSegmentIndex == segmentedIndex.playlists.rawValue {
            LoadingViewController.shared.startLoading()
            Task {
                do {
                    let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiSearchPlaylistResult(playlistSearchString: encodedString, nextPageToken: nextPageToken)
                    self.nextPlaylistPageToken = youtubeApiResponse.nextPageToken
                    self.playlistItemList += youtubeApiResponse.allItems
                    self.mediaItemCollectionView.itemArray = self.playlistItemList
                    self.mediaItemCollectionView.reloadData()
                } catch let error as APIError {
                    NavigationManager.shared.presentErrorViewController(apiError: error)
                }
                LoadingViewController.shared.stopLoading()
            }
        }
    }
}
