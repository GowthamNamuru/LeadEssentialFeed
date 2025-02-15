//
//  RemoteFeedLoader.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 09/02/25.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = LoadFeedResult

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(_ completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self]  result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
}
