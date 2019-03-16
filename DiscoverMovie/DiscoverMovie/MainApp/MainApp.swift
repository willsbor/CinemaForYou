//
//  MainApp.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

protocol MovieDiscovering {
    func discoverMoviesNextState(_ user: User, _ type: DiscoverySortType, _ status: DiscoveryStatus?, _ completionHandler: () -> Void)
}

protocol MovieBooking {
    func bookMovie(_ user: User, _ movieItem: MovieItem, _ completionHandler: () -> Void)
}

protocol User {
    var region: String { get }
    var language: String { get }
}

protocol MovieItem {
    
}

struct DiscoveryStatus {
    let totalPages: Int
    let totalMovies: Int
    let currentPage: Int
}

enum DiscoverySortType {
    case releaseDate
}

class MainApp {
    let movieDiscoverProvider: MovieDiscovering
    let movieBookProvider: MovieBooking
    let currentUser: User
    
    var focusMovie: MovieItem?
    
    let discoverySort: DiscoverySortType
    var discoveryStatus: DiscoveryStatus?
    var discoverMovies: [MovieItem]
    
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
}
