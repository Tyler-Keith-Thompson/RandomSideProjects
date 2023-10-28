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
            .catch { _ in DeferredTask { 2 } }
            .result
            .get()
        
        XCTAssertEqual(val, 1)
    }
    
    func testCatchDoesNotThrowError() async throws {
        let val = try await DeferredTask { 1 }
            .tryMap { _ in throw URLError(.badURL) }
            .catch { error -> DeferredTask<Int> in
                XCTAssertEqual(error as? URLError, URLError(.badURL))
                return DeferredTask { 2 }
            }
            .result
        
        XCTAssertEqual(try val.get(), 2)
    }

    func testTryCatchDoesNotInterfereWithNoFailure() async throws {
        let val = try await DeferredTask { 1 }
            .tryCatch { _ in DeferredTask { 2 } }
            .result
            .get()
        
        XCTAssertEqual(val, 1)
    }
    
    func testTryCatchDoesNotThrowError() async throws {
        let val = try await DeferredTask { 1 }
            .tryMap { _ in throw URLError(.badURL) }
            .tryCatch { error -> DeferredTask<Int> in
                XCTAssertEqual(error as? URLError, URLError(.badURL))
                return DeferredTask { 2 }
            }
            .result
        
        XCTAssertEqual(try val.get(), 2)
    }
}
