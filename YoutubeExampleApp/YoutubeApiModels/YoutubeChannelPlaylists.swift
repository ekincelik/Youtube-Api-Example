
import Foundation

struct YoutubeChannelPlaylists: Codable {
    let kind, etag, nextPageToken: String?
    let pageInfo: YoutubeChannelPlaylistsPageInfo?
    let items: [YoutubeChannelPlaylistsItem]?
}

// MARK: - YoutubeChannelPlaylistsItem

struct YoutubeChannelPlaylistsItem: Codable {
    let kind, etag, id: String?
    let snippet: YoutubeChannelPlaylistsSnippet?
    let contentDetails: YoutubeChannelPlaylistsContentDetails?
}

// MARK: - YoutubeChannelPlaylistsContentDetails

struct YoutubeChannelPlaylistsContentDetails: Codable {
    let itemCount: Int?
}

// MARK: - YoutubeChannelPlaylistsSnippet

struct YoutubeChannelPlaylistsSnippet: Codable {
    let publishedAt: String?
    let channelID, title, description: String?
    let thumbnails: YoutubeChannelPlaylistsThumbnails?
    let channelTitle: String?
    let localized: YoutubeChannelPlaylistsLocalized?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelID
        case title, description, thumbnails, channelTitle, localized
    }
}

// MARK: - YoutubeChannelPlaylistsLocalized

struct YoutubeChannelPlaylistsLocalized: Codable {
    let title, description: String?
}

// MARK: - YoutubeChannelPlaylistsThumbnails

struct YoutubeChannelPlaylistsThumbnails: Codable {
    let thumbnailsDefault, medium, high, standard: YoutubeChannelPlaylistsDefault?
    let maxres: YoutubeChannelPlaylistsDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault
        case medium, high, standard, maxres
    }
}

// MARK: - YoutubeChannelPlaylistsDefault

struct YoutubeChannelPlaylistsDefault: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - YoutubeChannelPlaylistsPageInfo

struct YoutubeChannelPlaylistsPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
