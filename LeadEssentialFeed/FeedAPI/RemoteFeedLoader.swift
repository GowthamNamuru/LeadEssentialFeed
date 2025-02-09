//
//  RemoteFeedLoader.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 09/02/25.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
    }

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(_ completion: @escaping (Error) -> Void = {_ in }) {
        client.get(from: url, completion: {_ in
            completion(.connectivity)
        })
    }
}
