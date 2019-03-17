//
//  BookingMovieManagerTests.swift
//  DiscoverMovieTests
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import XCTest

class BookingMovieManagerTests: XCTestCase {

    var bookingManager: BookingMovieManager!
    
    override func setUp() {
        bookingManager = BookingMovieManager()
    }

    override func tearDown() {
        bookingManager = nil
    }

    func testBookMovieByRegion1() {
        
        let resultURL: URL? = bookingManager.bookMovie("zh-US", "US")
        
        XCTAssertEqual(resultURL, URL(string: "https://www.cathaycineplexes.com.sg/")!)
    }
    
    func testBookMovieByRegion2() {
        
        let resultURL: URL? = bookingManager.bookMovie("en-US", "US")
        
        XCTAssertEqual(resultURL, URL(string: "https://www.cathaycineplexes.com.sg/")!)
    }
    
    func testBookMovieByRegion3() {
        
        let resultURL: URL? = bookingManager.bookMovie("zh-TW", "TW")
        
        XCTAssertEqual(resultURL, URL(string: "https://www.cathaycineplexes.com.sg/")!)
    }

}
