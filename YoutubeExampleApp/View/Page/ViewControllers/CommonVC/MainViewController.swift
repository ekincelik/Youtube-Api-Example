//
//  MainViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 20/05/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import EmitterKit
import Foundation
import UIKit

class MainViewController: UINavigationController, UINavigationControllerDelegate {
    public lazy var customTabBarController = CustomTabBarController().then { $0.delegate = self as? UITabBarControllerDelegate }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        navigationController?.setNavigationBarHidden(true, animated: true)
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        presentRoute(viewController: customTabBarController)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func setupViews() {
        view.backgroundColor = UIColor.black
    }

    func presentRoute(viewController: UIViewController) {
        pushViewController(viewController, animated: false)
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
