//
//  RemoteFeedLoader.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 09/02/25.
//

import Foundation

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(_ completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case .success(let data, let response):
                do {
                   let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
//                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }

    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
           let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}
