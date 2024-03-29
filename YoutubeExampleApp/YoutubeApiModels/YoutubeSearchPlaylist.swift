
import Foundation

struct YoutubeSearchPlaylist: Codable {
    let kind, etag, nextPageToken, regionCode: String?
    let pageInfo: YoutubeSearchPlaylistPageInfo?
    let items: [YoutubeSearchPlaylistItem]?
}

// MARK: - YoutubeSearchPlaylistItem

struct YoutubeSearchPlaylistItem: Codable {
    let kind: String?
    let etag: String?
    let id: YoutubeSearchPlaylistID?
    let snippet: YoutubeSearchPlaylistSnippet?
}

// MARK: - YoutubeSearchPlaylistID

struct YoutubeSearchPlaylistID: Codable {
    let kind: String?
    let playlistId: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case playlistId
    }
}

// MARK: - YoutubeSearchPlaylistSnippet

struct YoutubeSearchPlaylistSnippet: Codable {
    let publishedAt: String?
    let channelId, title, description: String?
    let thumbnails: YoutubeSearchPlaylistThumbnails?
    let channelTitle: String?
    let liveBroadcastContent: String?
    let publishTime: Date?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelId
        case title, description, thumbnails, channelTitle, liveBroadcastContent, publishTime
    }
}

// MARK: - YoutubeSearchPlaylistThumbnails

struct YoutubeSearchPlaylistThumbnails: Codable {
    let thumbnailsDefault, medium, high: YoutubeSearchPlaylistDefault?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault
        case medium, high
    }
}

// MARK: - YoutubeSearchPlaylistDefault

struct YoutubeSearchPlaylistDefault: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - YoutubeSearchPlaylistPageInfo

struct YoutubeSearchPlaylistPageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
