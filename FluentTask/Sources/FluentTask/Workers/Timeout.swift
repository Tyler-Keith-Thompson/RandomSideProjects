//
//  Timeout.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
extension Workers {
    struct Timeout<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(upstream: U, duration: Measurement<UnitDuration>) where U.Success == Success {
            state = TaskState {
                let task = Task {
                    try await upstream.operation()
                }
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: UInt64(duration.converted(to: .nanoseconds).value))
                    task.cancel()
                }
                
                return try await Task {
                    let result = try await task.value
                    timeoutTask.cancel()
                    return result
                }.value
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func timeout(_ duration: Measurement<UnitDuration>) -> some AsynchronousUnitOfWork<Success> {
        Workers.Timeout(upstream: self, duration: duration)
    }
}
