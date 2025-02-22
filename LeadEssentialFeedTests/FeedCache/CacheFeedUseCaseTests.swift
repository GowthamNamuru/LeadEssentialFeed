//
//  CacheFeedUseCaseTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 22/02/25.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {

    }
}

class FeedStore {
    var deletCachedFeedCallCount: Int = 0
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deletCachedFeedCallCount, 0)
    }
}
