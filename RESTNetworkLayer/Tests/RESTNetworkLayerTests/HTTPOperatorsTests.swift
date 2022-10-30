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
    override func setUpWithError() throws {
        HTTPStubs.removeAllStubs()

        stub { _ in true } response: { req in
            HTTPStubsResponse(error: URLError.init(.badURL))
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
}
