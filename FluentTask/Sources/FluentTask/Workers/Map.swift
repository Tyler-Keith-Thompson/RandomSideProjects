//
//  Map.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Map<Success: Sendable>: AsynchronousUnitOfWork {
        typealias Failure = Error
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async -> Success) {
            state = TaskState {
                Task(priority: priority) {
                    await transform(try await upstream.createTask().value)
                }
            }
        }
    }
    
    struct TryMap<Success: Sendable>: AsynchronousUnitOfWork {
        typealias Failure = Error
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async throws -> Success) {
            state = TaskState {
                Task(priority: priority) {
                    try await transform(await upstream.createTask().value)
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func map<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async -> S) -> some AsynchronousUnitOfWork<S, Error> {
        Workers.Map(priority: priority, upstream: self, transform: transform)
    }
    
    public func tryMap<S: Sendable>(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> S) -> some AsynchronousUnitOfWork<S, Error> {
        Workers.TryMap(priority: priority, upstream: self, transform: transform)
    }
}
