// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public protocol AsynchronousUnitOfWork<Success, Failure>: Sendable where Success: Sendable, Failure: Error {
    associatedtype Success
    associatedtype Failure
    
    var state: TaskState<Success, Failure> { get }
    
    func execute()
    var result: Result<Success, Failure> { get async }
}

extension AsynchronousUnitOfWork {
    public var result: Result<Success, Failure> {
        get async {
            await createTask().result
        }
    }
    
    public func execute() {
        createTask()
    }
    
    @discardableResult func createTask() -> Task<Success, Failure> { state.createTask() }
}

public class TaskState<Success: Sendable, Failure: Error>: @unchecked Sendable {
    let taskCreator: @Sendable () -> Task<Success, Failure>
    init(taskCreator: @Sendable @escaping () -> Task<Success, Failure>) {
        self.taskCreator = taskCreator
    }
    
    func createTask() -> Task<Success, Failure> { taskCreator() }
}
