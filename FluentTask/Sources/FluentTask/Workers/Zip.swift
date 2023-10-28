//
//  Zip.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Zip<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, downstream: D) where U.Failure == D.Failure, Failure == U.Failure, Success == (U.Success, D.Success), Failure == Error {
            taskCreator = {
                Task(priority: priority) {
                    async let u = try await upstream.taskCreator().value
                    async let d = try await downstream.taskCreator().value
                    return (try await u, try await d)
                }
            }
        }

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, downstream: D) where U.Failure == D.Failure, Failure == U.Failure, Success == (U.Success, D.Success), Failure == Never {
            taskCreator = {
                Task(priority: priority) {
                    async let u = await upstream.taskCreator().value
                    async let d = await downstream.taskCreator().value
                    return (await u, await d)
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func zip<D: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ downstream: D) -> some AsynchronousUnitOfWork<(Success, D.Success), Failure> where Failure == D.Failure, Failure == Error {
        Workers.Zip(priority: priority, upstream: self, downstream: downstream)
    }
    
    public func zip<D: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ downstream: D) -> some AsynchronousUnitOfWork<(Success, D.Success), Failure> where Failure == D.Failure, Failure == Never {
        Workers.Zip(priority: priority, upstream: self, downstream: downstream)
    }
    
    public func zip<D: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ downstream: D, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D.Success)) async throws -> T) -> some AsynchronousUnitOfWork<T, Error> where Failure == D.Failure, Failure == Error {
        Workers.TryMap<T>(priority: priority, upstream: Workers.Zip<(Success, D.Success), Error>(priority: priority, upstream: self, downstream: downstream), transform: transform)
    }
    
    public func zip<D: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ downstream: D, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D.Success)) async -> T) -> some AsynchronousUnitOfWork<T, Error> where Failure == D.Failure, Failure == Never {
        Workers.Map<T>(priority: priority, upstream: Workers.Zip<(Success, D.Success), Never>(priority: priority, upstream: self, downstream: downstream), transform: transform)
    }
}
