//
//  ReplaceNil.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
extension Workers {
    struct ReplaceNil<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, newValue: Success) where U.Success == Success? {
            state = TaskState {
                Task(priority: priority) {
                    if let val = try await upstream.createTask().value {
                        try Task.checkCancellation()
                        return val
                    } else {
                        try Task.checkCancellation()
                        return newValue
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func replaceNil<S: Sendable>(priority: TaskPriority? = nil, with value: S) -> some AsynchronousUnitOfWork<S> where Success == S? {
        Workers.ReplaceNil<S>(priority: priority, upstream: self, newValue: value)
    }
}
