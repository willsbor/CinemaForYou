//
//  MainApp+Shared.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

private var sharedMainApp: MainApp?

extension MainApp {
    
    static var shared: MainApp {
        return sharedMainApp!
    }
    
    static func configuration() {
        
        let movieDatabaseManager = MovieDatabaseManager()
        let bookingMovieManager = BookingMovieManager()
        let userManager = UserManager()
        userManager.createUser()
        
        sharedMainApp = MainApp(movieDatabaseManager, bookingMovieManager, userManager)
    }
    
}

extension MovieDatabaseManager: MovieDiscovering {
    func discoverMoviesNextPage(_ user: User, _ type: DiscoverySortType, _ status: DiscoveryStatus?, _ completionHandler: @escaping (DiscoveryStatus, [MovieItem]) -> Void) {

        let currentStatus = status ?? DiscoveryStatus.zero
        
        discoverMovies(type.toMovieDatabaseManagerSortType, currentStatus.currentPage + 1, user.language, user.region) { (result) in
            switch result {
            case .success(let infos):
                let successStatus = DiscoveryStatus(totalPages: infos.totalPages, totalMovies: infos.totalResults, currentPage: infos.page)
                completionHandler(successStatus, infos.results)
                
            case .status401(let statusCode, let statusMessage):
                print("401 \(statusCode), \(statusMessage)")
                completionHandler(currentStatus, [])
                
            case .status404(let statusCode, let statusMessage):
                print("404 \(statusCode), \(statusMessage)")
                completionHandler(currentStatus, [])
                
            case .failed(let error):
                print("error = \(error)")
                completionHandler(currentStatus, [])
            }
        }
    }
}

extension BookingMovieManager: MovieBooking {
    func bookMovie(_ user: User, _ movieItem: MovieItem) -> URL {
        return bookMovie(user.language, user.region)
    }
}

extension UserManager: User {
    var region: String {
        return currentRegion
    }
    
    var language: String {
        return currentLanguage
    }
}

extension DiscoverySortType {
    var toMovieDatabaseManagerSortType: MovieDatabaseManager.SortType {
        switch self {
        case .releaseDate:
            return .releaseDateDESC
        }
    }
}
