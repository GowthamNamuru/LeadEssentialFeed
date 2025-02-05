//
//  RemoteFeedLoaderTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 05/02/25.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    func load() {
        client.get(from: URL(string: "https://example.com/feed"))
    }
}

protocol HTTPClient {
    func get(from url: URL?)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL?) {
        requestedURL = url
    }
}


final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromTheURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestsDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
