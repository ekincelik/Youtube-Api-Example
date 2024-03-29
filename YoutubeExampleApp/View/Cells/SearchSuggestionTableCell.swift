//
//  SearchSuggestionTableCell.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 27.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import UIKit

class SearchSuggestionTableCell: UITableViewCell, ReusableCell {
    let mainLabel = UILabel()
    let arrow = UIImageView(image: R.image.arrowRight())

    override var reuseIdentifier: String? {
        "SearchTableCellId"
    }

    override func didMoveToSuperview() {
        contentView.backgroundColor = UIColor.collectionViewBackgroundColor
        selectionStyle = .none
        mainLabel.textColor = .white
        [mainLabel, arrow].forEach {
            contentView.addSubview($0)
        }
        layout()
    }

    private func layout() {
        mainLabel.easy.layout(Top(5), Left(10), Right(30), Bottom(5))
        arrow.easy.layout(Height(18), Width(11), Right(10), CenterY())
    }
}
