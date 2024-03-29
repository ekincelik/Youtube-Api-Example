//
//  LocalPlaylistVideoItem.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 9.10.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import Foundation
import RealmSwift

class LocalPlaylist: Object {
    @objc dynamic var localPlaylistid = 0
    @objc dynamic var playlistname = ""
    @objc dynamic var videocount = 0

    override static func primaryKey() -> String? {
        "localPlaylistid"
    }
}

class VideoData: Object {
    @objc dynamic var videoDataId = 0
    @objc dynamic var author = ""
    @objc dynamic var duration = ""
    @objc dynamic var likeCount = ""
    @objc dynamic var localPlaylistId = 0
    @objc dynamic var playlistId = ""
    @objc dynamic var thumbnailUrl = ""
    @objc dynamic var title = ""
    @objc dynamic var uploadDate = ""
    @objc dynamic var videoId = ""
    @objc dynamic var viewCount = ""
}

class HistorySearch: Object {
    @objc dynamic var searchedText = ""
}
