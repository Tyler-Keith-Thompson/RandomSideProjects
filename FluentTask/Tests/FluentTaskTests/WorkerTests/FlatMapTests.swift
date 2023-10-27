//
//  FlatMapTests.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
import FluentTask
import XCTest

final class FlatMapTests: XCTestCase {
    func testFlatMapTransformsValue() async throws {
        let val = try await DeferredTask { 1 }
            .flatMap { String(describing: $0) }
            .result
            .get()
        
        XCTAssertEqual(val, "1")
    }
    
    func testFlatMapOrdersCorrectly() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        _ = await DeferredTask {
            try await Task.sleep(nanoseconds: 10000)
            await test.append("1")
        }.flatMap {
            await test.append("2")
        }
        .result
        
        let copy = await test.arr
        XCTAssertEqual(copy, ["1", "2"])
    }
    
    func testFlatMapOrdersCorrectly_No_Throwing() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        _ = await DeferredTask {
            try! await Task.sleep(nanoseconds: 10000)
            await test.append("1")
        }.flatMap {
            await test.append("2")
        }
        .result
        
        let copy = await test.arr
        XCTAssertEqual(copy, ["1", "2"])
    }
    
    func testFlatMapThrowsError() async throws {
        let val = await DeferredTask { 1 }
            .flatMap { _ in throw URLError(.badURL) }
            .result
        
        XCTAssertThrowsError(try val.get()) { error in
            XCTAssertEqual(error as? URLError, URLError(.badURL))
        }
    }

}
