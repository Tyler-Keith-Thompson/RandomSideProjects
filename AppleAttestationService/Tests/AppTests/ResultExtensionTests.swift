//
//  ResultExtensionTests.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation
import XCTest

@testable import App

class ResultExtensionTests: XCTestCase {
    func testMergeWithFirstSuccess() {
        let result1: Result<Int, Error> = .success(10)
        let result2: Result<Int, Error> = .failure(NSError(domain: "", code: -1, userInfo: nil))
        let mergedResult = result1.merge(result2)
        switch mergedResult {
        case .success(let value):
            XCTAssertEqual(value, 10)
        case .failure:
            XCTFail("Expected a success case")
        }
    }

    func testMergeWithSecondSuccess() {
        let result1: Result<Int, Error> = .failure(NSError(domain: "", code: -1, userInfo: nil))
        let result2: Result<Int, Error> = .success(20)
        let mergedResult = result1.merge(result2)
        switch mergedResult {
        case .success(let value):
            XCTAssertEqual(value, 20)
        case .failure:
            XCTFail("Expected a success case")
        }
    }

    func testMergeWithTwoFailures() {
        let result1: Result<Int, Error> = .failure(NSError(domain: "", code: -1, userInfo: nil))
        let result2: Result<Int, Error> = .failure(NSError(domain: "", code: -2, userInfo: nil))
        let mergedResult = result1.merge(result2)
        switch mergedResult {
        case .success:
            XCTFail("Expected a failure case")
        case .failure(let error as NSError):
            XCTAssertEqual(error.code, -2)
        default:
            XCTFail("Expected a failure case with NSError")
        }
    }
}
