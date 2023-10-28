//
//  Zip.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Zip<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>
        
        init<U: AsynchronousUnitOfWork, D: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, downstream: D) where Success == (U.Success, D.Success) {
            state = TaskState {
                try Task.checkCancellation()
                async let u = try await upstream.operation()
                async let d = try await downstream.operation()
                let returnVal = (try await u, try await d)
                try Task.checkCancellation()
                return returnVal
            }
        }
    }
    
    struct Zip3<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>
        
        init<U: AsynchronousUnitOfWork, D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, d0: D0, d1: D1) where Success == (U.Success, D0.Success, D1.Success) {
            state = TaskState {
                try Task.checkCancellation()
                async let u = try await upstream.operation()
                async let d_0 = try await d0.operation()
                async let d_1 = try await d1.operation()
                
                let returnVal = (try await u, try await d_0, try await d_1)
                try Task.checkCancellation()
                return returnVal
            }
        }
    }
    
    struct Zip4<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>
        
        init<U: AsynchronousUnitOfWork, D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, d0: D0, d1: D1, d2: D2) where Success == (U.Success, D0.Success, D1.Success, D2.Success) {
            state = TaskState {
                try Task.checkCancellation()
                async let u = try await upstream.operation()
                async let d_0 = try await d0.operation()
                async let d_1 = try await d1.operation()
                async let d_2 = try await d2.operation()
                
                let returnVal = (try await u, try await d_0, try await d_1, try await d_2)
                try Task.checkCancellation()
                return returnVal
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func zip<D: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ downstream: D) -> some AsynchronousUnitOfWork<(Success, D.Success)> {
        Workers.Zip(priority: priority, upstream: self, downstream: downstream)
    }
    
    public func zip<D: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ downstream: D, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D.Success)) async throws -> T) -> some AsynchronousUnitOfWork<T> {
        Workers.TryMap<T>(priority: priority, upstream: Workers.Zip<(Success, D.Success)>(priority: priority, upstream: self, downstream: downstream), transform: transform)
    }
    
    // zip3
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1) -> some AsynchronousUnitOfWork<(Success, D0.Success, D1.Success)> {
        Workers.Zip3(priority: priority, upstream: self, d0: d0, d1: d1)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D0.Success, D1.Success)) async throws -> T) -> some AsynchronousUnitOfWork<T> {
        Workers.TryMap<T>(priority: priority, upstream: Workers.Zip3<(Success, D0.Success, D1.Success)>(priority: priority, upstream: self, d0: d0, d1: d1), transform: transform)
    }
    
    // zip4
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, _ d2: D2) -> some AsynchronousUnitOfWork<(Success, D0.Success, D1.Success, D2.Success)> {
        Workers.Zip4(priority: priority, upstream: self, d0: d0, d1: d1, d2: d2)
    }
    
    public func zip<D0: AsynchronousUnitOfWork, D1: AsynchronousUnitOfWork, D2: AsynchronousUnitOfWork, T: Sendable>(priority: TaskPriority? = nil, _ d0: D0, _ d1: D1, _ d2: D2, @_inheritActorContext @_implicitSelfCapture transform: @escaping @Sendable ((Success, D0.Success, D1.Success, D2.Success)) async throws -> T) -> some AsynchronousUnitOfWork<T> {
        Workers.TryMap<T>(priority: priority, upstream: Workers.Zip4<(Success, D0.Success, D1.Success, D2.Success)>(priority: priority, upstream: self, d0: d0, d1: d1, d2: d2), transform: transform)
    }
}
