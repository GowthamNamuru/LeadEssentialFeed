//
//  CacheFeedUseCaseTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 22/02/25.
//

import XCTest
import LeadEssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessage, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save(uniqueImageFeed().models) {_ in }

        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        sut.save(uniqueImageFeed().models) {_ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }

    func test_save_requestsNewCacheInsertionWithTimestampsOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = uniqueImageFeed()
        sut.save(items.models) {_ in }
        store.completeDeletionSuccesfully()

        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(items.local, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        expect(sut: sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        expect(sut: sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccesfully()
            store.completeInsertion(with: insertionError)
        }
    }

    func test_save_successOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        expect(sut: sut, toCompleteWithError: nil) {
            store.completeDeletionSuccesfully()
            store.completeInsertionSuccefully()
        }
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0) })
        sut = nil

        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0) })

        store.completeDeletionSuccesfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
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

    private func expect(sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, action: () -> Void, file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for save to complete")
        var receivedError: Error?
        sut.save(uniqueImageFeed().models) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                break
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }

}
