//
//  MainApp+ViewControlling.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

extension MainApp: DiscoverMovieControlling, MovieDetailControlling {
    var discoverDelegate: MoviesChangeDelegate? {
        get {
            return movieDiscoverMoreDataDelegate as? MoviesChangeDelegate
        }
        set {
            movieDiscoverMoreDataDelegate = newValue
        }
    }
    
    func currentMovies() -> [MovieResultType] {
        var results = discoverMovies.map { MovieResultType.normal($0) }
        if discoveryStatus?.isFinial ?? false {
            results.append(.finial)
        } else {
            results.append(.elseLeft)
        }
        return results
    }
    
    func getMovie(by index: Int) -> MovieResultType {
        if index < discoverMovies.count {
            return .normal(discoverMovies[index])
        } else {
            return .elseLeft
        }
    }
    
    func refreshMovies(_ completionHandler: @escaping () -> Void) {
        requestDiscoverMoviesFromFirstPage { (_, _) in
            completionHandler()
        }
    }
    
    func requestMoreMovies() {
        requestDiscoverMoviesNextPage { (sendRequest, oldItems, newItems) in
            guard sendRequest else {
                return
            }
            
            self.discoverDelegate?.begin()
            
            self.discoverDelegate?.movieDataDidChange(indexes: [oldItems.count], type: .replace)
            
            var insertIndexes: [Int] = []
            
            let start = oldItems.count + 1
            let end = oldItems.count + newItems.count - 1
            if start < end {
                for i in start...end {
                    insertIndexes.append(i)
                }
            }
            
            insertIndexes.append(oldItems.count + newItems.count) //< .finial or .elseLeft
            
            self.discoverDelegate?.movieDataDidChange(indexes: insertIndexes, type: .insert)
            
            self.discoverDelegate?.end()
        }
    }
    
    func getFocusMovieDetail() -> MovieDisplayDetail? {
        return focusMovie
    }
    
    func getBookingFocusMovieURL() -> URL {
        guard let focusMovie = focusMovie else {
            // TODO: need focus or should throw error or nil...
            preconditionFailure()
        }
        
        return movieBookProvider.bookMovie(currentUser, focusMovie)
    }
}

extension MovieItem: MovieDisplayAbstract, MovieDisplayDetail {
    var posterImage: URL? {
        guard let path = posterPath else {
            print("posterPath of \(id) is nil")
            return nil
        }
        var url = URL(string: "https://image.tmdb.org/t/p/w500")
        url?.appendPathComponent(path)
        print("p: \(url!)")
        return url
    }
    
    var backdropImage: URL? {
        guard let path = backdropPath else {
            print("backdropPath of \(id) is nil")
            return nil
        }
        var url = URL(string: "https://image.tmdb.org/t/p/w500")
        url?.appendPathComponent(path)
        print("b: \(url!)")
        return url
    }
    
    var synopsis: String {
        return "TODO: synopsis"
    }
    
    var genres: String {
        return "TODO: genres"
    }
    
    var language: String {
        return "TODO: language"
    }
    
    var duration: String {
        return "TODO: duration"
    }
}
