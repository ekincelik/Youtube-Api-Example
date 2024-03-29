
import Foundation

struct YoutubePlaylistDetail: Codable {
    let kind, etag, nextPageToken: String?
    let items: [YoutubePlaylistDetailItem]?
    let pageInfo: YoutubePlaylistDetailPageInfo?
}

// MARK: - YoutubePlaylistDetailItem

struct YoutubePlaylistDetailItem: Codable {
    let kind, etag, id: String?
    let snippet: YoutubePlaylistDetailSnippet?
}

// MARK: - YoutubePlaylistDetailSnippet

struct YoutubePlaylistDetailSnippet: Codable {
    let publishedAt: String?
    let channelId, title, description: String?
    let thumbnails: YoutubePlaylistDetailThumbnails?
    let channelTitle, playlistId: String?
    let position: Int?
    let resourceId: YoutubePlaylistDetailResourceID?
    let videoOwnerChannelTitle, videoOwnerChannelId: String?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelId
        case title, description, thumbnails, channelTitle
        case playlistId
        case position
        case resourceId
        case videoOwnerChannelTitle
        case videoOwnerChannelId
    }
}

// MARK: - YoutubePlaylistDetailResourceID

struct YoutubePlaylistDetailResourceID: Codable {
    let kind, videoId: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case videoId
    }
}

// MARK: - YoutubePlaylistDetailThumbnails

struct YoutubePlaylistDetailThumbnails: Codable {
    let thumbnailsDefault, medium, high, standard: YoutubePlaylistDetailDefault?
    let maxres: YoutubePlaylistDetailDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault
        case medium, high, standard, maxres
    }
}

// MARK: - YoutubePlaylistDetailDefault

struct YoutubePlaylistDetailDefault: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - YoutubePlaylistDetailPageInfo

struct YoutubePlaylistDetailPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
