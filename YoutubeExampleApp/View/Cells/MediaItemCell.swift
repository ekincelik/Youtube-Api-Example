//
//  MediaItemCell.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 11.07.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import EasyPeasy
import Foundation
import Kingfisher
import UIKit

public enum CellEditingType {
    case none
    case deleteMode
    case reorderMode
}

public class MediaItemCell: UICollectionViewCell, ReusableCell {
    public var imageView: UIImageView = UIImageView().then {
        $0.kf.indicatorType = .activity
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor.gray
        $0.contentMode = .scaleToFill
        $0.backgroundColor = .lightGray
    }

    let optionImageView = UIImageView().then {
        $0.image = R.image.options()
        $0.tintColor = .gray
    }

    let optionButton = UIButton(frame: .zero)

    let nameLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 2
        $0.font = UIFont.systemFont(ofSize: 16)
    }

    let channelTitleLabel = UILabel().then {
        $0.textColor = .red
        $0.numberOfLines = 1
        $0.font = UIFont.systemFont(ofSize: 14)
    }

    let viewCountLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 12)
    }

    let dateLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textAlignment = .right
    }

    let durationLabel = UILabel().then {
        $0.backgroundColor = .black
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .white
        $0.layer.cornerRadius = 5
        $0.textAlignment = .center
    }

    let numberOfTracksLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textAlignment = .left
    }

    let checkMark = UIButton().then {
        $0.isUserInteractionEnabled = false
        $0.setImage(R.image.marked(), for: .selected)
        $0.setImage(R.image.unmarked(), for: .normal)
        $0.isHidden = true
    }

    var videoItem: VideoItem?
    var isLoading: Bool = false
    var isEditingEnabled: Bool = false

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    override public var isSelected: Bool {
        didSet {
            checkMark.isSelected = isSelected
        }
    }

    override public func prepareForReuse() {
        isSelected = false
    }

    open func setupViews() {
        [checkMark, imageView, nameLabel, channelTitleLabel, dateLabel, durationLabel, viewCountLabel, optionButton, numberOfTracksLabel].forEach {
            addSubview($0)
        }
        checkMark.isHidden = !isEditingEnabled
        optionButton.addSubview(optionImageView)
        optionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
    }

    @objc func optionButtonTapped() {
        guard let item = videoItem else { return }
        NavigationManager.shared.displayOptions(item: item)
    }

    open func setupLayout() {
        let imageWidth: CGFloat = 150

        if isEditingEnabled {
            checkMark.easy.layout(
                Left(34),
                Width(32),
                Height(32),
                Top(10)
            )
            imageView.easy.layout(
                Left(20).to(checkMark, .right),
                Width(imageWidth),
                Bottom(),
                Top()
            )
        } else {
            imageView.easy.layout(
                Left(),
                Width(imageWidth),
                Bottom(),
                Top()
            )
        }

        durationLabel.easy.layout(
            Left(-65).to(imageView),
            Width(55),
            Height(20),
            Bottom(5)
        )
        optionButton.easy.layout(
            Top().to(self, .top),
            Right(10).to(self, .right),
            Width(40),
            Height(40)
        )
        optionImageView.easy.layout(
            Top(8),
            Bottom(8),
            Left(8),
            Right(8)
        )
        nameLabel.easy.layout(
            Top(5),
            Left(10).to(imageView),
            Right(10).to(optionButton, .left),
            Height(45)
        )
        channelTitleLabel.easy.layout(
            Top(0).to(nameLabel),
            Left(10).to(imageView),
            Right(5).to(self),
            Height(20)
        )
        viewCountLabel.easy.layout(
            Top(5).to(channelTitleLabel, .bottom),
            Left(10).to(imageView),
            Width(120),
            Height(20)
        )
        dateLabel.easy.layout(
            Top().to(viewCountLabel, .top),
            Right(45),
            Width(70),
            Height(20)
        )
        numberOfTracksLabel.easy.layout(
            Top().to(channelTitleLabel, .bottom),
            Left().to(nameLabel, .left),
            Width(60),
            Height(20)
        )
    }

    func configureCell(item: VideoItem, allowSelection: Bool = false, editType: CellEditingType) {
        isEditingEnabled = allowSelection
        setCheckMark(editingType: editType)
        setupViews()
        setupLayout()
        configure(item: item)
    }

    public func configure(item: VideoItem) {
        videoItem = item
        if let imageUrl = item.thumbnailUrl {
            imageView.kf.setImage(with: URL(string: imageUrl))
        }
        nameLabel.text = item.title
        channelTitleLabel.text = item.author
        if let viewCount = item.viewCount {
            viewCountLabel.text = viewCount.convertViewCountFormat() ?? viewCount
        }
        setDurationLabel()
        setNumberOfTrackLabel(numberOfTracks: item.numberOfTracks)
        if item.uploadDate != nil {
            dateLabel.text = item.uploadDate
        }
        optionButton.isHidden = false
        if item.isFromLocalPlaylist {
            optionButton.isHidden = true
        }
    }

    private func setCheckMark(editingType: CellEditingType) {
        switch editingType {
        case .deleteMode:
            checkMark.setImage(R.image.marked(), for: .selected)
            checkMark.setImage(R.image.unmarked(), for: .normal)
        case .reorderMode:
            checkMark.setImage(R.image.reorder(), for: .selected)
            checkMark.setImage(R.image.reorder(), for: .normal)
        default:
            break
        }
    }

    private func setDurationLabel() {
        if videoItem?.isLiveContent == true {
            durationLabel.text = "LIVE"
        } else if let duration = videoItem?.duration {
            durationLabel.text = duration.getYoutubeFormattedDuration()
        } else {
            durationLabel.isHidden = true
        }
    }

    private func setNumberOfTrackLabel(numberOfTracks: String?) {
        guard let numberOfTracks = numberOfTracks else { return }
        var trackString = "track"
        if let trackNumber = Int(numberOfTracks), trackNumber > 1 {
            trackString = "tracks"
        }
        numberOfTracksLabel.text = "\(numberOfTracks) \(trackString)"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
