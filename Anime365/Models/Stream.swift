// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let stream = try? newJSONDecoder().decode(Stream.self, from: jsonData)

import Foundation

// MARK: - Stream
struct Stream: Codable {
    let height: Int
    let urls: [String]
}
