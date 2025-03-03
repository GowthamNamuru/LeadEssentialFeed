//
//  LocalFeedImage.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 23/02/25.
//

public struct LocalFeedImage: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL

    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
