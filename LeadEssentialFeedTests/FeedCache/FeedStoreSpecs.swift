//
//  FeedStoreSpecs.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 08/03/25.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_noSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValueOnNonEmptyCache()
    func test_retrieve_noSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrive_deliversFailureOnRetrievalError()
    func test_retrive_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}
