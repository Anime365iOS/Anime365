//
//  AnimeAPI.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import Foundation
import Alamofire

class AnimeAPI {

    static let shared = AnimeAPI()
    
    private let baseUrl = "https://smotret-anime.online/api"

    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 10
        return Session(configuration: configuration)
    }()
    
    private enum APIError: Error {
        case emptyResponse
        case invalidResponse
        case requestFailed
        case serverError
    }
    
    enum FeedType: String {
        case recent
        case id
        case all
    }
    
    
    private func get<T: Decodable>(url: String, parameters: [String: Any]?, responseType: T.Type) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            var headers: HTTPHeaders = [
                "User-Agent": "Anime365 IOS root@dimensi.dev",
                "cookie": "aaaa8ed0da05b797653c4bd51877d861=497fedc668a89bf62da1e6451bdb3f1a2e4805a7a%3A4%3A%7Bi%3A0%3Bi%3A50780%3Bi%3A1%3Bs%3A7%3A%22DimenSi%22%3Bi%3A2%3Bi%3A2592000%3Bi%3A3%3Ba%3A1%3A%7Bs%3A23%3A%22passwordChangedDateTime%22%3Bs%3A19%3A%222023-02-25+21%3A23%3A09%22%3B%7D%7D"
            ]
            
//            if let cookies = HTTPCookieStorage.shared.cookies {
//                if (!cookies.isEmpty) {
//                    let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
//                    cookieHeader.forEach { key, value in
//                        headers.add(name: key, value: value)
//                    }
//                }
//            }
            
            print(headers)
            
            sessionManager.request(url, parameters: parameters, headers: headers).validate().responseDecodable(of: responseType) { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(with: .success(data))
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 400...499:
                            continuation.resume(with: .failure(APIError.invalidResponse))
                        case 500...599:
                            continuation.resume(with: .failure(APIError.serverError))
                        default:
                            continuation.resume(with: .failure(APIError.requestFailed))
                        }
                    } else {
                        continuation.resume(with: .failure(error))
                    }
                }
            }
        }
    }

    func getLatestTranslations(feedType: FeedType? = nil, seriesId: Int? = nil, limit: Int? = nil, fields: String? = nil) async throws -> [Translation] {
        let url = baseUrl + "/translations/"
        let parameters: [String: Any] = [
            "feed": feedType?.rawValue as Any,
            "seriesId": seriesId as Any,
            "limit": limit as Any,
            "fields": fields as Any,
        ].compactMapValues { $0 }


        let response: TranslationsListResponse = try await get(url: url, parameters: parameters, responseType: TranslationsListResponse.self)
        return response.data
    }
    

    func getTranslationById(id: Int) async throws -> Translation {
        let url = baseUrl + "/translations/\(id)"

        let response: TranslationResponse = try await get(url: url, parameters: nil, responseType: TranslationResponse.self)
        return response.data
    }

    func getTranslationEmbedInfo(id: Int) async throws -> Embed {
        let url = baseUrl + "/translations/embed/\(id)";
        
        let response: EmbedResponse = try await get(url: url, parameters: nil, responseType: EmbedResponse.self)
        return response.data
    }

    func getAllAnime(fields: String? = nil, myAnimeListId: Int? = nil, query: String? = nil, pretty: Int? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> [Serial] {
        let url = baseUrl + "/series/"
        let parameters: [String: Any] = [
            "fields": fields as Any,
            "myAnimeListId": myAnimeListId as Any,
            "query": query as Any,
            "pretty": pretty as Any,
            "limit": limit as Any,
            "offset": offset as Any
        ].compactMapValues { $0 }

        let response: SeriesListResponse = try await get(url: url, parameters: parameters, responseType: SeriesListResponse.self)
        return response.data
    }

    func getAnimeById(id: Int) async throws -> Serial {
        let url = baseUrl + "/series/\(id)";
        let response: SerialResponse = try await get(url: url, parameters: nil, responseType: SerialResponse.self)
        return response.data
    }

    func getEpisodeInfo(id: Int) async throws -> Episode {
        let url = baseUrl + "/episodes/\(id)"

        let response: EpisodeResponse = try await get(url: url, parameters: nil, responseType: EpisodeResponse.self)
        return response.data
    }
}
