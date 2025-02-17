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

    struct UnexpectedValuesRepresentation: Error {}

    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else  if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
        super.tearDown()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestedError = NSError(domain: "any error", code: 1)

        let receivedError = resultErrorFor(data: nil, response: nil, error: requestedError) as? NSError

        XCTAssertEqual(receivedError?.code, requestedError.code)
        XCTAssertEqual(receivedError?.domain, requestedError.domain)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let requestedData = anyData()
        let requestedResponse = anyHTTPURLResponse()

        let receivedValues = resultValuesFor(data: requestedData, response: requestedResponse, error: nil)

        XCTAssertEqual(receivedValues?.data, requestedData)
        XCTAssertEqual(receivedValues?.response.url, requestedResponse?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, requestedResponse?.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyOnHTTPURLResponseWithNilData() {
        let requestedResponse = anyHTTPURLResponse()
        let emptyData = Data()

        let receivedValues = resultValuesFor(data: nil, response: requestedResponse, error: nil)

        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, requestedResponse?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, requestedResponse?.statusCode)
    }

    // MARK: - Helper
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }

    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }

    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse? {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    }

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,
                                file: StaticString = #filePath,
                                line: UInt = #line) -> Error? {

        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure with error, got \(result)", file: file, line: line)
            return nil
        }
    }

    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?,
                                file: StaticString = #filePath,
                                line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {

        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result)", file: file, line: line)
            return nil
        }
    }


    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath,
                           line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Completion handler called")
        var receivedResult: HTTPClientResult!
        makeSUT(file: file, line: line).get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func observeRequest(_ completion: @escaping (URLRequest) -> Void) {
            requestObserver = completion
        }

        static func stopInterceptingRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
