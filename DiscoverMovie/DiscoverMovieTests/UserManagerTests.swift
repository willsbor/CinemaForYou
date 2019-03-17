//
//  UserManagerTests.swift
//  DiscoverMovieTests
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import XCTest

class UserManagerTests: XCTestCase {

    var userManager: UserManager!
    var mockSystemProvider: MockSystemProvider!
    
    override func setUp() {
        mockSystemProvider = MockSystemProvider()
        userManager = UserManager()
        
        setSystemUtils(mockSystemProvider)
    }

    override func tearDown() {
        setSystemUtils(nil)
        
        userManager = nil
        mockSystemProvider = nil
    }

    func testCreateUser() {
        
        mockSystemProvider.specificRegion = "JP"
        mockSystemProvider.specificLanguage = "ja"
        
        userManager.createUser()
        
        XCTAssertEqual(userManager.currentLanguage, "ja-JP")
        XCTAssertEqual(userManager.currentRegion, "JP")
    }

}
