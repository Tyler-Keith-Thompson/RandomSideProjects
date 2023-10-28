//
//  ZipTests.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
import FluentTask
import XCTest

final class ZipTests: XCTestCase {
    func testZipCombinesTasks_WithExplicitFailure() async throws {
        let t1 = DeferredTask<Int, Error> { 1 }
        
        let t2 = DeferredTask<String, Error> { "A" }
        let t3 = t2.zip(t1)
        let val = try await t3.result.get() // Steak sauce!!!
        XCTAssertEqual(val.0, "A")
        XCTAssertEqual(val.1, 1)
    }
    
    func testZipCombinesTasks() async throws {
        let t1 = DeferredTask { 1 }
        
        let t2 = DeferredTask { "A" }
        let t3 = t2.zip(t1)
        let val = try await t3.result.get() // Steak sauce!!!
        XCTAssertEqual(val.0, "A")
        XCTAssertEqual(val.1, 1)
    }
    
    func testZipTransformCombinesTasks_WithExplicitFailure() async throws {
        let t1 = DeferredTask<Int, Error> { 1 }
        
        let t2 = DeferredTask<String, Error> { "A" }
        let t3 = t2.zip(t1) { $0 + String(describing: $1) }
        let val = try await t3.result.get() // Steak sauce!!!
        XCTAssertEqual(val, "A1")
    }
    
    func testZipTransformCombinesTasks() async throws {
        let t1 = DeferredTask { 1 }
    
        let t2 = DeferredTask { "A" }
        let t3 = t2.zip(t1) { $0 + String(describing: $1) }
        let val = try await t3.result.get() // Steak sauce!!!
        XCTAssertEqual(val, "A1")
    }
    
    func testZip3CombinesTasks_WithExplicitFailure() async throws {
        let t1 = DeferredTask<Int, Error> { 1 }
        let t2 = DeferredTask<String, Error> { "A" }
        let t3 = DeferredTask<Bool, Error> { true }
        
        let t4 = t2.zip(t1, t3)
        let val = try await t4.result.get() // Steak sauce!!!
        XCTAssertEqual(val.0, "A")
        XCTAssertEqual(val.1, 1)
        XCTAssertEqual(val.2, true)
    }
    
    func testZip3CombinesTasks() async throws {
        let t1 = DeferredTask { 1 }
        let t2 = DeferredTask { "A" }
        let t3 = DeferredTask { true }

        let t4 = t2.zip(t1, t3)
        let val = try await t4.result.get() // Steak sauce!!!
        XCTAssertEqual(val.0, "A")
        XCTAssertEqual(val.1, 1)
        XCTAssertEqual(val.2, true)
    }
    
    func testZip3TransformCombinesTasks_WithExplicitFailure() async throws {
        let t1 = DeferredTask<Int, Error> { 1 }
        let t2 = DeferredTask<String, Error> { "A" }
        let t3 = DeferredTask<Bool, Error> { true }
        
        let t4 = t2.zip(t1, t3) { $0 + String(describing: $1) + String(describing: $2) }
        let val = try await t4.result.get() // Steak sauce!!!
        XCTAssertEqual(val, "A1true")
    }
    
    func testZip3TransformCombinesTasks() async throws {
        let t1 = DeferredTask { 1 }
        let t2 = DeferredTask { "A" }
        let t3 = DeferredTask { true }
        
        let t4 = t2.zip(t1, t3) { $0 + String(describing: $1) + String(describing: $2) }
        let val = try await t4.result.get() // Steak sauce!!!
        XCTAssertEqual(val, "A1true")
    }
}
