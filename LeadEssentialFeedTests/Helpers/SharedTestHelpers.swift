//
//  SharedTestHelpers.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 26/02/25.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
