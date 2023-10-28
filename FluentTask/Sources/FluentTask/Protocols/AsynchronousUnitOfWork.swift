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
            return await createTask().result
        }
    }
    
    public func execute() throws {
        guard !state.isCancelled else { throw CancellationError() }
        createTask()
    }
    
    public func cancel() {
        state.cancel()
    }
    
    // deliberately internal
    @discardableResult func createTask() -> Task<Success, Error> { state.createTask() }
}

public class TaskState<Success: Sendable>: @unchecked Sendable {
    let lock = NSRecursiveLock()
    var tasks: [Task<Success, Error>] = []
    let taskCreator: @Sendable () -> Task<Success, Error>
    
    private let _isCancelled = ManagedAtomic<Bool>(false)
    
    var isCancelled: Bool {
        _isCancelled.load(ordering: .sequentiallyConsistent)
    }
    
    init(taskCreator: @Sendable @escaping () -> Task<Success, Error>) {
        self.taskCreator = taskCreator
    }
    
    func createTask() -> Task<Success, Error> {
        let task = taskCreator()
        if !isCancelled {
            lock.lock()
            tasks.append(task)
            lock.unlock()
        } else {
            task.cancel()
        }
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
