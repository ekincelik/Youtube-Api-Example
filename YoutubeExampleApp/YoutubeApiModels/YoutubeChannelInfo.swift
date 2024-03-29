
import Foundation

struct YoutubeChannelInfo: Codable {
    let kind, etag: String?
    let pageInfo: YoutubeChannelInfoPageInfo?
    let items: [YoutubeChannelInfoItem]?
}

// MARK: - YoutubeChannelInfoItem

struct YoutubeChannelInfoItem: Codable {
    let kind, etag, id: String?
    let snippet: YoutubeChannelInfoSnippet?
    let contentDetails: YoutubeChannelInfoContentDetails?
    let statistics: YoutubeChannelInfoStatistics?
}

// MARK: - YoutubeChannelInfoContentDetails

struct YoutubeChannelInfoContentDetails: Codable {
    let relatedPlaylists: YoutubeChannelInfoRelatedPlaylists?
}

// MARK: - YoutubeChannelInfoRelatedPlaylists

struct YoutubeChannelInfoRelatedPlaylists: Codable {
    let likes, uploads: String?
}

// MARK: - YoutubeChannelInfoSnippet

struct YoutubeChannelInfoSnippet: Codable {
    let title, description, customURL: String?
    let publishedAt: String?
    let thumbnails: YoutubeChannelInfoThumbnails?
    let localized: YoutubeChannelInfoLocalized?
    let country: String?

    enum CodingKeys: String, CodingKey {
        case title, description
        case customURL
        case publishedAt, thumbnails, localized, country
    }
}

// MARK: - YoutubeChannelInfoLocalized

struct YoutubeChannelInfoLocalized: Codable {
    let title, description: String?
}

// MARK: - YoutubeChannelInfoThumbnails

struct YoutubeChannelInfoThumbnails: Codable {
    let thumbnailsDefault, medium, high: YoutubeChannelInfoDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault
        case medium, high
    }
}

// MARK: - YoutubeChannelInfoDefault

struct YoutubeChannelInfoDefault: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - YoutubeChannelInfoStatistics

struct YoutubeChannelInfoStatistics: Codable {
    let viewCount, subscriberCount: String?
    let hiddenSubscriberCount: Bool?
    let videoCount: String?
}

// MARK: - YoutubeChannelInfoPageInfo

struct YoutubeChannelInfoPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
