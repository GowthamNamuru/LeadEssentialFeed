//
//  RemoteFeedItem.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 23/02/25.
//

internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
