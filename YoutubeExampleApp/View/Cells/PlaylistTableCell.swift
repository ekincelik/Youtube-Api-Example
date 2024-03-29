//
//  PlaylistTableCell.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 19.10.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import Then
import UIKit

class PlaylistTableCell: UITableViewCell, ReusableCell {
    let mainLabel = UILabel().then {
        $0.textColor = .white
    }

    let viewCountLabel = UILabel().then {
        $0.textColor = .white
    }

    let line = UIView().then {
        $0.backgroundColor = .white
    }

    let optionImageView = UIImageView().then {
        $0.image = R.image.options()
        $0.tintColor = .gray
    }

    var localPlaylistObj: LocalPlaylist? = nil

    var localPlaylistDelegate: LocalPlaylistViewController?

    let optionButton = UIButton(frame: .zero)

    override var reuseIdentifier: String? {
        "PlaylistTableCellId"
    }

    override func didMoveToSuperview() {
        contentView.backgroundColor = UIColor.collectionViewBackgroundColor
        selectionStyle = .none
        optionButton.addSubview(optionImageView)
        [mainLabel, viewCountLabel, optionButton, line].forEach {
            contentView.addSubview($0)
        }
        optionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        layout()
    }

    @objc func optionButtonTapped() {
        guard let localPlaylist = localPlaylistObj else { return }
        localPlaylistDelegate?.displayOptions(localPlaylist: localPlaylist)
    }

    private func layout() {
        mainLabel.easy.layout(Top(10), Left(5), Width(screenWidth - 100), Height(30))
        viewCountLabel.easy.layout(Top(5).to(mainLabel, .bottom), Left(5), Width(screenWidth - 100), Height(30))
        optionImageView.easy.layout(
            Top(8),
            Bottom(8),
            Left(8),
            Right(8)
        )
        optionButton.easy.layout(
            CenterY(),
            Left(-40).to(contentView, .right),
            Width(40),
            Height(40)
        )
        line.easy.layout(Bottom(), Left(), Right(), Height(1))
    }
}
