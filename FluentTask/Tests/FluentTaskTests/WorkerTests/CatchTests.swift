//
//  CatchTests.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
import FluentTask
import XCTest

final class CatchTests: XCTestCase {
    func testCatchDoesNotInterfereWithNoFailure() async throws {
        let val = try await DeferredTask { 1 }
            .catch { _ in 2 }
            .result
            .get()
        
        XCTAssertEqual(val, 1)
    }
    
    func testCatchDoesNotThrowError() async throws {
        let val = await DeferredTask { 1 }
            .tryMap { _ in throw URLError(.badURL) }
            .catch { error -> Int in
                XCTAssertEqual(error as? URLError, URLError(.badURL))
                return 2
            }
            .result
        
        XCTAssertEqual(try val.get(), 2)
    }

}
