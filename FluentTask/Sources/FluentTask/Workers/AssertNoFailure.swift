//
//  AssertNoFailure.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct AssertNoFailure<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U) where U.Success == Success {
            state = TaskState {
                Task(priority: priority) {
                    do {
                        let val = try await upstream.createTask().value
                        try Task.checkCancellation()
                        return val
                    } catch {
                        if !(error is CancellationError) {
                            assertionFailure("Expected no error in asynchronous unit of work, but got: \(error)")
                        }
                        throw error
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func assertNoFailure(priority: TaskPriority? = nil) -> some AsynchronousUnitOfWork<Success> {
        Workers.AssertNoFailure(priority: priority, upstream: self)
    }
}
