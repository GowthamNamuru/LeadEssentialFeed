//
//  ValidateFeedCacheUseCaseTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 26/02/25.
//

import XCTest
import LeadEssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessage, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCacheFeed])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }


    func test_validateCache_doesNotDeleteOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }

    func test_validateCache_deletesCacheOnExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCacheFeed])
    }

    func test_validateCache_deletesExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT()

        sut.validateCache()

        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessage, [.retrieval, .deleteCacheFeed])
    }

    func test_validateCahce_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache()
        sut = nil

        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessage, [.retrieval])
    }

    // MARK: - Helper
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
