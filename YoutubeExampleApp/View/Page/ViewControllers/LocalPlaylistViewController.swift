//
//  LocalPlaylistViewController.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 01/06/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

class LocalPlaylistViewController: BaseTabbarViewController, UITableViewDelegate, UITableViewDataSource {
    var localPlaylistList: [LocalPlaylist] = []
    let table = UITableView(frame: .zero, style: .plain)

    let emptyLabel = UILabel().then {
        $0.text = "Empty List"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.font = UIFont.systemFont(ofSize: 24)
    }

    override init() {
        super.init()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layout()
        setNavigationTitle(title: "Local Playlists")
        customNavBar.searchButton.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.register(reusable: PlaylistTableCell.self)
        table.separatorColor = UIColor.clear
        table.backgroundColor = UIColor.collectionViewBackgroundColor
        view.addSubview(table)
        view.backgroundColor = UIColor.black
        setNeedsStatusBarAppearanceUpdate()

        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.easy.layout(
            CenterX(),
            CenterY(),
            Width(200),
            Height(45)
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    func loadData() {
        localPlaylistList = []
        localPlaylistList.append(contentsOf: RealmManager.shared.returnLocalPlaylists())
        emptyLabel.isHidden = localPlaylistList.isEmpty ? false : true
        table.reloadData()
    }

    func layout() {
        table.easy.layout(Top(10).to(customNavBar, .bottom), Bottom(10), Trailing(10), Leading(10))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        80
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        localPlaylistList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableCell.reuseIdentifier, for: indexPath)
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }

    func tableView(_: UITableView, shouldIndentWhileEditingRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let localPlaylist = localPlaylistList[indexPath.row]
        let userPlaylistVC = UserPlaylistViewController(localPlaylistIdString: localPlaylist.localPlaylistid, title: localPlaylist.playlistname)
        navigationController?.pushViewController(userPlaylistVC, animated: true)
    }

    func configureCell(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let navCell = cell as? PlaylistTableCell else { return }
        let localPlaylist = localPlaylistList[indexPath.row]
        navCell.mainLabel.text = localPlaylist.playlistname
        navCell.localPlaylistObj = localPlaylist
        navCell.localPlaylistDelegate = self
        let videoString = localPlaylist.videocount > 1 ? " videos" : " video"
        navCell.viewCountLabel.text = "\(localPlaylist.videocount)" + videoString
    }

    func displayOptions(localPlaylist: LocalPlaylist) {
        let alert = UIAlertController(title: localPlaylist.playlistname, message: "", preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) { _ in
            RealmManager.shared.deletePlaylist(playlistId: localPlaylist.localPlaylistid)
            self.loadData()
        }
        let addPlaylist = UIAlertAction(title: "Rename Playlist", style: UIAlertAction.Style.default) { _ in
            self.renamePlaylist(localPlaylist: localPlaylist)
        }
        let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in }
        alert.addAction(shareAction)
        alert.addAction(addPlaylist)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }

    func renamePlaylist(localPlaylist: LocalPlaylist) {
        let alert = UIAlertController(title: nil, message: localPlaylist.playlistname, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) in
            textField.placeholder = "Enter new playlist name"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
            if let answer = alert.textFields?[0].text, answer.count > 1 {
                RealmManager.shared.updatePlaylistTitle(playlistId: localPlaylist.localPlaylistid, playlistTitle: answer)
                self.loadData()
            }
        }
        let alertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in }
        alert.addAction(submitAction)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}
