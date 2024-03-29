import Foundation

struct YoutubeVideoSearch: Codable {
    let kind, etag, nextPageToken, regionCode: String?
    let pageInfo: YoutubeVideoSearchPageInfo?
    let items: [YoutubeVideoSearchItem]?
}

// MARK: - YoutubeVideoSearchItem

struct YoutubeVideoSearchItem: Codable {
    let kind: String?
    let etag: String?
    let id: YoutubeVideoSearchID?
    let snippet: YoutubeVideoSearchSnippet?
}

// MARK: - YoutubeVideoSearchID

struct YoutubeVideoSearchID: Codable {
    let kind: String?
    let videoId: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case videoId
    }
}

// MARK: - YoutubeVideoSearchSnippet

struct YoutubeVideoSearchSnippet: Codable {
    let publishedAt: String?
    let channelId, title, description: String?
    let thumbnails: YoutubeVideoSearchThumbnails?
    let channelTitle: String?
    let liveBroadcastContent: String?
    let publishTime: Date?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelId
        case title, description, thumbnails, channelTitle, liveBroadcastContent, publishTime
    }
}

// MARK: - YoutubeVideoSearchThumbnails

struct YoutubeVideoSearchThumbnails: Codable {
    let thumbnailsDefault, medium, high: YoutubeVideoSearchDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault
        case medium, high
    }
}

// MARK: - YoutubeVideoSearchDefault

struct YoutubeVideoSearchDefault: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - YoutubeVideoSearchPageInfo

struct YoutubeVideoSearchPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
