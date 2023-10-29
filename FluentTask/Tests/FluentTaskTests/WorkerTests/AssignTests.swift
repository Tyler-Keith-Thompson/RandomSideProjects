//
//  AssignTests.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation
import FluentTask
import XCTest

final class AssignTests: XCTestCase {
    func testAssignToProperty() async throws {
        class Test {
            var val = ""
        }
        
        var test = Test()
        
        try await DeferredTask { "test" }
            .assign(to: \.val, on: test)
        
        XCTAssertEqual(test.val, "test")
    }
}