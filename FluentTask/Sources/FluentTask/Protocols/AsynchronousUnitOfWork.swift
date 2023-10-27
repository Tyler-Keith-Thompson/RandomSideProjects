// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public protocol AsynchronousUnitOfWork<Success, Failure>: Sendable where Success: Sendable, Failure: Error {
    associatedtype Success
    associatedtype Failure
    
    var taskCreator: @Sendable () -> Task<Success, Failure> { get }
    
    func execute()
    var result: Result<Success, Failure> { get async }
}

extension AsynchronousUnitOfWork {
    public var result: Result<Success, Failure> {
        get async {
            await taskCreator().result
        }
    }
    
    public func execute() {
        _ = taskCreator()
    }
}
