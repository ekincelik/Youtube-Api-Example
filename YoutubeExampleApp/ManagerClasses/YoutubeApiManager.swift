//
//  YoutubeApiManager.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 29/12/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import Foundation
import UIKit

public struct YoutubeResponseType {
    public let allItems: [VideoItem]
    public let nextPageToken: String?

    init(videoItem: [VideoItem], nextPageTkn: String? = nil) {
        allItems = videoItem
        nextPageToken = nextPageTkn
    }
}

public enum APIError: Error { case unknown, network, server, decoding }

open class YoutubeApiManager {
    public static let shared = YoutubeApiManager()
    let kApiClient = "https://www.googleapis.com/youtube/v3/"
    let skippedVideos = ["Deleted video", "Private video"]
    var apiKeyString: String = "AIzaSyAkYSanhlbvaZg4S6v0tYMNXOa6xAutgWM"

    private func setupRequestUrl(path: String, parametersDict: [String: String]) -> String {
        var string = "\(kApiClient)\(path)"
        var parameters = parametersDict
        parameters["key"] = apiKeyString
        string += "?" + parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        return string
    }

    private func setupParameters(part: String? = nil, q: String? = nil, maxResults: String? = nil, type: String? = nil, order: String? = nil, id: String? = nil, chart: String? = nil, videoCategoryId: String? = nil, channelId: String? = nil, playlistId: String? = nil, regionCode: String? = nil, pageToken: String? = nil) -> [String: String] {
        var params: [String: String] = [:]
        params["part"] = part
        params["q"] = q
        params["maxResults"] = maxResults
        params["type"] = type
        params["order"] = order
        params["id"] = id
        params["chart"] = chart
        params["videoCategoryId"] = videoCategoryId
        params["channelId"] = channelId
        params["playlistId"] = playlistId
        params["regionCode"] = regionCode
        params["pageToken"] = pageToken
        return params
    }

