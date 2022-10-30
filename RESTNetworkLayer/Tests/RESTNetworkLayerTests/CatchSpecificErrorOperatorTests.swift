//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine
import XCTest

import RESTNetworkLayer

final class CatchSpecificErrorOperatorTests: XCTestCase {
    func testTryCatchWithEquatableError_CallsPublisherClosureIfErrorMatches() async {
        enum Err: Error, Equatable {
            case err1
            case err2
        }

        let exp = expectation(description: "TryCatch called")

        _ = await Fail<String, Error>(error: Err.err1)
            .tryCatch(Err.err1) { err -> AnyPublisher<String, Error> in
                XCTAssertEqual(err, Err.err1)
                exp.fulfill()
                throw err
            }
            .firstValue()

        wait(for: [exp], timeout: 0.3)
    }

    func testTryCatchWithEquatableError_DoesNotCallsPublisherClosureIfErrorDoesNotMatch() async {
        enum Err: Error, Equatable {
            case err1
            case err2
        }
        
        _ = await Fail<String, Error>(error: Err.err1)
            .tryCatch(Err.err2) { err -> AnyPublisher<String, Error> in
                XCTFail("Error closure should not have been called, given error does not match.")
                throw err
            }
            .firstValue()
    }
}
