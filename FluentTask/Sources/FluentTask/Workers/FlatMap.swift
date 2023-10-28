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

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async throws -> D) where Success == D.Success {
            state = TaskState {
                try await transform(try await upstream.operation()).operation()
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func flatMap<D: AsynchronousUnitOfWork>(@_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> D) -> some AsynchronousUnitOfWork<D.Success> {
        Workers.FlatMap(upstream: self, transform: transform)
    }
    
    public func flatMap<D: AsynchronousUnitOfWork>(@_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable () async throws -> D) -> some AsynchronousUnitOfWork<D.Success> where Success == Void {
        Workers.FlatMap(upstream: self, transform: { _ in try await transform() })
    }
}