    func youtubeApiSearchVideosResult(videoSearchString: String, maxResult: Int = 25, nextPageToken: String? = nil) async throws -> YoutubeResponseType {
        let parameters = setupParameters(part: "snippet", q: videoSearchString, maxResults: String(maxResult), type: "video", order: "relevance", pageToken: nextPageToken)
        let requestURL = setupRequestUrl(path: "search", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubeVideoSearch.self, from: url)
            if let items = responseData.items {
                var videoItemArray: [VideoItem] = []
                for youtubePlaylistItem in items {
                    videoItemArray.append(convertSearchItemtoVideoItem(item: youtubePlaylistItem))
                }
                do {
                    let detailResponse = try await youtubeApiVideoContentDetailResult(videoItemArray: videoItemArray)
                    return YoutubeResponseType(videoItem: detailResponse, nextPageTkn: responseData.nextPageToken)
                } catch {
                    return YoutubeResponseType(videoItem: videoItemArray, nextPageTkn: responseData.nextPageToken)
                }
            }
        }
        throw APIError.unknown
    }

    func youtubeApiVideoContentDetailResult(videoItemArray: [VideoItem]) async throws -> [VideoItem] {
        let videoIdString = videoItemArray.filter { $0.videoId != nil }.map { $0.videoId! }.joined(separator: ",")

        let parameters = setupParameters(part: "statistics,contentDetails", id: videoIdString)
        let requestURL = setupRequestUrl(path: "videos", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubeVideoContentDetails.self, from: url)
            if let itemArray = responseData.items {
                var itemsArray: [VideoItem] = videoItemArray
                for (index, videoItem) in itemsArray.enumerated() {
                    if itemArray.count > index, responseData.items?[index].id == videoItem.videoId {
                        videoItem.viewCount = responseData.items?[index].statistics?.viewCount
                        videoItem.duration = responseData.items?[index].contentDetails?.duration
                        itemsArray[index] = videoItem
                    }
                }
                return itemsArray
            }
        }
        throw APIError.unknown
    }

    func youtubeApiSearchPlaylistResult(playlistSearchString: String, maxResult: Int = 25, nextPageToken: String? = nil) async throws -> YoutubeResponseType {
        let parameters = setupParameters(part: "snippet", q: playlistSearchString, maxResults: String(maxResult), type: "playlist", order: "relevance", pageToken: nextPageToken)
        let requestURL = setupRequestUrl(path: "search", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubeSearchPlaylist.self, from: url)
            if let items = responseData.items {
                var videoItemArray: [VideoItem] = []
                for youtubePlaylistItem in items {
                    if let title = youtubePlaylistItem.snippet?.title?.convertHtmlStringSymbols(), !skippedVideos.contains(title) {
                        videoItemArray.append(convertPlaylistResultItemtoVideoItem(item: youtubePlaylistItem))
                    }
                }
                do {
                    let detailResponse = try await youtubeApiPlaylistContentDetailResult(videoItemArray: videoItemArray)
                    return YoutubeResponseType(videoItem: detailResponse, nextPageTkn: responseData.nextPageToken)
                } catch {
                    return YoutubeResponseType(videoItem: videoItemArray, nextPageTkn: responseData.nextPageToken)
                }
            }
        }
        throw APIError.unknown
    }

    func youtubeApiPlaylistContentDetailResult(videoItemArray: [VideoItem]) async throws -> [VideoItem] {
        let playlistIdString = videoItemArray.filter { $0.playlistId != nil }.map { $0.playlistId! }.joined(separator: ",")
        let parameters = setupParameters(part: "contentDetails", id: playlistIdString)
        let requestURL = setupRequestUrl(path: "playlists", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubePlaylistContentDetail.self, from: url)
            if responseData.items != nil {
                var itemsArray: [VideoItem] = videoItemArray
                for (index, videoItem) in itemsArray.enumerated() {
                    if let itemArray = responseData.items, itemArray.count > index {
                        if responseData.items?[index].id == videoItem.playlistId, let itemCount = responseData.items?[index].contentDetails?.itemCount {
                            videoItem.numberOfTracks = "\(itemCount)"
                            itemsArray[index] = videoItem
                        }
                    }
                }
                return itemsArray
            }
        }
        throw APIError.unknown
    }

    func getChannelInfoWithId(channelId: String, nextPageToken: String? = nil) async throws -> [YoutubeChannelInfoItem] {
        let parameters = setupParameters(part: "id,snippet,contentDetails,statistics", id: channelId, pageToken: nextPageToken)
        let requestURL = setupRequestUrl(path: "channels", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubeChannelInfo.self, from: url)
            if let items = responseData.items {
                return items
            }
        }
        throw APIError.unknown
    }

    func youtubeApiGetPlaylistDetail(playlistId: String, maxResult: Int = 25, nextPageToken: String? = nil) async throws -> YoutubeResponseType {
        let parameters = setupParameters(part: "snippet", maxResults: String(maxResult), playlistId: playlistId, pageToken: nextPageToken)
        let requestURL = setupRequestUrl(path: "playlistItems", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubePlaylistDetail.self, from: url)
            if let items = responseData.items {
                var videoItemArray: [VideoItem] = []
                for youtubePlaylistItem in items {
                    if let title = youtubePlaylistItem.snippet?.title?.convertHtmlStringSymbols(), !skippedVideos.contains(title) {
                        videoItemArray.append(convertPlaylistDetailItemtoVideoItem(item: youtubePlaylistItem))
                    }
                }
                let detailResponse = try await youtubeApiVideoContentDetailResult(videoItemArray: videoItemArray)
                return YoutubeResponseType(videoItem: detailResponse, nextPageTkn: responseData.nextPageToken)
            }
        }
        throw APIError.unknown
    }

    func youtubeApiGetPlaylistsOfChannel(channelID: String, maxResult: Int = 25, nextPageToken: String? = nil) async throws -> YoutubeResponseType {
        let parameters = setupParameters(part: "snippet,contentDetails", maxResults: String(maxResult), channelId: channelID, pageToken: nextPageToken)
        let requestURL = setupRequestUrl(path: "playlists", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let responseData = try await fetchData(for: YoutubeChannelPlaylists.self, from: url)
            if let items = responseData.items {
                var videoItemArray: [VideoItem] = []
                for youtubePlaylistItem in items {
                    videoItemArray.append(convertChannelPlaylistItemtoVideoItem(item: youtubePlaylistItem))
                }
                return YoutubeResponseType(videoItem: videoItemArray, nextPageTkn: responseData.nextPageToken)
            }
        }
        throw APIError.unknown
    }

    func youtubeApiGetPlaylistByRegion(regionCode: String, videoCategoryID: Int, maxResult: Int = 25, nextPageToken: String? = nil) async throws -> YoutubeResponseType {
        let parameters = setupParameters(part: "snippet,contentDetails,statistics", maxResults: String(maxResult), chart: "mostPopular", videoCategoryId: String(videoCategoryID), regionCode: regionCode, pageToken: nextPageToken)
        let requestURL = setupRequestUrl(path: "videos", parametersDict: parameters)

        if let url = URL(string: requestURL) {
            let streamingData = try await fetchData(for: YoutubePlaylistRegion.self, from: url)
            if let items = streamingData.items {
                var videoItemArray: [VideoItem] = []
                for youtubePlaylistItem in items {
                    videoItemArray.append(convertRegionItemtoVideoItem(item: youtubePlaylistItem))
                }
                return YoutubeResponseType(videoItem: videoItemArray, nextPageTkn: streamingData.nextPageToken)
            }
        }
        throw APIError.unknown
    }

    private func fetchData<T: Decodable>(for _: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else { throw APIError.unknown }

        switch response.statusCode {
        case 200 ... 399:
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        case 400 ... 499:
            throw APIError.network
        case 500 ... 599:
            throw APIError.server
        default:
            throw APIError.unknown
        }
    }
}

