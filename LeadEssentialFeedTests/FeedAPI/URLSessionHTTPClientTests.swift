//
//  URLSessionHTTPClientTests.swift
//  LeadEssentialFeedTests
//
//  Created by Gowtham Namuru on 15/02/25.
//

import XCTest
import LeadEssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _,_,error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let sut = URLSessionHTTPClient()
        URLProtocolStub.stub(url: url, error: error)
        let exp = expectation(description: "Completion handler called")
        sut.get(from: url) { receivedResult in
            switch receivedResult {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, error.code)
                XCTAssertEqual(receivedError.domain, error.domain)
            default:
                XCTFail("Expected failure with error \(error), got \(receivedResult)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }

    // MARK: - Helper
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()

        private struct Stub {
            let error: Error?
        }

        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }

        static func startInterceptingRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return Self.stubs[url] != nil
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else {
                return
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
