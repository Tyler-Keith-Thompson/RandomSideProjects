//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine
import XCTest

import OHHTTPStubs
import OHHTTPStubsSwift

import RESTNetworkLayer

final class HTTPOperatorsTests: XCTestCase {
    struct JSONPlaceholder: RESTAPIProtocol {
        var baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    override func setUpWithError() throws {
        HTTPStubs.removeAllStubs()

        stub { _ in true } response: { req in
            XCTFail("Unexpected request made: \(req)")
            return HTTPStubsResponse(error: URLError.init(.badURL))
        }
    }

    func testCatchingAllHTTPErrors() async throws {
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))
        let allErrors: [any HTTPError] = HTTPClientError.allCases + HTTPServerError.allCases

        for error in allErrors {
            let response = try XCTUnwrap(HTTPURLResponse(url: url,
                                                         statusCode: Int(error.statusCode),
                                                         httpVersion: nil,
                                                         headerFields: nil))

            let result = await Just((data: Data(), response: response))
                .setFailureType(to: Error.self)
                .catchHTTPErrors()
                .firstValue()

            guard case .failure(let failure) = result else {
                XCTFail("Publisher succeeded, expected failure with HTTPError")
                return
            }

            guard let actualError = failure as? (any HTTPError) else {
                XCTFail("Error: \(failure) thrown by publisher was not an HTTPError")
                return
            }

            XCTAssertEqual(actualError.statusCode, error.statusCode)
        }
    }

    func testCatchingTooManyRequests() async throws {
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))

        let error = HTTPClientError.tooManyRequests()

        let response = try XCTUnwrap(HTTPURLResponse(url: url,
                                                     statusCode: Int(error.statusCode),
                                                     httpVersion: nil,
                                                     headerFields: ["Retry-After": "1.5"]))

        let result = await Just((data: Data(), response: response))
            .setFailureType(to: Error.self)
            .catchHTTPErrors()
            .firstValue()

        guard case .failure(let failure) = result else {
            XCTFail("Publisher succeeded, expected failure with HTTPError")
            return
        }

        guard let actualError = failure as? (any HTTPError) else {
            XCTFail("Error: \(failure) thrown by publisher was not an HTTPError")
            return
        }

        XCTAssertEqual(actualError.statusCode, error.statusCode)

        if case HTTPClientError.tooManyRequests(.some(let retryAfter)) = actualError {
            XCTAssertEqual(retryAfter.converted(to: .seconds).value, 1.5)
        } else {
            XCTFail("RetryAfter value not in error.")
        }
    }

    func testRetryAfterServerSpecifiedTime() async throws {
        let json = try XCTUnwrap("""
        [
            {
                userId: 1,
                id: 1,
                title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
            },
        ]
        """.data(using: .utf8))
        let retryAfter = Double.random(in: 0.100...0.240)
        let requestDate: Date = Date()
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }
        .thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: json, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.get(endpoint: "posts")
            .respondToRateLimiting()
            .firstValue()
            .get()

        XCTAssertGreaterThan(Date().timeIntervalSince1970 - requestDate.timeIntervalSince1970, Measurement(value: retryAfter, unit: UnitDuration.milliseconds).converted(to: .seconds).value)
        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
    }

    func testRespondToRateLimitingOnlyRetriesOnce() async throws {
        let retryAfter = Double.random(in: 0.100...0.300)
        let requestDate: Date = Date()
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }
        .thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }
        .thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            XCTFail("Should not have made a 3rd request")
            return HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }

        let api = JSONPlaceholder()

        var publisherRetries = 0
        let result = await api.get(endpoint: "posts")
            .map { val in
                publisherRetries += 1
                return val
            }
            .respondToRateLimiting(maxSecondsToWait: 0)
            .firstValue()

        XCTAssertGreaterThan(Date().timeIntervalSince1970 - requestDate.timeIntervalSince1970, Measurement(value: retryAfter, unit: UnitDuration.milliseconds).converted(to: .seconds).value)
        XCTAssertThrowsError(try result.get()) { error in
            guard let actualError = error as? (any HTTPError) else {
                XCTFail("Error: \(error) thrown by publisher was not an HTTPError")
                return
            }

            XCTAssertEqual(actualError.statusCode, HTTPClientError.tooManyRequests().statusCode)
        }
        XCTAssertEqual(publisherRetries, 2)
    }

    func testRateLimitingShouldDoNothingUnlessCorrectStatusCodeIsGiven() async throws {
        let json = try XCTUnwrap("""
        [
            {
                userId: 1,
                id: 1,
                title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
            },
        ]
        """.data(using: .utf8))
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: json, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.get(endpoint: "posts")
            .respondToRateLimiting()
            .firstValue()
            .get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
    }

    func testRateLimitingDoesNotRetryIfADifferentErrorIsThrown() async throws {
        var requestCount = 0
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            requestCount += 1
            return HTTPStubsResponse(data: Data(), statusCode: 401, headers: nil)
        }

        let api = JSONPlaceholder()

        let result = await api.get(endpoint: "posts")
            .respondToRateLimiting()
            .firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual($0 as? HTTPClientError, .unauthorized)
        }

        XCTAssertEqual(requestCount, 1)
    }
}
