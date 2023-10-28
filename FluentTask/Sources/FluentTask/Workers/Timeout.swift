//
//  Timeout.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
extension Workers {
    struct Timeout<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, duration: Measurement<UnitDuration>) where Failure == Error, U.Success == Success, U.Failure == Failure {
            taskCreator = {
                let task = Task {
                    let taskResult = try await upstream.taskCreator().value
                    try Task.checkCancellation()
                    return taskResult
                }
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: UInt64(duration.converted(to: .nanoseconds).value))
                    task.cancel()
                }
                
                return Task(priority: priority) {
                    let result = try await task.value
                    timeoutTask.cancel()
                    return result
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork where Failure == Error {
    public func timeout(priority: TaskPriority? = nil, _ duration: Measurement<UnitDuration>) -> some AsynchronousUnitOfWork<Success, Failure> {
        Workers.Timeout(priority: priority, upstream: self, duration: duration)
    }
}
