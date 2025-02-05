//
//  RemoteFeedLoaderTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 05/02/25.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://example.com/feed"))
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    func get(from url: URL?) { }
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL?) {
        requestedURL = url
    }

    var requestedURL: URL?
}


final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromTheURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
