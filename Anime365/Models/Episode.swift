// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let episode = try? newJSONDecoder().decode(Episode.self, from: jsonData)

import Foundation

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

struct EpisodeFull: Codable {
    let id: Int
    let episodeFull, episodeInt, episodeTitle: String
    let episodeType: QualityTypeEnum
    let firstUploadedDateTime: String
    let isActive, isFirstUploaded, seriesID: Int
    let translations: [EpisodeTranslation]

    enum CodingKeys: String, CodingKey {
        case id, episodeFull, episodeInt, episodeTitle, episodeType, firstUploadedDateTime, isActive, isFirstUploaded
        case seriesID = "seriesId"
        case translations
    }
}

struct EpisodeTranslation: Codable, Identifiable {
    let id: Int
    let addedDateTime, activeDateTime: String
    let authorsList: [String]
    let fansubsTranslationID, isActive, priority: Int
    let qualityType: QualityTypeEnum
    let type: TranslationType
    let typeKind: TypeKind
    let typeLang: TypeLang
    let updatedDateTime, title: String
    let seriesID, episodeID: Int
    let url, embedURL: String
    let authorsSummary, duration: String
    let width, height: Int

    enum CodingKeys: String, CodingKey {
        case id, addedDateTime, activeDateTime, authorsList
        case fansubsTranslationID = "fansubsTranslationId"
        case isActive, priority, qualityType, type, typeKind, typeLang, updatedDateTime, title
        case seriesID = "seriesId"
        case episodeID = "episodeId"
        case url
        case embedURL = "embedUrl"
        case authorsSummary, duration, width, height
    }
}
