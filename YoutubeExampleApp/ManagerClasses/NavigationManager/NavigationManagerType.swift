//
//  NavigationManagerType.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 13.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import UIKit

public protocol NavigationManagerType {
    var window: UIWindow { get }
    var mainViewController: UIViewController? { get }
    func playItem(item: VideoItem, itemList: [VideoItem], completion: @escaping (Bool) -> Void)
    func presentError(title: String?, message: String?)
    func presentErrorViewController(apiError: APIError)
    func displayOptions(item: VideoItem)
}
