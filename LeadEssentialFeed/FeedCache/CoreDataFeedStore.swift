//
//  CoreDataFeedStore.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 09/03/25.
//

import CoreData

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

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescritpion: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
