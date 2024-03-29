//
//  CustomNavigationView.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 23.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

class CustomNavigationView: UIView {
    let backButton = UIButton().then {
        $0.setImage(R.image.back(), for: .normal)
    }

    let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
    }

    let searchBarView = UISearchBar().then {
        $0.placeholder = "Search"
        $0.backgroundColor = .black
        $0.setShowsCancelButton(true, animated: true)
        $0.tintColor = .white
        $0.setTextColor(.black)
        $0.barTintColor = UIColor.tabBarColor
    }

    let searchButton = UIButton().then {
        $0.setImage(R.image.search(), for: .normal)
    }

    let editButton = UIButton().then {
        $0.setTitle("Edit", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .clear
    }

    let removeButton = UIButton().then {
        $0.setTitle("Remove", for: .normal)
        $0.setTitleColor(.red, for: .normal)
        $0.backgroundColor = .clear
    }

    public var latestSearch: String?

    public var searchDidTapped: ((String) -> Void)?

    public var goBackAction: (() -> Void)?

    public var cancelButtonTapped: (() -> Void)?

    public var editButtonTapped: (() -> Void)?

    public var removeButtonTapped: (() -> Void)?

    public var searchSuggestionsUpdate: (([String]) -> Void)?

    public var searchHistoryGet: (([String]) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.tabBarColor
        setSubViews()
        setLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSubViews() {
        addSubview(searchBarView)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(searchButton)
        addSubview(editButton)
        addSubview(removeButton)
        sendSubviewToBack(searchBarView)
        editButton.isHidden = true
        removeButton.isHidden = true
        searchBarView.isHidden = true
        searchBarView.delegate = self
        editButton.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeButtonClicked), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    func getHistorySearch() {
        let searchedItems = RealmManager.shared.returnSearchText()
        var stringsArray: [String] = []
        for searchedItem in searchedItems {
            stringsArray.append(searchedItem.searchedText)
            searchHistoryGet?(stringsArray)
        }
    }

    func setLayout() {
        let topAnchor: CGFloat = 15

        backButton.easy.layout(
            Top(topAnchor),
            Left(10),
            Width(44),
            Height(39)
        )

        titleLabel.easy.layout(
            Top().to(backButton, .top),
            CenterX(),
            Width(screenWidth - (44 * 2)),
            Height(39)
        )

        searchButton.easy.layout(
            Top().to(backButton, .top),
            Right(10),
            Width(44),
            Height(39)
        )

        editButton.easy.layout(
            Top().to(backButton, .top),
            Right(10),
            Width(44),
            Height(39)
        )

        removeButton.easy.layout(
            Top().to(backButton, .top),
            Left(10),
            Width(70),
            Height(39)
        )

        searchBarView.easy.layout(
            Top().to(backButton, .top),
            Bottom(),
            Right(),
            Left()
        )
    }

    @objc func searchButtonClicked(sender _: UIButton) {
        searchBarView.isHidden = false
        bringSubviewToFront(searchBarView)
        searchBarView.becomeFirstResponder()
        searchBarView.text = latestSearch ?? ""
        if let searchText = searchBarView.text, searchText.count == 0 { getHistorySearch() }
    }

    @objc func editButtonClicked() {
        editButtonTapped?()
    }

    @objc func removeButtonClicked() {
        removeButtonTapped?()
    }

    @objc func goBack() {
        goBackAction?()
    }

    public func closeSearchView() {
        searchBarView.resignFirstResponder()
        searchBarView.isHidden = true
    }

    public func showEditButton() {
        backButton.isHidden = false
        searchButton.isHidden = true
        editButton.isHidden = false
    }

    public func doneEditButton() {
        backButton.isHidden = false
        searchButton.isHidden = true
        editButton.isHidden = false
        removeButton.isHidden = true
    }

    public func editButtonEnabled() {
        searchButton.isHidden = true
    }

    public func showRemoveButtonEnabled() {
        backButton.isHidden = true
        removeButton.isHidden = false
    }

    public func hideRemoveButtonEnabled() {
        backButton.isHidden = false
        removeButton.isHidden = true
    }
}

extension CustomNavigationView: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarView.isHidden = true
        sendSubviewToBack(searchBarView)
        cancelButtonTapped?()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchStr = searchBar.text, searchStr.count > 0 else { return }
        closeSearchView()
        searchDidTapped?(searchStr)
    }

    func searchBar(_: UISearchBar, textDidChange _: String) {
        guard let searchText = searchBarView.text else { return }
        latestSearch = searchText
        if searchText.count == 0 {
            getHistorySearch()
        }
        if searchText.count > 1 {
            AutoComplete.getQuerySuggestions(searchText) { [unowned self] suggestions, _ in
                if let suggestions = suggestions, suggestions.count > 0 {
                    self.searchSuggestionsUpdate?(suggestions)
                }
            }
        }
    }
}
