//
//  SearchSuggestionViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 16.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

final class SearchSuggestionViewController: UIViewController {
    enum searchType: Int {
        case searchSuggestion = 0
        case searchedTest
    }

    public var seachSuggestionArray: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.searchSuggestionTable.tag = searchType.searchSuggestion.rawValue
                self.searchSuggestionTable.reloadData()
            }
        }
    }

    public var returnedSearchedArray: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.searchSuggestionTable.tag = searchType.searchedTest.rawValue
                self.searchSuggestionTable.reloadData()
            }
        }
    }

    public var searchSuggestionsCellDidTapped: ((String) -> Void)?

    public let searchSuggestionTable = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        seachSuggestionArray = []
        setCommonSubViews()
    }

    func setCommonSubViews() {
        searchSuggestionTable.delegate = self
        searchSuggestionTable.dataSource = self
        searchSuggestionTable.register(reusable: SearchSuggestionTableCell.self)
        searchSuggestionTable.separatorColor = .lightGray
        searchSuggestionTable.backgroundColor = UIColor.collectionViewBackgroundColor
        view.addSubview(searchSuggestionTable)
        searchSuggestionTable.easy.layout(
            Top(),
            Left(),
            Right(),
            Height(screenHeight * 0.4)
        )
    }
}

extension SearchSuggestionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.tag == searchType.searchSuggestion.rawValue ? seachSuggestionArray.count : returnedSearchedArray.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionTableCell.reuseIdentifier, for: indexPath)
        tableView.tag == searchType.searchSuggestion.rawValue ? suggestionConfigureCell(cell: cell, forRowAt: indexPath) : historyConfigureCell(cell: cell, forRowAt: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == searchType.searchSuggestion.rawValue {
            guard seachSuggestionArray.count > indexPath.row else { return }
            RealmManager.shared.addSearchText(searchText: seachSuggestionArray[indexPath.row])
            searchSuggestionsCellDidTapped?(seachSuggestionArray[indexPath.row])
        } else {
            guard returnedSearchedArray.count > indexPath.row else { return }
            RealmManager.shared.addSearchText(searchText: returnedSearchedArray[indexPath.row])
            searchSuggestionsCellDidTapped?(returnedSearchedArray[indexPath.row])
        }
    }

    func suggestionConfigureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let navCell = cell as? SearchSuggestionTableCell else { return }
        guard seachSuggestionArray.count > indexPath.row else { return }
        navCell.mainLabel.text = seachSuggestionArray[indexPath.row]
    }

    func historyConfigureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let navCell = cell as? SearchSuggestionTableCell else { return }
        guard returnedSearchedArray.count > indexPath.row else { return }
        navCell.mainLabel.text = returnedSearchedArray[indexPath.row]
    }
}
