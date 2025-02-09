//
//  RemoteFeedLoader.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 09/02/25.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(_ completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: {error, response in
            if (response != nil) {
                completion(.invalidData)

            } else {
                completion(.connectivity)
            }
        })
    }
}
