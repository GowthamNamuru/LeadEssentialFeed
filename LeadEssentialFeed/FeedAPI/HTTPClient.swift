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
    ///  The completion handler can be invoked in any thread.
    ///  Clients are responsible to dispatch to appropiate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

