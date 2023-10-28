//
//  Zip.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Zip<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, downstream: D) where U.Failure == D.Failure, Failure == U.Failure, Success == (U.Success, D.Success), Failure == Error {
            state = TaskState {
                Task(priority: priority) {
                    async let u = try await upstream.createTask().value
                    async let d = try await downstream.createTask().value
                    return (try await u, try await d)
                }
            }
        }

        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, downstream: D) where U.Failure == D.Failure, Failure == U.Failure, Success == (U.Success, D.Success), Failure == Never {
            state = TaskState {
                Task(priority: priority) {
                    async let u = await upstream.createTask().value
                    async let d = await downstream.createTask().value
                    return (await u, await d)
                }
            }
        }
    }
    
    struct Zip3<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork, D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, d0: D0, d1: D1) where U.Failure == D0.Failure, D0.Failure == D1.Failure, Failure == U.Failure, Success == (U.Success, D0.Success, D1.Success), Failure == Error {
            state = TaskState {
                Task(priority: priority) {
                    async let u = try await upstream.createTask().value
                    async let d_0 = try await d0.createTask().value
                    async let d_1 = try await d1.createTask().value
                    return (try await u, try await d_0, try await d_1)
                }
            }
        }

        init<U: AsynchronousUnitOfWork, D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, d0: D0, d1: D1) where U.Failure == D0.Failure, D0.Failure == D1.Failure, Failure == U.Failure, Success == (U.Success, D0.Success, D1.Success), Failure == Never {
            state = TaskState {
                Task(priority: priority) {
                    async let u = await upstream.createTask().value
                    async let d_0 = await d0.createTask().value
                    async let d_1 = await d1.createTask().value
                    return (await u, await d_0, await d_1)
                }
            }
        }
    }
    
    struct Zip4<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>

        init<U: AsynchronousUnitOfWork, D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, d0: D0, d1: D1, d2: D2) where U.Failure == D0.Failure, D0.Failure == D1.Failure, D1.Failure == D2.Failure, Failure == U.Failure, Success == (U.Success, D0.Success, D1.Success, D2.Success), Failure == Error {
            state = TaskState {
                Task(priority: priority) {
                    async let u = try await upstream.createTask().value
                    async let d_0 = try await d0.createTask().value
                    async let d_1 = try await d1.createTask().value
                    async let d_2 = try await d2.createTask().value
                    return (try await u, try await d_0, try await d_1, try await d_2)
                }
            }
        }

        init<U: AsynchronousUnitOfWork, D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, d0: D0, d1: D1, d2: D2) where U.Failure == D0.Failure, D0.Failure == D1.Failure, D1.Failure == D2.Failure, Failure == U.Failure, Success == (U.Success, D0.Success, D1.Success, D2.Success), Failure == Never {
            state = TaskState {
                Task(priority: priority) {
                    async let u = await upstream.createTask().value
                    async let d_0 = await d0.createTask().value
                    async let d_1 = await d1.createTask().value
                    async let d_2 = await d2.createTask().value
                    return (await u, await d_0, await d_1, await d_2)
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
    
    // zip3
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1) -> some AsynchronousUnitOfWork<(Success, D0.Success, D1.Success), Failure> where Failure == D0.Failure, D0.Failure == D1.Failure, Failure == Error {
        Workers.Zip3(priority: priority, upstream: self, d0: d0, d1: d1)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1) -> some AsynchronousUnitOfWork<(Success, D0.Success, D1.Success), Failure> where Failure == D0.Failure, D0.Failure == D1.Failure, Failure == Never {
        Workers.Zip3(priority: priority, upstream: self, d0: d0, d1: d1)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D0.Success, D1.Success)) async throws -> T) -> some AsynchronousUnitOfWork<T, Error> where Failure == D0.Failure, D0.Failure == D1.Failure, Failure == Error {
        Workers.TryMap<T>(priority: priority, upstream: Workers.Zip3<(Success, D0.Success, D1.Success), Error>(priority: priority, upstream: self, d0: d0, d1: d1), transform: transform)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D0.Success, D1.Success)) async -> T) -> some AsynchronousUnitOfWork<T, Error> where Failure == D0.Failure, D0.Failure == D1.Failure, Failure == Never {
        Workers.Map<T>(priority: priority, upstream: Workers.Zip3<(Success, D0.Success, D1.Success), Never>(priority: priority, upstream: self, d0: d0, d1: d1), transform: transform)
    }
    
    // zip4
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, _ d2: D2) -> some AsynchronousUnitOfWork<(Success, D0.Success, D1.Success, D2.Success), Failure> where Failure == D0.Failure, D0.Failure == D1.Failure, D1.Failure == D2.Failure, Failure == Error {
        Workers.Zip4(priority: priority, upstream: self, d0: d0, d1: d1, d2: d2)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, _ d2: D2) -> some AsynchronousUnitOfWork<(Success, D0.Success, D1.Success, D2.Success), Failure> where Failure == D0.Failure, D0.Failure == D1.Failure, D1.Failure == D2.Failure, Failure == Never {
        Workers.Zip4(priority: priority, upstream: self, d0: d0, d1: d1, d2: d2)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, _ d2: D2, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D0.Success, D1.Success, D2.Success)) async throws -> T) -> some AsynchronousUnitOfWork<T, Error> where Failure == D0.Failure, D0.Failure == D1.Failure, D1.Failure == D2.Failure, Failure == Error {
        Workers.TryMap<T>(priority: priority, upstream: Workers.Zip4<(Success, D0.Success, D1.Success, D2.Success), Error>(priority: priority, upstream: self, d0: d0, d1: d1, d2: d2), transform: transform)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, _ d2: D2, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D0.Success, D1.Success, D2.Success)) async -> T) -> some AsynchronousUnitOfWork<T, Error> where Failure == D0.Failure, D0.Failure == D1.Failure, D1.Failure == D2.Failure, Failure == Never {
        Workers.Map<T>(priority: priority, upstream: Workers.Zip4<(Success, D0.Success, D1.Success, D2.Success), Never>(priority: priority, upstream: self, d0: d0, d1: d1, d2: d2), transform: transform)
    }
}
