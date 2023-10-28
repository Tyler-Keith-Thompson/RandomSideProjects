//
//  ReplaceError.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation
extension Workers {
    struct ReplaceError<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(upstream: U, newValue: Success) where U.Success == Success {
            state = TaskState {
                do {
                    return try await upstream.operation()
                } catch {
                    return newValue
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func replaceError(with value: Success) -> some AsynchronousUnitOfWork<Success> {
        Workers.ReplaceError(upstream: self, newValue: value)
    }
}
