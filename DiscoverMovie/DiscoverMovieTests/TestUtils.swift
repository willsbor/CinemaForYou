//
//  TestUtils.swift
//  DiscoverMovieTests
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class MockSystemProvider: SystemProvider {
    
    var specificRegion: String?
    override func getRegion() -> String {
        if let value = specificRegion {
            return value
        } else {
            return super.getRegion()
        }
    }
    
    var specificLanguage: String?
    override func getLanguage() -> String {
        if let value = specificLanguage {
            return value
        } else {
            return super.getLanguage()
        }
    }
    
    var specificCurrentDate: Date?
    override func currentDate() -> Date {
        if let value = specificCurrentDate {
            return value
        } else {
            return super.currentDate()
        }
    }
}
