//
//  Map.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    public struct Map<Success: Sendable>: AsynchronousUnitOfWork {
        public typealias Failure = Error
        public let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async -> Success) {
            taskCreator = {
                Task(priority: priority) {
                    await transform(try await upstream.taskCreator().value)
                }
            }
        }
    }
    
    public struct TryMap<Success: Sendable>: AsynchronousUnitOfWork {
        public typealias Failure = Error
        public let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, @_implicitSelfCapture transform: @escaping @Sendable (U.Success) async throws -> Success) {
            taskCreator = {
                Task(priority: priority) {
                    try await transform(await upstream.taskCreator().value)
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func map<S: Sendable>(priority: TaskPriority? = nil, @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async -> S) -> some AsynchronousUnitOfWork<S, Error> {
        Workers.Map(priority: priority, upstream: self, transform: transform)
    }
    
    public func tryMap<S: Sendable>(priority: TaskPriority? = nil, @_implicitSelfCapture _ transform: @escaping @Sendable (Success) async throws -> S) -> some AsynchronousUnitOfWork<S, Error> {
        Workers.TryMap(priority: priority, upstream: self, transform: transform)
    }
}
