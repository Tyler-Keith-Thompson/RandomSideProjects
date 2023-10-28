//
//  Retry.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Retry<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, retries: UInt) where Failure == Error, U.Success == Success, U.Failure == Failure {
            guard retries > 0 else { taskCreator = upstream.taskCreator; return }
            taskCreator = {
                Task(priority: priority) {
                    for _ in 0..<retries {
                        try Task.checkCancellation()
                        do {
                            return try await upstream.taskCreator().value
                        } catch {
                            continue
                        }
                    }
                    
                    try Task.checkCancellation()
                    return try await upstream.taskCreator().value
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork where Failure == Error {
    public func retry(priority: TaskPriority? = nil, _ retries: UInt = 1) -> some AsynchronousUnitOfWork<Success, Failure> {
        Workers.Retry(priority: priority, upstream: self, retries: retries)
    }
}
