//
//  LoadingViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 9.10.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import Foundation
import UIKit

class LoadingViewController: UIViewController {
    public static let shared = LoadingViewController()

    override var prefersStatusBarHidden: Bool {
        true
    }

    var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.autoresizingMask = [
            .flexibleWidth, .flexibleHeight,
        ]
        return blurEffectView
    }()

    var loadingActivityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func startLoading() {
        guard let mainViewController = NavigationManager.shared.window.rootViewController as? MainViewController else { return }
        view.backgroundColor = .clear

        view.addSubview(blurEffectView)
        view.addSubview(loadingActivityIndicator)
        mainViewController.view.addSubview(view)

        if #available(iOS 13.0, *) {
            loadingActivityIndicator.style = .large
        }
        loadingActivityIndicator.color = .black
        loadingActivityIndicator.tintColor = .black
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.easy.layout(
            CenterX(),
            CenterY(),
            Width(120),
            Height(120)
        )
        loadingActivityIndicator.easy.layout(
            CenterX(),
            CenterY(),
            Width(60),
            Height(60)
        )

        loadingActivityIndicator.startAnimating()
    }

    func stopLoading() {
        loadingActivityIndicator.stopAnimating()
        view.removeFromSuperview()
    }
}
