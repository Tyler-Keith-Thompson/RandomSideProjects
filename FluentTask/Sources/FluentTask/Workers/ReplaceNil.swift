//
//  ReplaceNil.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
extension Workers {
    struct ReplaceNil<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let taskCreator: @Sendable () -> Task<Success, Failure>
        
        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, newValue: Success) where U.Success == Success?, U.Failure == Failure, Failure == Error {
            taskCreator = {
                Task(priority: priority) {
                    if let val = try await upstream.taskCreator().value {
                        return val
                    } else {
                        return newValue
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork where Failure == Error {
    public func replaceNil<S: Sendable>(priority: TaskPriority? = nil, with value: S) -> some AsynchronousUnitOfWork<S, Failure> where Success == S? {
        Workers.ReplaceNil<S, Failure>(priority: priority, upstream: self, newValue: value)
    }
}
