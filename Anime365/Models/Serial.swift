// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let series = try? newJSONDecoder().decode(Series.self, from: jsonData)

import Foundation

// MARK: - Series
struct Serial: Codable {
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
    let descriptions: [Description]
    let episodes: [Episode]
    let genres: [Genre]

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
        case titleLines, allTitles, title, url, descriptions, episodes, genres
    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let title: String
    let url: String
}

// MARK: - Description
struct Description: Codable {
    let source, value, updatedDateTime: String
}
