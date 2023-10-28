//
//  FlatMap.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct FlatMap<Success: Sendable>: AsynchronousUnitOfWork {
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
    public func flatMap<S: Sendable>(@_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> S) -> some AsynchronousUnitOfWork<S> {
        Workers.FlatMap(upstream: self, transform: transform)
    }
    
    public func flatMap<S: Sendable>(@_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable () async throws -> S) -> some AsynchronousUnitOfWork<S> where Success == Void {
        Workers.FlatMap(upstream: self, transform: { _ in try await transform() })
    }
}
