import Foundation
import Atomics

public protocol AsynchronousUnitOfWork<Success, Failure>: Sendable where Success: Sendable, Failure: Error {
    associatedtype Success
    associatedtype Failure
    
    var state: TaskState<Success, Failure> { get }
    
    func execute() throws
    var result: Result<Success, Failure> { get async throws }
}

extension AsynchronousUnitOfWork {
    public var result: Result<Success, Failure> {
        get async throws {
            await createTask().result
        }
    }
    
    public func execute() throws {
        createTask()
    }
    
    @discardableResult func createTask() -> Task<Success, Failure> { state.createTask() }
}

public class TaskState<Success: Sendable, Failure: Error>: @unchecked Sendable {
    let taskCreator: @Sendable () -> Task<Success, Failure>
    
    private let _isCancelled = ManagedAtomic<Bool>(false)
    
    init(taskCreator: @Sendable @escaping () -> Task<Success, Failure>) {
        self.taskCreator = taskCreator
    }
    
    func createTask() -> Task<Success, Failure> { taskCreator() }
}
