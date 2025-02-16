//
//  URLSessionHTTPClientTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 15/02/25.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _,_,_ in }
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_CreatesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSPY()
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)
        XCTAssertEqual(session.receivedURLS, [url])
    }


    // MARK: - Helper
    private class URLSessionSPY: URLSession {
        var receivedURLS: [URL] = []
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLS.append(url)
            return FakeURLSessionDataTask()
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {
    }
}
