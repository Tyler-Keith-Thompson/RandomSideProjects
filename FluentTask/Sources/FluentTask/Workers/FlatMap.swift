//
//  FlatMap.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct FlatMap<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async throws -> Success) where Failure == Error {
            state = TaskState {
                Task(priority: priority) {
                    try await transform(upstream.createTask().value)
                }
            }
        }
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async -> Success) where Failure == Never, U.Failure == Never {
            state = TaskState {
                Task(priority: priority) {
                    await transform(await upstream.createTask().value)
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func flatMap<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> S) -> some AsynchronousUnitOfWork<S, Failure> where Failure == Error {
        Workers.FlatMap(priority: priority, upstream: self, transform: transform)
    }
    
    public func flatMap<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async -> S) -> some AsynchronousUnitOfWork<S, Failure> where Failure == Never {
        Workers.FlatMap(priority: priority, upstream: self, transform: transform)
    }
    
    public func flatMap<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable () async throws -> S) -> some AsynchronousUnitOfWork<S, Failure> where Success == Void, Failure == Error {
        Workers.FlatMap(priority: priority, upstream: self, transform: { _ in try await transform() })
    }
    
    public func flatMap<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable () async -> S) -> some AsynchronousUnitOfWork<S, Failure> where Success == Void, Failure == Never {
        Workers.FlatMap(priority: priority, upstream: self, transform: { _ in await transform() })
    }
}
