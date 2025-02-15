//
//  FeedItem.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 05/02/25.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
