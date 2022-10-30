//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import XCTest

import RESTNetworkLayer

final class HTTPClientErrorTests: XCTestCase {
    func testHTTPClientErrors() {
        HTTPClientError.allCases.forEach {
            switch $0 {
                case .badRequest:
                    XCTAssertEqual($0.statusCode, 400)
                case .unauthorized:
                    XCTAssertEqual($0.statusCode, 401)
                case .paymentRequired:
                    XCTAssertEqual($0.statusCode, 402)
                case .forbidden:
                    XCTAssertEqual($0.statusCode, 403)
                case .notFound:
                    XCTAssertEqual($0.statusCode, 404)
                case .methodNotAllowed:
                    XCTAssertEqual($0.statusCode, 405)
                case .notAcceptable:
                    XCTAssertEqual($0.statusCode, 406)
                case .proxyAuthenticationRequired:
                    XCTAssertEqual($0.statusCode, 407)
                case .requestTimeout:
                    XCTAssertEqual($0.statusCode, 408)
                case .conflict:
                    XCTAssertEqual($0.statusCode, 409)
                case .gone:
                    XCTAssertEqual($0.statusCode, 410)
                case .lengthRequired:
                    XCTAssertEqual($0.statusCode, 411)
                case .preconditionFailed:
                    XCTAssertEqual($0.statusCode, 412)
                case .payloadTooLarge:
                    XCTAssertEqual($0.statusCode, 413)
                case .requestURITooLong:
                    XCTAssertEqual($0.statusCode, 414)
                case .unsupportedMediaType:
                    XCTAssertEqual($0.statusCode, 415)
                case .requestedRangeNotSatisfiable:
                    XCTAssertEqual($0.statusCode, 416)
                case .expectationFailed:
                    XCTAssertEqual($0.statusCode, 417)
                case .misdirectedRequest:
                    XCTAssertEqual($0.statusCode, 421)
                case .unprocessableEntity:
                    XCTAssertEqual($0.statusCode, 422)
                case .locked:
                    XCTAssertEqual($0.statusCode, 423)
                case .failedDependency:
                    XCTAssertEqual($0.statusCode, 424)
                case .upgradeRequired:
                    XCTAssertEqual($0.statusCode, 426)
                case .preconditionRequired:
                    XCTAssertEqual($0.statusCode, 428)
                case .tooManyRequests:
                    XCTAssertEqual($0.statusCode, 429)
                case .requestHeaderFieldTooLarge:
                    XCTAssertEqual($0.statusCode, 431)
                case .connectionClosedWithoutResponse:
                    XCTAssertEqual($0.statusCode, 444)
                case .unavailableForLegalReasons:
                    XCTAssertEqual($0.statusCode, 451)
                case .clientClosedRequest:
                    XCTAssertEqual($0.statusCode, 499)
            }
        }
    }
}
