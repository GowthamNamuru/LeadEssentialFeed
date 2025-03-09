//
//  CoreDataFeedStore.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 09/03/25.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init () {
        
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    public func insert(_ feed: [LeadEssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
