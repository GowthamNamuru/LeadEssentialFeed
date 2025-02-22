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
    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                store.insert(items)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deletCachedFeedCallCount: Int = 0
    var insertionCacheCallCount: Int = 0

    private var deletionCompletions = [DeletionCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccesfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem]) {
        insertionCacheCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deletCachedFeedCallCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)

        XCTAssertEqual(store.deletCachedFeedCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertionCacheCallCount, 0)
    }

    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccesfully()

        XCTAssertEqual(store.insertionCacheCallCount, 1)
    }

    // MARK: - Helper

    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
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
}
