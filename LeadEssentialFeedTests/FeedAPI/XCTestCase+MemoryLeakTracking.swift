//
//  XCTestCase+MemoryLeakTracking.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 17/02/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated", file: file, line: line)
        }
    }
    
}
