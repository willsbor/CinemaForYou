//
//  BookingMovieManager.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class BookingMovieManager {
    
    typealias Result = URL
    
    func bookMovie(_ lang: String, _ region: String) -> URL {
        return getURL(by: lang, with: region)
    }
    
    private func getURL(by lang: String, with region: String) -> URL {
        switch (lang.lowercased(), region.lowercased()) {
        case (_, "us"):
            return URL(string: "https://www.cathaycineplexes.com.sg/")!
        default:
            return URL(string: "https://www.cathaycineplexes.com.sg/")!
        }
    }
}
