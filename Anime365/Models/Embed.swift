// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let embed = try? newJSONDecoder().decode(Embed.self, from: jsonData)

import Foundation

// MARK: - Embed
struct Embed: Codable {
    let embedURL: String
    let download: [Download]
    let stream: [VideoStream]
    let subtitlesURL: String
    let subtitlesVttURL: String

    enum CodingKeys: String, CodingKey {
        case embedURL = "embedUrl"
        case download, stream
        case subtitlesURL = "subtitlesUrl"
        case subtitlesVttURL = "subtitlesVttUrl"
    }
}
