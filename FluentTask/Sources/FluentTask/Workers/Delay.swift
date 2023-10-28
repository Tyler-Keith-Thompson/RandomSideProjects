//
//  Delay.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    struct Delay<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork, C: Clock>(priority: TaskPriority?, upstream: U, duration: C.Instant.Duration, tolerance: C.Instant.Duration?, clock: C) where Failure == Error, U.Success == Success, U.Failure == Failure {
            taskCreator = {
                Task(priority: priority) {
                    let val = try await upstream.taskCreator().value
                    try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
                    return val
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork where Failure == Error {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    public func delay<C: Clock>(priority: TaskPriority? = nil, for duration: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C = ContinuousClock()) -> some AsynchronousUnitOfWork<Success, Failure> {
        Workers.Delay(priority: priority, upstream: self, duration: duration, tolerance: tolerance, clock: clock)
    }
}
