//
//  VideoItem.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 18.10.2023.
//  Copyright © 2023 Ekin Celik. All rights reserved.
//

import Foundation

public class VideoItem: Codable {
    var uploadDate: String?
    var videoId: String?
    var title: String?
    var author: String?
    var liveString: String?
    var viewCount: String?
    var thumbnailUrl: String?
    var highThumbnailUrl: String?
    var duration: String?
    var likeCount: String?
    var dislikeCount: String?
    var numberOfTracks: String?
    var playlistId: String?
    var channelId: String?
    var fileSize: String?
    var isFromLocalPlaylist: Bool = false

    public init(uploadDate: String? = nil, videoId: String? = nil, title: String? = nil, author: String? = nil, liveString: String? = nil, viewCount: String? = nil, thumbnailUrl: String? = nil, highThumbnailUrl: String? = nil, duration: String? = nil, likeCount: String? = nil, dislikeCount: String? = nil, numberOfTracks: String? = nil, playlistId: String? = nil, channelId: String? = nil, fileSize: String? = nil) {
        self.uploadDate = uploadDate
        self.videoId = videoId
        self.title = title
        self.author = author
        self.liveString = liveString
        self.viewCount = viewCount
        self.thumbnailUrl = thumbnailUrl
        self.highThumbnailUrl = highThumbnailUrl
        self.duration = duration
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.numberOfTracks = numberOfTracks
        self.playlistId = playlistId
        self.channelId = channelId
        self.fileSize = fileSize
    }

    public var isLiveContent: Bool {
        liveString == "live"
    }
}
