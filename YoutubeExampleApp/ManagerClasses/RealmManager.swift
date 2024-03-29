//
//  RealmManager.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 9.10.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import RealmSwift
import UIKit

open class RealmManager {
    public static let shared = RealmManager()

    lazy var realmDB = try! Realm()
    let navigationManager = NavigationManager.shared

    func addSearchText(searchText: String) {
        let search = HistorySearch()
        search.searchedText = searchText
        let titleMatch = realmDB.objects(HistorySearch.self).filter("searchedText == %@", search.searchedText)
        if titleMatch.count != 0 {
            return
        }
        do {
            try realmDB.write {
                realmDB.add(search)
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
    }

    func deleteSearchText(searchText: String) {
        let search = HistorySearch()
        search.searchedText = searchText
        do {
            try realmDB.write {
                realmDB.delete(search)
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
    }

    func deletePlaylist(playlistId: Int) {
        let playlistToDelete = realmDB.objects(LocalPlaylist.self).filter("localPlaylistid == %@", playlistId)
        let videosToDelete = realmDB.objects(VideoData.self).filter("localPlaylistId == %@", playlistId)
        do {
            try realmDB.write {
                realmDB.delete(playlistToDelete)
                realmDB.delete(videosToDelete)
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
    }

    func updatePlaylistTitle(playlistId: Int, playlistTitle: String) {
        let playlist = realmDB.objects(LocalPlaylist.self).filter("localPlaylistid == %@", playlistId)
        if let playlistObj = playlist.first {
            do {
                try realmDB.write {
                    playlistObj.playlistname = playlistTitle
                }
            } catch {
                navigationManager.presentError(title: "", message: error.localizedDescription)
            }
        }
    }

    func removeVideoDataFromPlaylist(playlistID: Int, searchDataArray: [VideoItem]) {
        var objectsToDelete: [VideoData] = []
        for searchData in searchDataArray {
            let videoItem = realmDB.objects(VideoData.self).filter("(localPlaylistId == %@) AND (videoId == %@)", playlistID, searchData.videoId ?? "")
            objectsToDelete.append(contentsOf: videoItem)
        }
        do {
            try realmDB.write {
                realmDB.delete(objectsToDelete)
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
        updateViewCount(playlistId: playlistID)
    }

    func returnSearchText() -> Results<HistorySearch> {
        let realm = try! Realm()
        let historySearchData = realm.objects(HistorySearch.self)
        return historySearchData
    }

    func addLocalPlaylist(playlistName: String) -> LocalPlaylist? {
        guard playlistName.count > 1 else { return nil }
        let maxValue = realmDB.objects(LocalPlaylist.self).max(ofProperty: "localPlaylistid") as Int?
        let nextId = (maxValue ?? 0) + 1
        let localIPlaylist = LocalPlaylist()
        localIPlaylist.playlistname = playlistName
        localIPlaylist.localPlaylistid = nextId
        let titleMatch = realmDB.objects(LocalPlaylist.self).filter("playlistname == %@", localIPlaylist.playlistname)
        if titleMatch.count != 0 {
            navigationManager.presentError(title: "Error", message: "Playlist exits with same name. Please use another name.")
            return nil
        }
        do {
            try realmDB.write {
                realmDB.add(localIPlaylist)
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
        return localIPlaylist
    }

    func getPlaylistItems(playlistId: Int) -> [VideoItem] {
        let idMatch = realmDB.objects(VideoData.self).filter("localPlaylistId == %@", playlistId).sorted(byKeyPath: "videoDataId")
        var playlistItems: [VideoItem] = []
        for videoData in idMatch {
            let videoItem = convertVideoItemFromVideoData(videoItemObj: videoData)
            videoItem.isFromLocalPlaylist = true
            playlistItems.append(videoItem)
        }
        return playlistItems
    }

    func updateViewCount(playlistId: Int) {
        let idMatch = realmDB.objects(VideoData.self).filter("localPlaylistId == %@", playlistId)
        let playlist = realmDB.objects(LocalPlaylist.self).filter("localPlaylistid == %@", playlistId)
        if let playlistObj = playlist.first {
            do {
                try realmDB.write {
                    playlistObj.videocount = idMatch.count
                }
            } catch {
                navigationManager.presentError(title: "", message: error.localizedDescription)
            }
        }
    }

    func swapVideoData(first: VideoItem, destination: VideoItem, playlistId: Int, isFirstItem: Bool = false) {
        let firstItem = realmDB.objects(VideoData.self).filter("(localPlaylistId == %@) AND (videoId == %@)", playlistId, first.videoId ?? "")
        let previousItem = realmDB.objects(VideoData.self).filter("(localPlaylistId == %@) AND (videoId == %@)", playlistId, destination.videoId ?? "")
        guard let firstVideoData = firstItem.first, let previousVideoData = previousItem.first else { return }
        var videoDataList = realmDB.objects(VideoData.self).filter("videoDataId > %@", previousVideoData.videoDataId)
        if isFirstItem {
            videoDataList = realmDB.objects(VideoData.self).filter("videoDataId >= %@", previousVideoData.videoDataId)
        }
        var newItemData = previousVideoData.videoDataId + 1
        if isFirstItem {
            newItemData = previousVideoData.videoDataId
        }
        for videoData in videoDataList {
            if videoData.videoId != firstVideoData.videoId {
                do {
                    try realmDB.write {
                        videoData.videoDataId += 1
                    }
                } catch {
                    navigationManager.presentError(title: "", message: error.localizedDescription)
                }
            }
        }
        do {
            try realmDB.write {
                firstVideoData.videoDataId = newItemData
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
    }

    func addVideoData(videoItem: VideoItem, playlistId: Int) {
        let maxValue = realmDB.objects(VideoData.self).max(ofProperty: "videoDataId") as Int?
        let videoDataObj = convertVideoData(videoItem: videoItem)
        let nextId = (maxValue ?? 0) + 1
        videoDataObj.videoDataId = nextId
        videoDataObj.localPlaylistId = playlistId

        let titleMatch = realmDB.objects(VideoData.self).filter("(localPlaylistId == %@) AND (videoId == %@)", videoDataObj.localPlaylistId, videoDataObj.videoId)
        if titleMatch.count > 0 {
            navigationManager.presentError(title: "Error", message: "Video exists on this playlist.")
            return
        }

        do {
            try realmDB.write {
                realmDB.add(videoDataObj)
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }

        let idMatch = realmDB.objects(VideoData.self).filter("localPlaylistId == %@", playlistId)
        let playlist = realmDB.objects(LocalPlaylist.self).filter("localPlaylistid == %@", playlistId)
        if let playlistObj = playlist.first {
            do {
                try realmDB.write {
                    playlistObj.videocount = idMatch.count
                }
            } catch {
                navigationManager.presentError(title: "", message: error.localizedDescription)
            }
        }
    }

    func returnLocalPlaylists() -> Results<LocalPlaylist> {
        let realm = try! Realm()
        let localItems = realm.objects(LocalPlaylist.self)
        return localItems
    }

    func removeAllVideoItem() {
        let realm = try! Realm()
        do {
            try realmDB.write {
                realm.deleteAll()
            }
        } catch {
            navigationManager.presentError(title: "", message: error.localizedDescription)
        }
    }

    func convertVideoItemFromVideoData(videoItemObj: VideoData) -> VideoItem {
        VideoItem(uploadDate: videoItemObj.uploadDate, videoId: videoItemObj.videoId, title: videoItemObj.title, author: videoItemObj.author, viewCount: videoItemObj.viewCount, thumbnailUrl: videoItemObj.thumbnailUrl, duration: videoItemObj.duration, likeCount: videoItemObj.likeCount, playlistId: videoItemObj.playlistId)
    }

    func convertVideoData(videoItem: VideoItem) -> VideoData {
        let videoData = VideoData()
        if let uploadDate = videoItem.uploadDate {
            videoData.uploadDate = uploadDate
        }
        if let videoId = videoItem.videoId {
            videoData.videoId = videoId
        }
        if let title = videoItem.title {
            videoData.title = title
        }
        if let author = videoItem.author {
            videoData.author = author
        }
        if let viewCount = videoItem.viewCount {
            videoData.viewCount = viewCount
        }
        if let thumbnailUrl = videoItem.thumbnailUrl {
            videoData.thumbnailUrl = thumbnailUrl
        }
        if let duration = videoItem.duration {
            videoData.duration = duration
        }
        if let likeCount = videoItem.likeCount {
            videoData.likeCount = likeCount
        }
        if let playlistId = videoItem.playlistId {
            videoData.playlistId = playlistId
        }
        return videoData
    }
}
