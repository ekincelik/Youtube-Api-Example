
import Foundation

struct YoutubePlaylistContentDetail: Codable {
    let kind, etag, nextPageToken: String?
    let pageInfo: YoutubePlaylistContentDetailPageInfo?
    let items: [YoutubePlaylistContentDetailItem]?
}

// MARK: - YoutubePlaylistContentDetailItem

struct YoutubePlaylistContentDetailItem: Codable {
    let kind, etag, id: String?
    let contentDetails: YoutubePlaylistContentDetailContentDetails?
}

// MARK: - YoutubePlaylistContentDetailContentDetails

struct YoutubePlaylistContentDetailContentDetails: Codable {
    let itemCount: Int?
}

// MARK: - YoutubePlaylistContentDetailPageInfo

struct YoutubePlaylistContentDetailPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
