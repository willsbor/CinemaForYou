//
//  SystemProvider.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class SystemProvider {
    static let shared = SystemProvider()
    
    func getRegion() -> String {
        return "TW"
    }
    
    func getLanguage() -> String {
        return "zh-TW"
    }
    
    func currentDate() -> Date {
        return Date()
    }
}
