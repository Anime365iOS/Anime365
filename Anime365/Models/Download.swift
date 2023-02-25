// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let download = try? newJSONDecoder().decode(Download.self, from: jsonData)

import Foundation

// MARK: - Download
struct Download: Codable {
    let height: Int
    let url: String
}
