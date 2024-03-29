//
//  NavigationManager.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 13.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

final class NavigationManager: NavigationManagerType {
    public static let shared = NavigationManager()

    var mainViewController: UIViewController?

    var window: UIWindow {
        UIApplication.shared.windows.first!
    }

    public init() {
        guard let mainVC = window.rootViewController as? MainViewController else { return }
        mainViewController = mainVC
    }

    func playItem(item _: VideoItem, itemList _: [VideoItem], completion _: @escaping (Bool) -> Void) {
        // TODO: implement player
        presentError(title: "", message: "Player is not implemented yet")
    }

    func presentRoute(viewController: UIViewController) {
        if let mainViewController = window.rootViewController as? MainViewController {
            mainViewController.presentRoute(viewController: viewController)
        }
    }

    func presentErrorViewController(apiError: APIError) {
        switch apiError {
        case .decoding:
            presentError(title: nil, message: "Decoding error")
        case .network:
            presentError(title: nil, message: "Network error")
        case .server:
            presentError(title: nil, message: "Server error")
        case .unknown:
            presentError(title: nil, message: nil)
        }
    }

    func presentError(title: String? = "Error", message: String? = "An error occurred") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in }
        alert.addAction(alertAction)
        if let mainViewController = window.rootViewController as? MainViewController {
            mainViewController.present(alert, animated: true)
        }
    }

    func displayOptions(item: VideoItem) {
        let alert = UIAlertController(title: item.title, message: "", preferredStyle: .actionSheet)
        let addPlaylist = UIAlertAction(title: "Add to Playlist", style: UIAlertAction.Style.default) { _ in
            self.addToPlaylist(item: item)
        }
        let channelName = item.author ?? ""
        let openChannelAction = UIAlertAction(title: "Open Channel: \(channelName)", style: UIAlertAction.Style.default) { _ in
            guard let channelId = item.channelId else { return }
            let channelVC = ChannelViewController(channelId: channelId, channelName: channelName)
            self.rootVC()?.pushViewController(channelVC, animated: true)
        }

        let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in }

        if item.playlistId != nil, item.playlistId != "" {
            if item.channelId != nil {
                alert.addAction(openChannelAction)
            }
            alert.addAction(alertAction)
            rootVC()?.present(alert, animated: true)
            return
        }

        if item.channelId != nil {
            alert.addAction(openChannelAction)
        }
        alert.addAction(addPlaylist)
        alert.addAction(alertAction)
        rootVC()?.present(alert, animated: true)
    }

    func addToPlaylist(item: VideoItem) {
        var localPlaylistList: [LocalPlaylist] = []
        localPlaylistList.append(contentsOf: RealmManager.shared.returnLocalPlaylists())
        if localPlaylistList.count > 0 {
            let alert = UIAlertController(title: "Select playlist", message: "", preferredStyle: .alert)
            for localList in localPlaylistList {
                let playlistAction = UIAlertAction(title: localList.playlistname, style: UIAlertAction.Style.default) { _ in
                    self.addSongtoPlaylist(item: item, list: localList)
                }
                alert.addAction(playlistAction)
            }
            let createAlertAction = UIAlertAction(title: "Create a new playlist", style: UIAlertAction.Style.default) { _ in
                self.createNewPlaylist(item: item)
            }
            alert.addAction(createAlertAction)
            let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in }
            alert.addAction(alertAction)
            rootVC()?.present(alert, animated: true)
            return
        }
        createNewPlaylist(item: item)
    }

    func createNewPlaylist(item: VideoItem) {
        let alert = UIAlertController(title: nil, message: "Create a new playlist", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter playlist name"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
            if let answer = alert.textFields?[0].text, let localPlaylist = RealmManager.shared.addLocalPlaylist(playlistName: answer) {
                RealmManager.shared.addVideoData(videoItem: item, playlistId: localPlaylist.localPlaylistid)
            }
        }
        let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in }
        alert.addAction(submitAction)
        alert.addAction(alertAction)
        rootVC()?.present(alert, animated: true)
    }

    func addSongtoPlaylist(item: VideoItem, list: LocalPlaylist) {
        RealmManager.shared.addVideoData(videoItem: item, playlistId: list.localPlaylistid)
    }

    public func rootVC() -> UINavigationController? {
        var rootViewController = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        guard let rootVC = rootViewController as? UINavigationController else { return nil }
        return rootVC
    }
}
