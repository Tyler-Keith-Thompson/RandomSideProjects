//
//  RetryAfterFlatMapping.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation
extension Workers {
    actor RetryAfterFlatMapping<Success>: AsynchronousUnitOfWork {
        var retryCount: UInt

        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(upstream: U, retries: UInt, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (Error) async throws -> D) where U.Success == Success {
            retryCount = retries
            guard retries > 0 else {
                state = upstream.state
                return
            }
            state = TaskState<Success>.unsafeCreation()
            state.setOperation { [weak self] in
                guard let self else { throw CancellationError() }
                while await retryCount > 0 {
                    do {
                        return try await upstream.operation()
                    } catch {
                        _ = try await transform(error).operation()
                        await decrementRetry()
                        continue
                    }
                }
                return try await upstream.operation()
            }
        }
        
        func decrementRetry() {
            guard retryCount > 0 else { return }
            retryCount -= 1
        }
    }
    
    actor RetryOnAfterFlatMapping<Success>: AsynchronousUnitOfWork {
        var retryCount: UInt

        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork, E: Error & Equatable>(upstream: U, retries: UInt, error: E, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (Error) async throws -> D) where U.Success == Success {
            retryCount = retries
            guard retries > 0 else {
                state = upstream.state
                return
            }
            state = TaskState<Success>.unsafeCreation()
            state.setOperation { [weak self] in
                guard let self else { throw CancellationError() }
                while await retryCount > 0 {
                    do {
                        return try await upstream.operation()
                    } catch(let err) {
                        guard let unwrappedError = (err as? E),
                              unwrappedError == error else { throw err }
                        _ = try await transform(error).operation()
                        await decrementRetry()
                        continue
                    }
                }
                return try await upstream.operation()
            }
        }
        
        func decrementRetry() {
            guard retryCount > 0 else { return }
            retryCount -= 1
        }
    }
}

extension AsynchronousUnitOfWork {
    public func retry<D: AsynchronousUnitOfWork>(_ retries: UInt = 1, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Error) async throws -> D) -> some AsynchronousUnitOfWork<Success> {
        Workers.RetryAfterFlatMapping(upstream: self, retries: retries, transform: transform)
    }
    
    public func retry<D: AsynchronousUnitOfWork, E: Error & Equatable>(_ retries: UInt = 1, on error: E, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Error) async throws -> D) -> some AsynchronousUnitOfWork<Success> {
        Workers.RetryOnAfterFlatMapping(upstream: self, retries: retries, error: error, transform: transform)
    }
}
