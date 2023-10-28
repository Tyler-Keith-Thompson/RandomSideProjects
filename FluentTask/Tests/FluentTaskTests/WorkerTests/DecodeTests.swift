//
//  DecodeTests.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation
import FluentTask
import XCTest

final class DecodeTests: XCTestCase {
    func testDecodingSuccess() async throws {
        struct MyType: Codable {
            let val: String
        }
        
        let random = UUID().uuidString
        let res = try await DeferredTask {
            try JSONEncoder().encode(MyType(val: random))
        }
            .decode(type: MyType.self, decoder: JSONDecoder())
            .result
            .get()
        
        XCTAssertEqual(res.val, random)
    }
}
