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

        init<U: AsynchronousUnitOfWork>(upstream: U, retries: UInt) where U.Success == Success {
            guard retries > 0 else { state = upstream.state; return }
            state = TaskState {
                for _ in 0..<retries {
                    do {
                        return try await upstream.operation()
                    } catch {
                        continue
                    }
                }
                
                return try await upstream.operation()
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func retry(_ retries: UInt = 1) -> some AsynchronousUnitOfWork<Success> {
        Workers.Retry(upstream: self, retries: retries)
    }
}
