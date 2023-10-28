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

        init<U: AsynchronousUnitOfWork>(upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async -> Success) {
            state = TaskState {
                let val = try await upstream.operation()
                try Task.checkCancellation()
                return await transform(val)
            }
        }
    }
    
    struct TryMap<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async throws -> Success) {
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
    public func map<S: Sendable>(@_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async -> S) -> some AsynchronousUnitOfWork<S> {
        Workers.Map(upstream: self, transform: transform)
    }
    
    public func map<T>(_ keyPath: KeyPath<Success, T>) -> some AsynchronousUnitOfWork<T> {
        Workers.Map(upstream: self) {
            $0[keyPath: keyPath]
        }
    }
    
    public func tryMap<S: Sendable>(@_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> S) -> some AsynchronousUnitOfWork<S> {
        Workers.TryMap(upstream: self, transform: transform)
    }
}
