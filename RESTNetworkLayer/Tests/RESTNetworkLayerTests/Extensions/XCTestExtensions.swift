//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import Combine
import XCTest

extension Publisher {
    func firstValue(timeout: TimeInterval = 0.3,
                    file: StaticString = #file,
                    line: UInt = #line) async -> Result<Output, Error> where Failure == Error {
        await withCheckedContinuation { continuation in
            var result: Result<Output, Error>?
            let expectation = XCTestExpectation(description: "Awaiting publisher")

            let cancellable = map(Result<Output, Error>.success)
                .catch { Just(.failure($0)) }
                .sink {
                    result = $0
                    expectation.fulfill()
                }

            XCTWaiter().wait(for: [expectation], timeout: timeout)
            cancellable.cancel()

            do {
                let unwrappedResult = try XCTUnwrap(
                    result,
                    "Awaited publisher did not produce any output",
                    file: file,
                    line: line
                )
                continuation.resume(returning: unwrappedResult)
            } catch {
                continuation.resume(returning: .failure(error))
            }
        }
    }
}
