//
//  ShareTests.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
import FluentTask
import XCTest

final class ShareTests: XCTestCase {
    func testUnsharedTaskExecutesRepeatedly() async throws {
        let exp = expectation(description: "called")
        exp.expectedFulfillmentCount = 3
        
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        let t = DeferredTask {
            await test.append("called")
            exp.fulfill()
        }
        
        t.execute()
        t.execute()
        t.execute()

        await fulfillment(of: [exp], timeout: 0.001)
        let copy = await test.arr
        XCTAssertEqual(copy, ["called", "called", "called"])
    }
    
    func testUnsharedTaskExecutesRepeatedly_WithResult() async throws {
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
        
        _ = await t.result
        _ = await t.result
        _ = await t.result
        
        let copy = await test.arr
        XCTAssertEqual(copy, ["called", "called", "called"])
    }
    
    func testSharedTaskExecutesOnce() async throws {
        let exp = expectation(description: "called")
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        let t = DeferredTask {
            await test.append("called")
            exp.fulfill()
        }.share()
        
        t.execute()
        t.execute()
        t.execute()

        await fulfillment(of: [exp], timeout: 0.001)
        let copy = await test.arr
        XCTAssertEqual(copy, ["called"])
    }
    
    func testSharedTaskExecutesOnce_WithResult() async throws {
        actor Test {
            var arr = [String]()
            func append(_ str: String) {
                arr.append(str)
            }
        }
        
        let test = Test()
        
        let t = DeferredTask {
            await test.append("called")
        }.share()
        
        _ = await t.result
        _ = await t.result
        _ = await t.result
        
        let copy = await test.arr
        XCTAssertEqual(copy, ["called"])
    }
}