extension YoutubeApiManager {
    // Convert to VideoItem
    func convertSearchItemtoVideoItem(item: YoutubeVideoSearchItem) -> VideoItem {
        VideoItem(videoId: item.id?.videoId, title: item.snippet?.title?.convertHtmlStringSymbols(), author: item.snippet?.channelTitle, liveString: item.snippet?.liveBroadcastContent, thumbnailUrl: item.snippet?.thumbnails?.medium?.url, channelId: item.snippet?.channelId)
    }

    func convertPlaylistResultItemtoVideoItem(item: YoutubeSearchPlaylistItem) -> VideoItem {
        VideoItem(title: item.snippet?.title?.convertHtmlStringSymbols(), author: item.snippet?.channelTitle, liveString: item.snippet?.liveBroadcastContent, thumbnailUrl: item.snippet?.thumbnails?.medium?.url, playlistId: item.id?.playlistId, channelId: item.snippet?.channelId)
    }

    func convertPlaylistResultItemtoVideoItem(item: YoutubeVideoContentDetailsItem) -> VideoItem {
        VideoItem(videoId: item.id, viewCount: item.statistics?.viewCount, duration: item.contentDetails?.duration, likeCount: item.statistics?.likeCount)
    }

    func convertPlaylistDetailItemtoVideoItem(item: YoutubePlaylistDetailItem) -> VideoItem {
        VideoItem(videoId: item.snippet?.resourceId?.videoId, title: item.snippet?.title?.convertHtmlStringSymbols(), author: item.snippet?.videoOwnerChannelTitle, thumbnailUrl: item.snippet?.thumbnails?.medium?.url, channelId: item.snippet?.videoOwnerChannelId)
    }

    func convertChannelPlaylistItemtoVideoItem(item: YoutubeChannelPlaylistsItem) -> VideoItem {
        VideoItem(title: item.snippet?.title?.convertHtmlStringSymbols(), author: item.snippet?.channelTitle, thumbnailUrl: item.snippet?.thumbnails?.medium?.url, numberOfTracks: String(item.contentDetails?.itemCount ?? 0), playlistId: item.id, channelId: item.snippet?.channelID)
    }

    func convertRegionItemtoVideoItem(item: YoutubePlaylistRegionItem) -> VideoItem {
        VideoItem(videoId: item.id, title: item.snippet?.title?.convertHtmlStringSymbols(), author: item.snippet?.channelTitle, viewCount: item.statistics?.viewCount, thumbnailUrl: item.snippet?.thumbnails?.medium?.url, duration: item.contentDetails?.duration, channelId: item.snippet?.channelId)
    }
}
