//
//  RepalceNilTests.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
import FluentTask
import XCTest

final class RepalceNilTests: XCTestCase {
    func testReplaceNilTransformsValue() async throws {
        let val = try await DeferredTask { nil as Int? }
            .replaceNil(with: 0)
            .result
            .get()
        
        XCTAssertEqual(val, 0)
    }
}