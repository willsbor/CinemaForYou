//
//  MainApp+ViewControlling.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

extension MainApp: DiscoverMovieControlling, MovieDetailControlling {
    var isFinal: Bool {
        return discoveryStatus?.isFinal ?? false
    }
    
    func currentMovies() -> [MovieDisplayAbstract] {
        return discoverMovies
    }
    
    func getMovie(by index: Int) -> MovieDisplayAbstract? {
        if index < discoverMovies.count {
            return discoverMovies[index]
        } else {
            return nil
        }
    }
    
    func refreshMovies(_ completionHandler: @escaping () -> Void) {
        requestDiscoverMoviesFromFirstPage { (_, _) in
            completionHandler()
        }
    }
    
    func requestMoreMovies(_ completionHandler: @escaping (Int, Int) -> Void) {
        requestDiscoverMoviesNextPage { (sendRequest, oldItems, newItems) in
            guard sendRequest else {
                return
            }
            
            completionHandler(oldItems.count, newItems.count)
        }
    }
    
    func getFocusMovieDetail() -> MovieDisplayDetail? {
        return focusMovie
    }
    
    func getBookingFocusMovieURL() -> URL {
        guard let focusMovie = focusMovie else {
            preconditionFailure()
        }
        
        return movieBookProvider.bookMovie(currentUser, focusMovie)
    }
}

extension MovieItem: MovieDisplayAbstract, MovieDisplayDetail {
    var title: String {
        switch (info.title.isEmpty, info.originalTitle.isEmpty) {
        case (false, false):
            if info.title != info.originalTitle {
                return "\(info.title) (\(info.originalTitle))"
            } else {
                return info.title
            }
        case (true, true):
            return "<no title>"
        case (true, false):
            return info.originalTitle
        case (false, true):
            return info.title
        }
    }
    
    var popularity: Double {
        return info.popularity
    }
    
    var posterImage: URL? {
        guard let path = info.posterPath else {
            print("posterPath of \(info.id) is nil")
            return nil
        }
        var url = URL(string: "https://image.tmdb.org/t/p/w500")
        url?.appendPathComponent(path)
        return url
    }
    
    var backdropImage: URL? {
        guard let path = info.backdropPath else {
            print("backdropPath of \(info.id) is nil")
            return nil
        }
        var url = URL(string: "https://image.tmdb.org/t/p/w500")
        url?.appendPathComponent(path)
        return url
    }
    
    var synopsis: String {
        return detail?.overview ?? "<null>"
    }
    
    var genres: String {
        return detail?.genres.map { $0.name }.joined(separator: ", ") ?? "<null>"
    }
    
    var language: String {
        return "original: \(detail?.originalLanguage ?? "<null>")\nspoken: \(detail?.spokenLanguages.map { $0.name }.joined(separator: ", ") ?? "<null>")"
    }
    
    var duration: String {
        if let runtime = detail?.runtime {
            return "\(runtime) mins"
        } else {
            return "<null>"
        }
        
    }
    
    var releaseDate: String {
        return formattedReleaseDate ?? info.releaseDate
    }
}
