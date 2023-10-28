import Foundation
import Atomics

public protocol AsynchronousUnitOfWork<Success>: Sendable where Success: Sendable {
    associatedtype Success
    
    var state: TaskState<Success> { get }
    var result: Result<Success, Error> { get async throws }
    
    func execute() throws
    func cancel()
}

extension AsynchronousUnitOfWork {
    public var result: Result<Success, Error> {
        get async throws {
            guard !state.isCancelled else { throw CancellationError() }
            return await state.createTask().result
        }
    }
    
    public func execute() throws {
        guard !state.isCancelled else { throw CancellationError() }
        state.createTask()
    }
    
    public func cancel() {
        state.cancel()
    }
    
    var operation: @Sendable () async throws -> Success {
        state.createOperation()
    }
}

public class TaskState<Success: Sendable>: @unchecked Sendable {
    let lock = NSRecursiveLock()
    var tasks = [Task<Success, Error>]()
    let operation: @Sendable () async throws -> Success
    
    private let _isCancelled = ManagedAtomic<Bool>(false)
    
    var isCancelled: Bool {
        _isCancelled.load(ordering: .sequentiallyConsistent)
    }
    
    init(operation: @Sendable @escaping () async throws -> Success) {
        self.operation = operation
    }
    
    func createOperation() -> @Sendable () async throws -> Success {
        { [operation] in
            try Task.checkCancellation()
            let success = try await operation()
            try Task.checkCancellation()
            return success
        }
    }
    
    @discardableResult func createTask() -> Task<Success, Error> {
        let task = Task { try await operation() }
        lock.lock()
        tasks.append(task)
        lock.unlock()
        return task
    }
    
    func cancel() {
        guard !isCancelled else { return }
        _isCancelled.store(true, ordering: .sequentiallyConsistent)
        lock.lock()
        tasks.forEach { $0.cancel() }
        lock.unlock()
    }
}
