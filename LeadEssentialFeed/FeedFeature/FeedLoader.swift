//
//  FeedLoader.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 05/02/25.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(_ completion: @escaping (LoadFeedResult) -> Void)
}
