//
//  RemoteFeedLoaderTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 05/02/25.
//

import XCTest

class RemoteFeedLoader {

}

class HTTPClient {
    var requestedURL: URL?
}


final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromTheURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
}
