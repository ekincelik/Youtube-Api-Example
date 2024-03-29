//
//  ChannelViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 03.04.2022.
//  Copyright © 2022 Ekin Celik. All rights reserved.
//

import EasyPeasy
import Kingfisher
import Then
import UIKit

class ChannelViewController: BaseTabbarViewController {
    let segmentedControl = UISegmentedControl()
    public let channelId: String
    let channelName: String
    var uploadVideoNextPageToken: String?
    var playlistNextPageToken: String?
    var playlistId: String = ""
    var videoItemList: [VideoItem] = []
    var playlistItemList: [VideoItem] = []
    var channelInfoItem: YoutubeChannelInfoItem?

    enum segmentedIndex: Int {
        case videos = 0
        case playlists = 1
    }

    public var channelImageView: UIImageView = UIImageView().then {
        $0.kf.indicatorType = .activity
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor.gray
    }

    let channelTitleLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 2
        $0.font = UIFont.systemFont(ofSize: 16)
    }

    let subscriberLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 16)
    }

    /// The wrapper for the list view
    lazy var itemListWrapper: UIView = {
        let view = UIView()
        return view
    }()

    /// The list view
    fileprivate var mediaItemCollectionView: ItemCollectionView?

    init(channelId: String, channelName: String) {
        self.channelName = channelName
        self.channelId = channelId
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

        // Add the segmented control to the container view
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
        view.addSubview(channelImageView)
        view.addSubview(channelTitleLabel)
        view.addSubview(subscriberLabel)

        setNavigationTitle(title: channelName)
        getChannelInfo(channelId: channelId)
        channelImageView.layer.cornerRadius = 40.0
        channelImageView.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let listView = mediaItemCollectionView {
            listView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        layout()
    }

    func layout() {
        channelImageView.easy.layout(
            Top(30).to(customNavBar, .bottom),
            Left(30),
            Width(80),
            Height(80)
        )

        channelTitleLabel.easy.layout(
            Top(30).to(customNavBar, .bottom),
            Left(30).to(channelImageView, .right),
            Width(150),
            Height(30)
        )

        subscriberLabel.easy.layout(
            Top(5).to(channelTitleLabel, .bottom),
            Left(30).to(channelImageView, .right),
            Width(150),
            Height(30)
        )

        segmentedControl.easy.layout(
            Top(10).to(channelImageView, .bottom),
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

    func getChannelInfo(channelId: String) {
        Task {
            do {
                let returnedItems = try await YoutubeApiManager.shared.getChannelInfoWithId(channelId: channelId)
                guard let firstItem = returnedItems.first else { return }
                self.channelInfoItem = firstItem
                self.setupUI(youtubeItem: firstItem)
                self.getVideoResult(youtubeItem: firstItem)
            } catch let error as APIError {
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }

    func setupUI(youtubeItem: YoutubeChannelInfoItem) {
        if let imageURL = youtubeItem.snippet?.thumbnails?.medium?.url {
            channelImageView.kf.setImage(with: URL(string: imageURL))
        }
        channelTitleLabel.text = youtubeItem.snippet?.title
        if let subscriberCount = Int(youtubeItem.statistics?.subscriberCount ?? "") {
            subscriberLabel.text = subscriberCount.formatPoints()
        }
    }

    func getVideoResult(youtubeItem: YoutubeChannelInfoItem) {
        playlistId = youtubeItem.contentDetails?.relatedPlaylists?.uploads ?? ""
        Task {
            do {
                let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiGetPlaylistDetail(playlistId: playlistId)
                self.uploadVideoNextPageToken = youtubeApiResponse.nextPageToken
                self.videoItemList = youtubeApiResponse.allItems
                self.configureCollectionViewList(responseArray: youtubeApiResponse.allItems)
            } catch let error as APIError {
                self.configureCollectionViewList(responseArray: [])
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }

    func getPlaylistResult() {
        LoadingViewController.shared.startLoading()
        Task {
            do {
                let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiGetPlaylistsOfChannel(channelID: self.channelId)
                self.playlistNextPageToken = youtubeApiResponse.nextPageToken
                self.playlistItemList = youtubeApiResponse.allItems
                self.configureCollectionViewList(responseArray: youtubeApiResponse.allItems)
            } catch let error as APIError {
                self.configureCollectionViewList(responseArray: [])
                NavigationManager.shared.presentErrorViewController(apiError: error)
            }
            LoadingViewController.shared.stopLoading()
        }
    }

    private func configureCollectionViewList(responseArray: [VideoItem]) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        if let listView = mediaItemCollectionView {
            listView.removeFromSuperview()
        }
        mediaItemCollectionView = ItemCollectionView(layout: layout, items: responseArray)
        guard let mediaItemCollectionView = mediaItemCollectionView else { return }
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
                configureCollectionViewList(responseArray: videoItemList)
            } else if let channelItem = channelInfoItem {
                getVideoResult(youtubeItem: channelItem)
            }
        } else if segmentedControl.selectedSegmentIndex == segmentedIndex.playlists.rawValue {
            if playlistItemList.count > 0 {
                configureCollectionViewList(responseArray: playlistItemList)
            } else {
                getPlaylistResult()
            }
        }
    }
}

extension ChannelViewController {
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
        if segmentedControl.selectedSegmentIndex == segmentedIndex.videos.rawValue, let uploadNxtPageToken = uploadVideoNextPageToken {
            LoadingViewController.shared.startLoading()
            Task {
                do {
                    let youtubeApiResponse = try await
                        YoutubeApiManager.shared.youtubeApiGetPlaylistDetail(playlistId: playlistId, nextPageToken: uploadNxtPageToken)
                    self.uploadVideoNextPageToken = youtubeApiResponse.nextPageToken
                    self.videoItemList += youtubeApiResponse.allItems
                    self.mediaItemCollectionView?.itemArray = self.videoItemList
                    self.mediaItemCollectionView?.reloadData()
                } catch let error as APIError {
                    NavigationManager.shared.presentErrorViewController(apiError: error)
                }
                LoadingViewController.shared.stopLoading()
            }
        } else if segmentedControl.selectedSegmentIndex == segmentedIndex.playlists.rawValue, let playlistPageToken = playlistNextPageToken {
            LoadingViewController.shared.startLoading()
            Task {
                do {
                    let youtubeApiResponse = try await YoutubeApiManager.shared.youtubeApiGetPlaylistsOfChannel(channelID: self.channelId, nextPageToken: playlistPageToken)
                    self.playlistNextPageToken = youtubeApiResponse.nextPageToken
                    self.playlistItemList += youtubeApiResponse.allItems
                    self.mediaItemCollectionView?.itemArray = self.playlistItemList
                    self.mediaItemCollectionView?.reloadData()
                } catch let error as APIError {
                    NavigationManager.shared.presentErrorViewController(apiError: error)
                }
                LoadingViewController.shared.stopLoading()
            }
        }
    }
}
