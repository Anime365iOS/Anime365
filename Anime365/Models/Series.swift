// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let series = try? newJSONDecoder().decode(Series.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseSeries { response in
//     if let series = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Series
struct Series: Codable {
    let id, aniDBID, animeNewsNetworkID, fansubsID: Int
    let imdbID, worldArtID, isActive, isAiring: Int
    let isHentai: Int
    let links: [Link]
    let myAnimeListID: Int
    let myAnimeListScore, worldArtScore: String
    let worldArtTopPlace: Int?
    let numberOfEpisodes: Int
    let season: String
    let year: Int
    let type: QualityTypeEnum
    let typeTitle: TypeTitle
    let titles: Titles
    let posterURL, posterURLSmall: String
    let titleLines, allTitles: [String]
    let title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case aniDBID = "aniDbId"
        case animeNewsNetworkID = "animeNewsNetworkId"
        case fansubsID = "fansubsId"
        case imdbID = "imdbId"
        case worldArtID = "worldArtId"
        case isActive, isAiring, isHentai, links
        case myAnimeListID = "myAnimeListId"
        case myAnimeListScore, worldArtScore, worldArtTopPlace, numberOfEpisodes, season, year, type, typeTitle, titles
        case posterURL = "posterUrl"
        case posterURLSmall = "posterUrlSmall"
        case titleLines, allTitles, title, url
    }
}
