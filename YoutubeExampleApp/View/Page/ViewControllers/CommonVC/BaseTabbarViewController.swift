//
//  BaseTabbarViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 23.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

class BaseTabbarViewController: UIViewController {
    public let customNavBar: CustomNavigationView = .init()
    public let searchSuggestionVC: SearchSuggestionViewController = .init()
    public var navBarHeightAnchor: CGFloat = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        setCommonSubViews()
        setCommonLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavBar.backButton.isHidden = true
        if let viewCount = navigationController?.viewControllers.count, viewCount > 1 {
            customNavBar.backButton.isHidden = false
        }
    }

    func setNavigationTitle(title: String) {
        customNavBar.titleLabel.text = title
    }

    func setCommonSubViews() {
        view.addSubview(customNavBar)
        view.addSubview(searchSuggestionVC.view)
        searchSuggestionVC.view.isHidden = true

        searchSuggestionVC.searchSuggestionsCellDidTapped = { [weak self] string in
            guard let self = self else { return }
            self.searchSuggestionVC.view.isHidden = true
            let itemDetail = SearchResultViewController(searchString: string)
            self.customNavBar.closeSearchView()
            self.navigationController?.pushViewController(itemDetail, animated: true)
        }

        customNavBar.searchDidTapped = { [weak self] string in
            guard let self = self else { return }
            self.searchSuggestionVC.view.isHidden = true
            let itemDetail = SearchResultViewController(searchString: string)
            self.navigationController?.pushViewController(itemDetail, animated: true)
        }
        customNavBar.goBackAction = {
            self.navigationController?.popViewController(animated: true)
        }
        customNavBar.searchSuggestionsUpdate = { [weak self] stringArray in
            guard let self = self else { return }
            self.searchSuggestionVC.seachSuggestionArray = stringArray
            DispatchQueue.main.async {
                self.searchSuggestionVC.view.isHidden = false
                self.view.bringSubviewToFront(self.searchSuggestionVC.view)
            }
        }

        customNavBar.searchHistoryGet = { [weak self] stringArray in
            guard let self = self else { return }
            self.searchSuggestionVC.returnedSearchedArray = stringArray
            DispatchQueue.main.async {
                self.searchSuggestionVC.view.isHidden = false
                self.view.bringSubviewToFront(self.searchSuggestionVC.view)
            }
        }
        customNavBar.cancelButtonTapped = {
            self.searchSuggestionVC.view.isHidden = true
        }
    }

    func showEditButton() {
        customNavBar.showEditButton()
    }

    func setCommonLayout() {
        customNavBar.easy.layout(
            Top().to(view.safeAreaLayoutGuide, .top),
            Left(),
            Right(),
            Height(navBarHeightAnchor)
        )
        searchSuggestionVC.view.easy.layout(
            Top().to(customNavBar, .bottom),
            Left(),
            Right(),
            Height(screenHeight * 0.4)
        )
    }
}
