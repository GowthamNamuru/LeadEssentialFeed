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
        session.dataTask(with: url) { _,_,_ in }.resume()
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

    func test_getFromURL_ResumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSPY()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, task: task)

        sut.get(from: url)
        XCTAssertEqual(task.resumeCount, 1)
    }


    // MARK: - Helper
    private class URLSessionSPY: URLSession {
        var receivedURLS: [URL] = []
        private var stubs = [URL: URLSessionDataTask]()

        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLS.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCount = 0

        override func resume() {
            resumeCount += 1
        }
    }
}
