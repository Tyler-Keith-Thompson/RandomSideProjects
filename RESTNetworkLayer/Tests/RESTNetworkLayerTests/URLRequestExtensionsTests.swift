//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import XCTest

import RESTNetworkLayer

final class URLRequestExtensionsTests: XCTestCase {
    func testURLRequest_FluentAddHeader() throws {
        let headerVal = UUID().uuidString
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))

        let req = URLRequest(url: url)
        let modified = req.addingValue(headerVal, forHTTPHeaderField: "Custom-Header-Field")

        XCTAssertNotEqual(req, modified)
        XCTAssertEqual(modified.value(forHTTPHeaderField: "Custom-Header-Field"), headerVal)
    }
}
