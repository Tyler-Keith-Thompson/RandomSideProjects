//
//  Retry.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    struct Retry<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, retries: UInt) where U.Success == Success {
            guard retries > 0 else { state = upstream.state; return }
            state = TaskState {
                for _ in 0..<retries {
                    try Task.checkCancellation()
                    do {
                        return try await upstream.operation()
                    } catch {
                        continue
                    }
                }
                
                try Task.checkCancellation()
                return try await upstream.operation()
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func retry(priority: TaskPriority? = nil, _ retries: UInt = 1) -> some AsynchronousUnitOfWork<Success> {
        Workers.Retry(priority: priority, upstream: self, retries: retries)
    }
}
