// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let titles = try? newJSONDecoder().decode(Titles.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseTitles { response in
//     if let titles = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Titles
struct Titles: Codable {
    let romaji, ru: String
    let ja, en, short: String?
}
