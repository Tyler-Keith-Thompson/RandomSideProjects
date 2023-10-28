//
//  RetryTests.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
import FluentTask
import XCTest

final class RetryTests: XCTestCase {
    func testTaskCanRetryADefinedNumberOfTimes() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        let retryCount = UInt.random(in: 2...10)
        
        let t = DeferredTask {
            await test.append("called")
        }
        .tryMap { _ in throw URLError(.badURL) }
        .retry(retryCount)
        
        _ = await t.result
        
        let copy = await test.arr
        XCTAssertEqual(UInt(copy.count), retryCount + 1)
    }
    
    func testTaskCanRetryZero_DoesNothing() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        let t = DeferredTask {
            await test.append("called")
        }
        .tryMap { _ in throw URLError(.badURL) }
        .retry(0)
        
        _ = await t.result
        
        let copy = await test.arr
        XCTAssertEqual(UInt(copy.count), 1)
    }
    
    func testTaskCanRetryDefaultsToOnce() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        let t = DeferredTask {
            await test.append("called")
        }
        .tryMap { _ in throw URLError(.badURL) }
        .retry()
        
        _ = await t.result
        
        let copy = await test.arr
        XCTAssertEqual(UInt(copy.count), 2)
    }
    
    func testTaskCanRetryWithoutError_DoesNothing() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        let t = DeferredTask {
            await test.append("called")
        }
        .retry(10)
        
        _ = await t.result
        
        let copy = await test.arr
        XCTAssertEqual(UInt(copy.count), 1)
    }
}