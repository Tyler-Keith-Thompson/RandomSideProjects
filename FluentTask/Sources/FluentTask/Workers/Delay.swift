//
//  Delay.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    struct Delay<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork, C: Clock>(priority: TaskPriority?, upstream: U, duration: C.Instant.Duration, tolerance: C.Instant.Duration?, clock: C) where U.Success == Success {
            state = TaskState {
                Task(priority: priority) {
                    let val = try await upstream.createTask().value
                    try Task.checkCancellation()
                    try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
                    return val
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    public func delay<C: Clock>(priority: TaskPriority? = nil, for duration: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C = ContinuousClock()) -> some AsynchronousUnitOfWork<Success> {
        Workers.Delay(priority: priority, upstream: self, duration: duration, tolerance: tolerance, clock: clock)
    }
}
