//
//  FeedStore.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 22/02/25.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    ///  The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropiate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    ///  The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropiate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    ///  The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropiate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
