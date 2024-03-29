//
//  CustomTabBarController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 23.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

private let navIcons = [R.image.refPlaylist(), R.image.refSettings()]

private let navTitles = ["Videos", "Local Playlists"]

final class CustomTabBarController: UITabBarController { // WWE code - final added
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBar.tintColor = .white
        tabBar.barStyle = .black
        tabBar.backgroundColor = .darkGray
        tabBar.itemPositioning = .centered
        tabBar.barTintColor = UIColor.tabBarColor
        tabBar.isTranslucent = false
        view.backgroundColor = UIColor.primaryColor
        tabSetUp()
    }

    func remakeTabs() {
        viewControllers?.removeAll()
        tabSetUp()
    }

    @objc private func tabSetUp() {
        var controllers = [UIViewController]()
        for index in 0 ... 1 {
            var viewControllerUn = UIViewController()
            if index == 0 {
                viewControllerUn = RegionPlaylistViewController(playlistTitle: "Latest Music")
            }
            if index == 1 {
                viewControllerUn = LocalPlaylistViewController()
            }
            viewControllerUn.tabBarItem = UITabBarItem(title: navTitles[index], image: navIcons[index], tag: index)
            let navVC = UINavigationController(rootViewController: viewControllerUn)
            controllers.append(navVC)
        }

        viewControllers = controllers
        selectedIndex = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        view.setNeedsLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.titleView = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
}
