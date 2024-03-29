import Foundation

struct YoutubeVideoContentDetails: Codable {
    let kind, etag: String?
    let items: [YoutubeVideoContentDetailsItem]?
    let pageInfo: YoutubeVideoContentDetailsPageInfo?
}

// MARK: - YoutubeVideoContentDetailsItem

struct YoutubeVideoContentDetailsItem: Codable {
    let kind: String?
    let etag, id: String?
    let contentDetails: YoutubeVideoContentDetailsContentDetails?
    let statistics: YoutubeVideoContentDetailsStatistics?
}

// MARK: - YoutubeVideoContentDetailsContentDetails

struct YoutubeVideoContentDetailsContentDetails: Codable {
    let duration: String?
    let dimension: String?
    let definition: String?
    let caption: String?
    let licensedContent: Bool?
    let contentRating: YoutubeVideoContentDetailsContentRating?
    let projection: String?
    let regionRestriction: YoutubeVideoContentDetailsRegionRestriction?
}

// MARK: - YoutubeVideoContentDetailsContentRating

struct YoutubeVideoContentDetailsContentRating: Codable {}

// MARK: - YoutubeVideoContentDetailsRegionRestriction

struct YoutubeVideoContentDetailsRegionRestriction: Codable {
    let blocked: [String]?
}

// MARK: - YoutubeVideoContentDetailsStatistics

struct YoutubeVideoContentDetailsStatistics: Codable {
    let viewCount, likeCount, favoriteCount, commentCount: String?
}

// MARK: - YoutubeVideoContentDetailsPageInfo

struct YoutubeVideoContentDetailsPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
