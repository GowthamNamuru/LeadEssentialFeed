//
//  HTTPClient.swift
//  LeadEssentialFeed
//
//  Created by Gowtham Namuru on 15/02/25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

