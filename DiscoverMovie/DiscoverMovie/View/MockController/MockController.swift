//
//  MockController.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class MockController: DiscoverMovieControlling, SystemCapability, MovieDetailControlling {
    
    static let shared = MockController()
    
    struct MovieItem: MovieDisplayAbstract, MovieDisplayDetail {
        let posterImage: URL?
        let backdropImage: URL?
        let title: String
        let popularity: Double
        
        let synopsis: String
        let genres: String
        let language: String
        let duration: String
        
        init(posterImage: URL?, backdropImage: URL?, title: String, popularity: Double) {
            self.posterImage = posterImage
            self.backdropImage = backdropImage
            self.title = title
            self.popularity = popularity
            self.synopsis = "漫画中的初代“惊奇女士”原名Carol Danvers，她曾经是一名美国空军情报局探员，暗恋惊奇先生。此后她得到了超能力，成为“惊奇女士”，在漫画中是非常典型的女性英雄人物。她可以吸收并控制任意形态的能量，拥有众多超能力。《惊奇队长》将是漫威首部以女性超级英雄为主角的电影。"
            self.genres = ""
            self.language = ""
            self.duration = ""
        }
    }
    
    var discoverDelegate: MoviesChangeDelegate? = nil
    
    var movies: [MovieItem] = [
        MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg1")!,
                  backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg1")!,
                  title: "惊奇队长 (Captain Marvel)",
                  popularity: 585.976),
        MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                  backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                  title: "惊奇队长 (Captain Marvel)",
                  popularity: 585.976),
        MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                  backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                  title: "惊奇队长 (Captain Marvel)",
                  popularity: 585.976),
        MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                  backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                  title: "惊奇队长 (Captain Marvel)",
                  popularity: 585.976),
        MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                  backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                  title: "惊奇队长 (Captain Marvel)",
                  popularity: 585.976),
        ]
    
    var focusMovie: MovieItem?
    
    var isFinial: Bool {
        return false
    }
    
    func currentMovies() -> [MovieResultType] {
        var results = movies.map { MovieResultType.normal($0) }
        if isFinial {
            results.append(.finial)
        } else {
            results.append(.elseLeft)
        }
        return results
    }
    
    func getMovie(by index: Int) -> MovieResultType {
        if index < movies.count {
            return .normal(movies[index])
        } else {
            return .elseLeft
        }
    }
    
    func refreshMovies(_ completionHandler: @escaping () -> Void) {
        systemUtils.dispatchAfter(3000) {
            completionHandler()
        }
    }
    
    var isRequestingMoreMovies = false
    func requestMoreMovies() {
        
        guard !isRequestingMoreMovies else {
            return
        }
        isRequestingMoreMovies = true
        
        let newItems: [MovieItem] = [
            MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                      backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                      title: "惊奇队长 (Captain Marvel)",
                      popularity: 585.976),
            MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                      backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                      title: "惊奇队长 (Captain Marvel)",
                      popularity: 585.976),
            MovieItem(posterImage: URL(string: "https://image.tmdb.org/t/p/w500/vELsvyKySjI05znoNfB4gknfLf4.jpg")!,
                      backdropImage: URL(string: "https://image.tmdb.org/t/p/w500/w2PMyoyLU22YvrGK3smVM9fW1jj.jpg")!,
                      title: "惊奇队长 (Captain Marvel)",
                      popularity: 585.976),
            ]
        
        systemUtils.dispatchAfter(3000) {
            
            let oldItems = self.movies
            self.movies.append(contentsOf: newItems)
            
            DispatchQueue.main.async {
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
            
            
            self.isRequestingMoreMovies = false
        }
    }
    
    func focusMovie(_ index: Int) {
        focusMovie = movies[index]
    }
    
    func getFocusMovieDetail() -> MovieDisplayDetail? {
        return focusMovie
    }
    
    func defocusMovie() {
        focusMovie = nil
    }
    
    func getBookingFocusMovieURL() -> URL {
        return URL(string: "https://www.cathaycineplexes.com.sg/")!
    }
}
