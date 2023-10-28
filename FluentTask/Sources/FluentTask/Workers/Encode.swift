//
//  Encode.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation

public protocol TopLevelEncoder<Output> {
    associatedtype Output
    func encode<T: Encodable>(_ value: T) throws -> Output
}

extension JSONEncoder: TopLevelEncoder { }

extension Workers {
    struct Encode<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork, E: TopLevelEncoder>(priority: TaskPriority?, upstream: U, encoder: E) where Success == E.Output, U.Success: Encodable {
            state = TaskState {
                Task(priority: priority) {
                    let val = try await upstream.createTask().value
                    try Task.checkCancellation()
                    return try encoder.encode(val)
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func encode<E: TopLevelEncoder>(priority: TaskPriority? = nil, encoder: E) -> some AsynchronousUnitOfWork<E.Output> where Success: Encodable {
        Workers.Encode(priority: priority, upstream: self, encoder: encoder)
    }
}
