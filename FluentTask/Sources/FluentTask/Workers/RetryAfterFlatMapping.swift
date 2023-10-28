//
//  RetryAfterFlatMapping.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation
extension Workers {
    struct RetryAfterFlatMapping<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(upstream: U, retries: UInt, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (Error) async throws -> D) where U.Success == Success {
            guard retries > 0 else { state = upstream.state; return }
            state = TaskState {
                for _ in 0..<retries {
                    do {
                        return try await upstream.operation()
                    } catch {
                        _ = try await transform(error).operation()
                        continue
                    }
                }
                
                return try await upstream.operation()
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func retry<D: AsynchronousUnitOfWork>(_ retries: UInt = 1, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Error) async throws -> D) -> some AsynchronousUnitOfWork<Success> {
        Workers.RetryAfterFlatMapping(upstream: self, retries: retries, transform: transform)
    }
}
