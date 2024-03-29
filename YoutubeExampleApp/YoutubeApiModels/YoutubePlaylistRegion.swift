
import Foundation

struct YoutubePlaylistRegion: Codable {
    let kind, etag: String?
    let items: [YoutubePlaylistRegionItem]?
    let nextPageToken: String?
    let pageInfo: YoutubePlaylistRegionPageInfo?
}

// MARK: - YoutubePlaylistRegionItem

struct YoutubePlaylistRegionItem: Codable {
    let kind: String?
    let etag, id: String?
    let snippet: YoutubePlaylistRegionSnippet?
    let contentDetails: YoutubePlaylistRegionContentDetails?
    let statistics: YoutubePlaylistRegionStatistics?
}

// MARK: - YoutubePlaylistRegionContentDetails

struct YoutubePlaylistRegionContentDetails: Codable {
    let duration: String?
    let dimension: String?
    let definition: String?
    let caption: String?
    let licensedContent: Bool?
    let contentRating: YoutubePlaylistRegionContentRating?
    let projection: String?
    let regionRestriction: YoutubePlaylistRegionRegionRestriction?
}

// MARK: - YoutubePlaylistRegionContentRating

struct YoutubePlaylistRegionContentRating: Codable {}

// MARK: - YoutubePlaylistRegionRegionRestriction

struct YoutubePlaylistRegionRegionRestriction: Codable {
    let blocked, allowed: [String]?
}

// MARK: - YoutubePlaylistRegionSnippet

struct YoutubePlaylistRegionSnippet: Codable {
    let publishedAt: String?
    let channelId, title, description: String?
    let thumbnails: YoutubePlaylistRegionThumbnails?
    let channelTitle: String?
    let tags: [String]?
    let categoryID: String?
    let liveBroadcastContent: String?
    let localized: YoutubePlaylistRegionLocalized?
    let defaultAudioLanguage, defaultLanguage: String?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelId
        case title, description, thumbnails, channelTitle, tags
        case categoryID
        case liveBroadcastContent, localized, defaultAudioLanguage, defaultLanguage
    }
}

// MARK: - YoutubePlaylistRegionLocalized

struct YoutubePlaylistRegionLocalized: Codable {
    let title, description: String?
}

// MARK: - YoutubePlaylistRegionThumbnails

struct YoutubePlaylistRegionThumbnails: Codable {
    let thumbnailsDefault, medium, high, standard: YoutubePlaylistRegionDefault?
    let maxres: YoutubePlaylistRegionDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault
        case medium, high, standard, maxres
    }
}

// MARK: - YoutubePlaylistRegionDefault

struct YoutubePlaylistRegionDefault: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - YoutubePlaylistRegionStatistics

struct YoutubePlaylistRegionStatistics: Codable {
    let viewCount, likeCount, favoriteCount, commentCount: String?
}

// MARK: - YoutubePlaylistRegionPageInfo

struct YoutubePlaylistRegionPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
