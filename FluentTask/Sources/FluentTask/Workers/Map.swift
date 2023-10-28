//
//  Map.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Map<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async -> Success) {
            state = TaskState {
                let val = try await upstream.operation()
                try Task.checkCancellation()
                return await transform(val)
            }
        }
    }
    
    struct TryMap<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async throws -> Success) {
            state = TaskState {
                try Task.checkCancellation()
                let val = try await upstream.operation()
                try Task.checkCancellation()
                return try await transform(val)
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func map<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async -> S) -> some AsynchronousUnitOfWork<S> {
        Workers.Map(priority: priority, upstream: self, transform: transform)
    }
    
    public func tryMap<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> S) -> some AsynchronousUnitOfWork<S> {
        Workers.TryMap(priority: priority, upstream: self, transform: transform)
    }
}
