//
//  FeedLoader.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 05/02/25.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
