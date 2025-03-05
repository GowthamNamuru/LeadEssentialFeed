//
//  CodableFeedStoreTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 03/03/25.
//

import XCTest
import LeadEssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            feed.map({ $0.local })
        }
    }

    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL

        public init(id: UUID, description: String?, location: String?, url: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.url = url
        }

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }

        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}


final class CodableFeedStoreTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        setUpEmptyStoreState()
    }

    override func setUp() {
        super.setUp()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_noSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsetingToEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.insert(feed.local, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        expect(sut, toRetrieve: .found(feed: feed.local, timestamp: timestamp))
    }

    func test_retrieve_noSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.insert(feed, timestamp: timestamp) { insertionError in
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFound), .found(secondFound)):
                        XCTAssertEqual(firstFound.feed, feed)
                        XCTAssertEqual(secondFound.feed, feed)

                        XCTAssertEqual(firstFound.timestamp, timestamp)
                        XCTAssertEqual(secondFound.timestamp, timestamp)
                    default:
                        XCTFail("Expected retrieving twice from non empty cache to deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }


    // MARK:- Helpers
    private func makeSUT() -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecifiStoreURL())
        trackForMemoryLeaks(sut)
        return sut
    }

    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
                break

            case let (.found(expectedFeed, expectedTimeStamp), .found(receivedFeed, receivedTimestamp)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimeStamp, receivedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func testSpecifiStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory,
                                 in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecifiStoreURL())
    }


    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
}
