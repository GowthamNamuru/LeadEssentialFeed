//
//  CacheFeedUseCaseTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 22/02/25.
//

import XCTest
import LeadEssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if error == nil {
                store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessage, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) {_ in }

        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items) {_ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
    }

    func test_save_requestsNewCacheInsertionWithTimestampsOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) {_ in }
        store.completeDeletionSuccesfully()

        XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(items, timestamp)])
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
        var receivedResults = [Error?]()
        sut?.save([uniqueItem()], completion: { receivedResults.append($0) })
        sut = nil

        store.completeDeletion(with: anyNSError())
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

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }

    private func expect(sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, action: () -> Void, file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for save to complete")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }

    private class FeedStoreSpy: FeedStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void

        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([FeedItem], Date)
        }


        private(set) var receivedMessage = [ReceivedMessage]()

        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()

        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessage.append(.deleteCacheFeed)
        }

        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }

        func completeDeletionSuccesfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }

        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessage.append(.insert(items, timestamp))
        }

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }

        func completeInsertionSuccefully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }

}
