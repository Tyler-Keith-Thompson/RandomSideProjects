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
                    let taskResult = try await upstream.operation()
                    try Task.checkCancellation()
                    return taskResult
                }
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: UInt64(duration.converted(to: .nanoseconds).value))
                    task.cancel()
                }
                
                return try await Task {
                    try Task.checkCancellation()
                    let result = try await task.value
                    try Task.checkCancellation()
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
