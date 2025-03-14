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
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}
