import Foundation

struct TranslationsListResponse: Decodable {
    let data: [Translation]
}

struct TranslationResponse: Decodable {
    let data: Translation
}

struct SeriesListResponse: Decodable {
    let data: [Serial]
}

struct SerialResponse: Decodable {
    let data: Serial
}

struct EpisodeResponse: Decodable {
    let data: EpisodeFull
}

struct EmbedResponse: Decodable {
    let data: Embed
}
