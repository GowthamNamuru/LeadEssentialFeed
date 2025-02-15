//
//  RemoteFeedLoaderTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 05/02/25.
//

import XCTest
import LeadEssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromTheURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)

        sut.load{_ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)

        sut.load {_ in }
        sut.load {_ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "Test", code: .zero)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach({ index, code in
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        })

    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            let emptyJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }


    func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
        let (sut, client) = makeSUT()

        let (item1, item1JSON) = makeItem(id: UUID(), imageURL: URL(string: "http://a-url.com")!)

        let (item2, item2JSON) = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://a-url.com")!)

        let items = [item1, item2]

        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON([item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json)
        }
    }


    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://example.com/feed")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load({ capturedResults.append($0) })

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com/feed")!, client: HTTPClient = HTTPClientSpy(),
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated", file: file, line: line)
        }
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageUrl: imageURL)

        let itemJSON = [
            "id": id.uuidString,
            "location": location,
            "description": description,
            "image": imageURL.absoluteString
        ].compactMapValues({ $0 as Any })
        return (item, itemJSON)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
