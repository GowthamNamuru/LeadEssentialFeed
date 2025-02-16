//
//  URLSessionHTTPClientTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 15/02/25.
//

import XCTest
import LeadEssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPDataTask
}

protocol HTTPDataTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _,_,error in
            if let error = error as NSError? {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_ResumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSPY()
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, task: task)

        sut.get(from: url){_ in }
        XCTAssertEqual(task.resumeCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSPY()
        let error = NSError(domain: "any error", code: 1)
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, error: error)
        let exp = expectation(description: "Completion handler called")
        sut.get(from: url) { receivedResult in
            switch receivedResult {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(receivedResult)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helper
    private class URLSessionSPY: HTTPSession {
        private var stubs = [URL: Stub]()

        private struct Stub {
            let task: HTTPDataTask
            let error: Error?
        }

        func stub(url: URL, task: HTTPDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for URL \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }

    private class FakeURLSessionDataTask: HTTPDataTask {
        func resume() {}
    }
    private class URLSessionDataTaskSpy: HTTPDataTask {
        var resumeCount = 0

        func resume() {
            resumeCount += 1
        }
    }
}
