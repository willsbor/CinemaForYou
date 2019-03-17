//
//  MovieDatabaseManager.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class MovieDatabaseManager {
    
    enum Errors: Error {
        case createURLComponentsFailed
        case createRequestFailed
        case statusCodeInvalid
        case undefinedStatus(Int)
        case dataInNil
    }
    
    enum Result {
        case success(DiscoverResult)
        case status401(statusCode: Int, statusMessage: String)
        case status404(statusCode: Int, statusMessage: String)
        case failed(Error)
    }
    
    enum SortType: String {
        case popularityASC = "popularity.asc"
        case popularityDESC = "popularity.desc"
        case releaseDateASC = "release_date.asc"
        case releaseDateDESC = "release_date.desc"
    }
    
    struct DiscoverResult: Codable, Equatable {
        var page: Int
        var totalResults: Int
        var totalPages: Int
        var results: [MovieData]
        
        enum CodingKeys: String, CodingKey {
            case page
            case totalResults = "total_results"
            case totalPages = "total_pages"
            case results
        }
    }
    
    struct MovieData: Codable, Equatable {
        var id: Int
        var video: Bool
        var title: String
        var popularity: Double
        var posterPath: String?
        var originalLanguage: String
        var originalTitle: String
        var genreIDs: [Int]
        var adult: Bool
        var overview: String
        var releaseDate: String
        var backdropPath: String?
        var voteAverage: Double
        var voteCount: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case video
            case title
            case popularity
            case posterPath = "poster_path"
            case originalLanguage = "original_language"
            case originalTitle = "original_title"
            case genreIDs = "genre_ids"
            case adult
            case overview
            case releaseDate = "release_date"
            case backdropPath = "backdrop_path"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
    
    struct FailedResult: Decodable, Equatable {
        var statusMessage: String
        var statusCode: Int
        
        enum CodingKeys: String, CodingKey {
            case statusMessage = "status_message"
            case statusCode = "status_code"
        }
    }
    
    private enum ServiceEndPoint: String {
        case discoverMovie = "discover/movie"
    }
    
    let appKey = "0015d20b3f7005f8aec145f45a71ad00"
    private let baseURL = URL(string: "https://api.themoviedb.org")!
    private let serviceVersion = "3"
    private let urlSession: URLSession
    
    init(_ sessionConfiguration: URLSessionConfiguration = .default) {
        urlSession = URLSession(configuration: sessionConfiguration)
    }
    
    func discoverMovies(_ sort: SortType, _ page: Int, _ lang: String, _ region: String, _ completionHandler: @escaping (Result) -> Void) {
        
        assert(region.isMatch("^[A-Z]{2}$"), "region format is invalid. (spec: https://developers.themoviedb.org/3/discover/movie-discover)")
        assert(lang.isMatch("^[a-z]{2}-[A-Z]{2}$"), "lang format is invalid. (spec: https://developers.themoviedb.org/3/discover/movie-discover)")
        
        guard var components = URLComponents(url: makeURL(.discoverMovie), resolvingAgainstBaseURL: false) else {
            DispatchQueue.global().async {
                completionHandler(.failed(Errors.createURLComponentsFailed))
            }
            return
        }
        components.queryItems = [
            URLQueryItem(name: "sort_by", value: sort.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "language", value: lang),
            URLQueryItem(name: "region", value: region),
            URLQueryItem(name: "api_key", value: appKey),
        ]
        
        guard let url = components.url else {
            DispatchQueue.global().async {
                completionHandler(.failed(Errors.createRequestFailed))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failed(error))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandler(.failed(Errors.statusCodeInvalid))
                return
            }
            
            do {
                switch statusCode {
                case 200:
                    guard let result = try data?.toDiscoverResult() else {
                        throw Errors.dataInNil
                    }
                    completionHandler(.success(result))
                    
                case 401:
                    guard let (code, message) = try data?.toStatusCodeAndMessage() else {
                        throw Errors.dataInNil
                    }
                    completionHandler(.status401(statusCode: code, statusMessage: message))
                    
                case 404:
                    guard let (code, message) = try data?.toStatusCodeAndMessage() else {
                        throw Errors.dataInNil
                    }
                    completionHandler(.status404(statusCode: code, statusMessage: message))
                    
                default:
                    completionHandler(.failed(Errors.undefinedStatus(statusCode)))
                }
            } catch {
                completionHandler(.failed(error))
            }
        }
        
        task.resume()
    }
    
    private func makeURL(_ endPoint: ServiceEndPoint) -> URL {
        return baseURL.appendingPathComponent(serviceVersion).appendingPathComponent(endPoint.rawValue)
    }
}

extension Data {
    fileprivate func toDiscoverResult() throws -> MovieDatabaseManager.DiscoverResult {
        let decoder = JSONDecoder()
        return try decoder.decode(MovieDatabaseManager.DiscoverResult.self, from: self)
    }
    
    fileprivate func toStatusCodeAndMessage() throws -> (Int, String) {
        let decoder = JSONDecoder()
        let object = try decoder.decode(MovieDatabaseManager.FailedResult.self, from: self)
        return (object.statusCode, object.statusMessage)
    }
}

extension String {
    fileprivate func isMatch(_ pattern: String) -> Bool {
        let re = try! NSRegularExpression(pattern: pattern)
        return re.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) != nil
    }
}
