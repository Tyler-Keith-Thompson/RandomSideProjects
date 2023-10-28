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

        init<U: AsynchronousUnitOfWork>(upstream: U, newValue: Success) where U.Success == Success? {
            state = TaskState {
                if let val = try await upstream.operation() {
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

extension AsynchronousUnitOfWork {
    public func replaceNil<S: Sendable>(with value: S) -> some AsynchronousUnitOfWork<S> where Success == S? {
        Workers.ReplaceNil<S>(upstream: self, newValue: value)
    }
}
