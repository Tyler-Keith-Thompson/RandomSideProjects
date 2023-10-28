//
//  Catch.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Catch<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture _ handler: @escaping @Sendable (U.Failure) async throws -> Success) where Failure == Error, U.Success == Success, U.Failure == Failure {
            state = TaskState {
                Task(priority: priority) {
                    do {
                        return try await upstream.createTask().value
                    } catch {
                        return try await handler(error)
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork where Failure == Error {
    public func `catch`(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ handler: @escaping @Sendable (Failure) async throws -> Success) -> some AsynchronousUnitOfWork<Success, Failure> {
        Workers.Catch(priority: priority, upstream: self, handler)
    }
    
    public func tryCatch(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ handler: @escaping @Sendable (Failure) async throws -> Success) -> some AsynchronousUnitOfWork<Success, Failure> {
        Workers.Catch(priority: priority, upstream: self, handler)
    }
}
