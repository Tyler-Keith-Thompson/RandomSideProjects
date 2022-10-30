//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import XCTest

import RESTNetworkLayer

final class HTTPServerErrorTests: XCTestCase {
    func testHTTPServerErrors() {
        HTTPServerError.allCases.forEach {
            switch $0 {
                case .internalServerError:
                    XCTAssertEqual($0.rawValue, 500)
                case .notImplemented:
                    XCTAssertEqual($0.rawValue, 501)
                case .badGateway:
                    XCTAssertEqual($0.rawValue, 502)
                case .serviceUnavailable:
                    XCTAssertEqual($0.rawValue, 503)
                case .gatewayTimeout:
                    XCTAssertEqual($0.rawValue, 504)
                case .httpVersionNotSupported:
                    XCTAssertEqual($0.rawValue, 505)
                case .variantAlsoNegotiates:
                    XCTAssertEqual($0.rawValue, 506)
                case .insufficientStorage:
                    XCTAssertEqual($0.rawValue, 507)
                case .loopDetected:
                    XCTAssertEqual($0.rawValue, 508)
                case .notExtended:
                    XCTAssertEqual($0.rawValue, 510)
                case .networkAuthenticationRequired:
                    XCTAssertEqual($0.rawValue, 511)
                case .networkConnectTimeoutError:
                    XCTAssertEqual($0.rawValue, 599)
            }
            XCTAssertEqual($0.rawValue, $0.statusCode)
        }
    }
}
