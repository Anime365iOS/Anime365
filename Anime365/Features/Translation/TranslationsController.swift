//
//  TranslationsController.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import Foundation
import Alamofire

class TranslationListController {
    
    static let shared = TranslationListController()
    
    private let baseURL = "https://smotret-anime.com/api/translations/"
    
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 10
        return Session(configuration: configuration)
    }()
    
    private enum TranslationAPIError: Error {
        case emptyResponse
        case invalidResponse
        case requestFailed
        case serverError
    }
    
    func getTranslationList(completion: @escaping (Result<[Translation], Error>) -> Void) {
        sessionManager.request(baseURL).validate().responseDecodable(of: TranslationResponse.self) { response in
            switch response.result {
            case .success(let translationResponse):
                if translationResponse.data.isEmpty {
                    completion(.failure(TranslationAPIError.emptyResponse))
                } else {
                    completion(.success(translationResponse.data))
                }
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 400...499:
                        completion(.failure(TranslationAPIError.invalidResponse))
                    case 500...599:
                        completion(.failure(TranslationAPIError.serverError))
                    default:
                        completion(.failure(TranslationAPIError.requestFailed))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}

