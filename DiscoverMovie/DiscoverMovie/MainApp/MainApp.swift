//
//  MainApp.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class MovieItem {
    var info: MovieDatabaseManager.MovieData
    var detail: MovieDatabaseManager.MovieDetailData?
    
    var formattedReleaseDate: String?
    
    init(_ info: MovieDatabaseManager.MovieData) {
        self.info = info
    }
}

struct DiscoveryStatus: Equatable {
    let totalPages: Int
    let totalMovies: Int
    let currentPage: Int
}

protocol MovieDatabase {
    func discoverMoviesNextPage(_ user: User, _ type: DiscoverySortType, _ status: DiscoveryStatus?, _ completionHandler: @escaping (DiscoveryStatus, [MovieItem]) -> Void)
    func detailMovie(_ movieItem: MovieItem, _ user: User, _ completionHandler: @escaping (MovieItem) -> Void)
}

protocol MovieBooking {
    func bookMovie(_ user: User, _ movieItem: MovieItem) -> URL
}

protocol User {
    var region: String { get }
    var language: String { get }
}

enum DiscoverySortType {
    case releaseDate
}

class MainApp {
    let movieDiscoverProvider: MovieDatabase
    let movieBookProvider: MovieBooking
    let currentUser: User
    
    private(set) var focusMovie: MovieItem?
    
    let discoverySort: DiscoverySortType
    private(set) var discoveryStatus: DiscoveryStatus?
    private(set) var discoverMovies: [MovieItem]
    
    var movieDiscoverMoreDataDelegate: Any?
    
    private let lockQueue = DispatchQueue(label: "com.xxx.main_app.lock")
    private var requestingDiscoverMovies = false
    private var dateFormatter = DateFormatter()
    
    init(_ movieDiscoverProvider: MovieDatabase,
         _ movieBookProvider: MovieBooking,
         _ currentUser: User) {
        
        self.movieBookProvider = movieBookProvider
        self.movieDiscoverProvider = movieDiscoverProvider
        self.currentUser = currentUser
        
        self.focusMovie = nil
        
        self.discoverySort = .releaseDate
        self.discoveryStatus = nil
        self.discoverMovies = []
    }
    
    func focusMovie(_ index: Int) {
        focusMovie = discoverMovies[index]
    }
    
    func defocusMovie() {
        focusMovie = nil
    }
    
    func requestFocusMovieDetail(_ completionHandler: @escaping () -> Void) {
        guard let focusMovie = focusMovie else {
            preconditionFailure()
        }
        
        movieDiscoverProvider.detailMovie(focusMovie, currentUser) { (item) in
            completionHandler()
        }
    }
    
    func requestDiscoverMoviesFromFirstPage(_ completionHandler: @escaping (_ sendRequest: Bool, _ items: [MovieItem]) -> Void) {
        lockQueue.sync {
            if requestingDiscoverMovies {
                DispatchQueue.global().async {
                    completionHandler(false, self.discoverMovies)
                }
                
                return
            }
            requestingDiscoverMovies = true
            
            discoveryStatus = nil
            
            movieDiscoverProvider.discoverMoviesNextPage(currentUser, discoverySort, discoveryStatus) { (status, nextMovies) in
                
                let nextMovies = self.formatMovieItems(nextMovies)
                
                self.lockQueue.sync {
                    self.discoverMovies = nextMovies
                    self.discoveryStatus = status
                    
                    self.requestingDiscoverMovies = false
                    DispatchQueue.global().async {
                        completionHandler(true, nextMovies)
                    }
                }
            }
        }
    }
    
    func requestDiscoverMoviesNextPage(_ completionHandler: @escaping (_ sendRequest: Bool, _ oldMovies: [MovieItem], _ newItems: [MovieItem]) -> Void) {
        
        lockQueue.sync {
            if requestingDiscoverMovies {
                DispatchQueue.global().async {
                    completionHandler(false, self.discoverMovies, [])
                }
                
                return
            }
            requestingDiscoverMovies = true
            
            movieDiscoverProvider.discoverMoviesNextPage(currentUser, discoverySort, discoveryStatus) { (status, nextMovies) in
                
                let nextMovies = self.formatMovieItems(nextMovies)
                
                self.lockQueue.sync {
                    self.discoveryStatus = status
                    
                    let oldMovies = self.discoverMovies
                    self.discoverMovies.append(contentsOf: nextMovies)
                    
                    self.requestingDiscoverMovies = false
                    DispatchQueue.global().async {
                        completionHandler(true, oldMovies, nextMovies)
                    }
                }
            }
        }
    }
    
    private func formatMovieItems(_ movies: [MovieItem]) -> [MovieItem] {
        return movies.map({ (item) -> MovieItem in
            if let date = item.info.releaseDate.releaseDateToDate() {
                item.formattedReleaseDate = format(releaseDate: date)
            }
            return item
        })
    }
    
    private func format(releaseDate: Date) -> String {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: currentUser.language)
        dateFormatter.calendar = Calendar.current
        
        return dateFormatter.string(from: releaseDate)
    }
}

extension DiscoveryStatus {
    var nextPage: Int {
        return currentPage + 1
    }
    
    var isFinial: Bool {
        return totalPages <= currentPage
    }
    
    static let unknown = DiscoveryStatus(totalPages: 0, totalMovies: -1, currentPage: 0)
}

extension String {
    fileprivate func releaseDateToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.calendar = Calendar(identifier: .gregorian)

        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        
        return date
    }
}
