//
//  MovieDatabaseManagerTests.swift
//  DiscoverMovieTests
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import XCTest

class MovieDatabaseManagerTests: XCTestCase {

    class MockURLProtocol: URLProtocol {
        
        static var responseStatusCode = 200
        static var responseBody: Data?
        static var inputRequest: URLRequest?
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            MockURLProtocol.inputRequest = request
            return request
        }
        
        override func startLoading() {
            print("startLoading ...")
            DispatchQueue.global().async {
                let response = HTTPURLResponse(url: self.request.url!, statusCode: MockURLProtocol.responseStatusCode, httpVersion: "1.1", headerFields: nil)!
                
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = MockURLProtocol.responseBody {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        override func stopLoading() {
            print("stopLoading ...")
        }
    }
    
    var movieDatabaseManager: MovieDatabaseManager!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        movieDatabaseManager = MovieDatabaseManager(configuration)
    }

    override func tearDown() {
        movieDatabaseManager = nil
    }

    func testDiscoverMoviesWith200() {
        
        /// Given
        let (answer, responseBody): (MovieDatabaseManager.DiscoverResult, Data) = makeFakeDiscoverResult("DiscoverResult200-1")
        MockURLProtocol.responseBody = responseBody
        MockURLProtocol.responseStatusCode = 200
        let page = 3
        let sort = MovieDatabaseManager.SortType.releaseDateDESC
        let region = "TW"
        let lang = "zh-TW"
        
        /// When
        let expect = expectation(description: "wait for discovery")
        var result: MovieDatabaseManager.Result<MovieDatabaseManager.DiscoverResult>!
        movieDatabaseManager.discoverMovies(sort, page, lang, region) { (r) in
            result = r
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3)
        
        /// Then
        assertInputDiscoverRequest(sort, page, lang, region)
        
        switch result! {
        case .success(let data):
            XCTAssertEqual(data, answer)
            XCTAssertEqual(data.page, page)
        case .status401, .status404, .failed:
            XCTFail()
        }
    }
    
    func testDiscoverMoviesWith401() {
        
        /// Given
        let (answer, responseBody): (MovieDatabaseManager.FailedResult, Data) = makeFakeDiscoverResult("DiscoverResult401-1")
        MockURLProtocol.responseBody = responseBody
        MockURLProtocol.responseStatusCode = 401
        let page = 3
        let sort = MovieDatabaseManager.SortType.releaseDateDESC
        let region = "TW"
        let lang = "zh-TW"
        
        /// When
        let expect = expectation(description: "wait for discovery")
        var result: MovieDatabaseManager.Result<MovieDatabaseManager.DiscoverResult>!
        movieDatabaseManager.discoverMovies(sort, page, lang, region) { (r) in
            result = r
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3)
        
        /// Then
        assertInputDiscoverRequest(sort, page, lang, region)
        
        switch result! {
        case .status401(let statusCode, let statusMessage):
            XCTAssertEqual(statusCode, answer.statusCode)
            XCTAssertEqual(statusMessage, answer.statusMessage)
        case .success, .status404, .failed:
            XCTFail()
        }
    }
    
    func testDiscoverMoviesWith404() {
        
        /// Given
        let (answer, responseBody): (MovieDatabaseManager.FailedResult, Data) = makeFakeDiscoverResult("DiscoverResult404-1")
        MockURLProtocol.responseBody = responseBody
        MockURLProtocol.responseStatusCode = 404
        let page = 3
        let sort = MovieDatabaseManager.SortType.releaseDateDESC
        let region = "TW"
        let lang = "zh-TW"
        
        /// When
        let expect = expectation(description: "wait for discovery")
        var result: MovieDatabaseManager.Result<MovieDatabaseManager.DiscoverResult>!
        movieDatabaseManager.discoverMovies(sort, page, lang, region) { (r) in
            result = r
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3)
        
        /// Then
        assertInputDiscoverRequest(sort, page, lang, region)
        
        switch result! {
        case .status404(let statusCode, let statusMessage):
            XCTAssertEqual(statusCode, answer.statusCode)
            XCTAssertEqual(statusMessage, answer.statusMessage)
        case .success, .status401, .failed:
            XCTFail()
        }
    }
    
    func testMovieDetail() {
        /// Given
        let (answer, responseBody): (MovieDatabaseManager.MovieDetailData, Data) = makeFakeDiscoverResult("DetailResult200-1")
        MockURLProtocol.responseBody = responseBody
        MockURLProtocol.responseStatusCode = 200
        let movieID = 299537
        let lang = "zh-TW"
        
        /// When
        let expect = expectation(description: "wait for discovery")
        var result: MovieDatabaseManager.Result<MovieDatabaseManager.MovieDetailData>!
        movieDatabaseManager.movieDetail(movieID, lang, { (r) in
            result = r
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3)
        
        /// Then
        assertInputDiscoverRequest(movieID, lang)
        
        switch result! {
        case .success(let data):
            XCTAssertEqual(data, answer)
            XCTAssertEqual(data.id, movieID)
        case .status401, .status404, .failed:
            XCTFail()
        }
    }
    
    private func assertInputDiscoverRequest(_ movieID: Int, _ lang: String) {
        XCTAssertEqual(MockURLProtocol.inputRequest!.httpMethod, "GET")
        let resultComponent = URLComponents(url: MockURLProtocol.inputRequest!.url!, resolvingAgainstBaseURL: false)!
        
        XCTAssertTrue(resultComponent.path.hasSuffix("/\(movieID)"))
        
        XCTAssertEqual(resultComponent.queryItems!.count, 2)
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "language" && $0.value == "\(lang)" }))
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "api_key" && $0.value == movieDatabaseManager.appKey }))
    }
    
    private func assertInputDiscoverRequest(_ sort: MovieDatabaseManager.SortType, _ page: Int, _ lang: String, _ region: String) {
        XCTAssertEqual(MockURLProtocol.inputRequest!.httpMethod, "GET")
        let resultComponent = URLComponents(url: MockURLProtocol.inputRequest!.url!, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(resultComponent.queryItems!.count, 5)
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "sort_by" && $0.value == sort.rawValue }))
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "page" && $0.value == "\(page)" }))
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "language" && $0.value == "\(lang)" }))
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "region" && $0.value == "\(region)" }))
        XCTAssertTrue(resultComponent.queryItems!.contains(where: { $0.name == "api_key" && $0.value == movieDatabaseManager.appKey }))
    }
    
    private func makeFakeDiscoverResult<T: Decodable>(_ fileName: String) -> (T, Data) {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: fileName, ofType: "json")!
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let decoder = JSONDecoder()
        let object = try! decoder.decode(T.self, from: jsonData)

        return (object, jsonData)
    }
}
