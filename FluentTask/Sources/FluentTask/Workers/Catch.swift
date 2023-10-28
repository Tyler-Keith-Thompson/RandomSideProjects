//
//  Catch.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Catch<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(upstream: U, @_inheritActorContext @_implicitSelfCapture _ handler: @escaping @Sendable (Error) async throws -> Success) where U.Success == Success {
            state = TaskState {
                do {
                    let val = try await upstream.operation()
                    try Task.checkCancellation()
                    return val
                } catch {
                    if error is CancellationError {
                        throw error
                    } else {
                        let val = try await handler(error)
                        try Task.checkCancellation()
                        return val
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func `catch`(@_inheritActorContext @_implicitSelfCapture _ handler: @escaping @Sendable (Error) async throws -> Success) -> some AsynchronousUnitOfWork<Success> {
        Workers.Catch(upstream: self, handler)
    }
    
    public func tryCatch(@_inheritActorContext @_implicitSelfCapture _ handler: @escaping @Sendable (Error) async throws -> Success) -> some AsynchronousUnitOfWork<Success> {
        Workers.Catch(upstream: self, handler)
    }
}
