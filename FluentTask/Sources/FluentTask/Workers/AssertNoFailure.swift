//
//  AssertNoFailure.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct AssertNoFailure<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U) where Failure == Error, U.Success == Success, U.Failure == Failure {
            state = TaskState {
                Task(priority: priority) {
                    do {
                        return try await upstream.createTask().value
                    } catch {
                        assertionFailure("Expected no error in asynchronous unit of work, but got: \(error)")
                        throw error
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork where Failure == Error {
    public func assertNoFailure(priority: TaskPriority? = nil) -> some AsynchronousUnitOfWork<Success, Failure> where Failure == Error {
        Workers.AssertNoFailure(priority: priority, upstream: self)
    }
}
