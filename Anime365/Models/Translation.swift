// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let translation = try? newJSONDecoder().decode(Translation.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseTranslation { response in
//     if let translation = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Translation
struct Translation: Codable {
    let id: Int
    let addedDateTime, activeDateTime: String
    let authorsList: [String]
    let fansubsTranslationID, isActive, priority: Int
    let qualityType: QualityTypeEnum
    let type: PurpleType
    let typeKind: TypeKind
    let typeLang: TypeLang
    let updatedDateTime, title: String
    let seriesID, episodeID: Int
    let url, embedURL: String
    let authorsSummary: String
    let episode: Episode
    let series: Series
    let duration: String
    let width, height: Int

    enum CodingKeys: String, CodingKey {
        case id, addedDateTime, activeDateTime, authorsList
        case fansubsTranslationID = "fansubsTranslationId"
        case isActive, priority, qualityType, type, typeKind, typeLang, updatedDateTime, title
        case seriesID = "seriesId"
        case episodeID = "episodeId"
        case url
        case embedURL = "embedUrl"
        case authorsSummary, episode, series, duration, width, height
    }
}
