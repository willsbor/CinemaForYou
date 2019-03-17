//
//  UserManager.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class UserManager: SystemCapability {
    private(set) var currentRegion: String = "undef"
    private(set) var currentLanguage: String = "undef"
    
    func createUser() {
        currentRegion = systemUtils.getRegion()
        currentLanguage = "\(systemUtils.getLanguage())-\(currentRegion)"
    }
}
