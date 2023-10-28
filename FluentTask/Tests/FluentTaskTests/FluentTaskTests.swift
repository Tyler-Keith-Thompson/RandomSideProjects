import XCTest
@testable import FluentTask

final class FluentTaskTests: XCTestCase {
    func testDeferredTaskDoesNotExecuteImmediately() async throws {
        let notFiredExpectation = expectation(description: "did not fire")
        notFiredExpectation.isInverted = true
        
        _ = DeferredTask {
            notFiredExpectation.fulfill()
        }
        
        await fulfillment(of: [notFiredExpectation], timeout: 0.001)
    }
    
    func testDeferredTaskExecutesWhenAskedTo() async throws {
        let firedExpectation = expectation(description: "did not fire")
        
        try DeferredTask {
            firedExpectation.fulfill()
        }.execute()
        
        await fulfillment(of: [firedExpectation], timeout: 0.001)
    }
}
