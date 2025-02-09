//
//  RemoteFeedLoaderTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 05/02/25.
//

import XCTest
@testable import LeadEssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromTheURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error?]()
        sut.load { capturedErrors.append($0) }

        let clientError = NSError(domain: "Test", code: .zero)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com/feed")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        private var messages = [(url: URL, completion: (Error) -> Void)]()

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
