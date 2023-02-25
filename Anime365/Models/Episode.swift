// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let episode = try? newJSONDecoder().decode(Episode.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseEpisode { response in
//     if let episode = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Episode
struct Episode: Codable {
    let id: Int
    let episodeFull, episodeInt, episodeTitle: String
    let episodeType: QualityTypeEnum
    let firstUploadedDateTime: String
    let isActive, isFirstUploaded, seriesID: Int

    enum CodingKeys: String, CodingKey {
        case id, episodeFull, episodeInt, episodeTitle, episodeType, firstUploadedDateTime, isActive, isFirstUploaded
        case seriesID = "seriesId"
    }
}
