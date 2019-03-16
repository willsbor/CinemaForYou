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
        
        var resultURL: URL?
        let expect = expectation(description: "wait for book a movie")
        bookingManager.bookMovie("zh-US", "US") { (url) in
            resultURL = url
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 3)
        
        XCTAssertEqual(resultURL, URL(string: "https://www.cathaycineplexes.com.sg/")!)
    }
    
    func testBookMovieByRegion2() {
        
        var resultURL: URL?
        let expect = expectation(description: "wait for book a movie")
        bookingManager.bookMovie("en-US", "US") { (url) in
            resultURL = url
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 3)
        
        XCTAssertEqual(resultURL, URL(string: "https://www.cathaycineplexes.com.sg/")!)
    }
    
    func testBookMovieByRegion3() {
        
        var resultURL: URL?
        let expect = expectation(description: "wait for book a movie")
        bookingManager.bookMovie("zh-TW", "TW") { (url) in
            resultURL = url
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 3)
        
        XCTAssertEqual(resultURL, URL(string: "https://www.cathaycineplexes.com.sg/")!)
    }

}
