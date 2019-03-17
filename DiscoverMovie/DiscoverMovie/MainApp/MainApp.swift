//
//  MainApp.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

typealias MovieItem = MovieDatabaseManager.MovieData

struct DiscoveryStatus {
    let totalPages: Int
    let totalMovies: Int
    let currentPage: Int
}

protocol MovieDiscovering {
    func discoverMoviesNextPage(_ user: User, _ type: DiscoverySortType, _ status: DiscoveryStatus?, _ completionHandler: @escaping (DiscoveryStatus, [MovieItem]) -> Void)
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
    let movieDiscoverProvider: MovieDiscovering
    let movieBookProvider: MovieBooking
    let currentUser: User
    
    private(set) var focusMovie: MovieItem?
    
    let discoverySort: DiscoverySortType
    private(set) var discoveryStatus: DiscoveryStatus?
    private(set) var discoverMovies: [MovieItem]
    
    var movieDiscoverMoreDataDelegate: Any?
    
    private let lockQueue = DispatchQueue(label: "com.xxx.main_app.lock")
    private var requestingDiscoverMovies = false
    
    init(_ movieDiscoverProvider: MovieDiscovering,
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
    
    func requestDiscoverMoviesNextPage(_ completionHandler: @escaping (_ sendRequest: Bool, _ oldItems: [MovieItem], _ newItems: [MovieItem]) -> Void) {
        
        lockQueue.sync {
            if requestingDiscoverMovies {
                DispatchQueue.global().async {
                    completionHandler(false, self.discoverMovies, [])
                }
                
                return
            }
            requestingDiscoverMovies = true
            
            movieDiscoverProvider.discoverMoviesNextPage(currentUser, discoverySort, discoveryStatus) { (status, newItems) in
                self.lockQueue.sync {
                    self.discoveryStatus = status
                    
                    let oldItems = self.discoverMovies
                    self.discoverMovies.append(contentsOf: newItems)
                    
                    self.requestingDiscoverMovies = false
                    DispatchQueue.global().async {
                        completionHandler(true, oldItems, newItems)
                    }
                }
            }
        }
    }
}

extension DiscoveryStatus {
    var nextPage: Int {
        return currentPage + 1
    }
    
    var isFinial: Bool {
        return totalPages == currentPage
    }
    
    static let zero = DiscoveryStatus(totalPages: 0, totalMovies: 0, currentPage: 0)
}
