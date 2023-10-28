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

        init<U: AsynchronousUnitOfWork, E: TopLevelEncoder>(upstream: U, encoder: E) where Success == E.Output, U.Success: Encodable {
            state = TaskState {
                try encoder.encode(try await upstream.operation())
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func encode<E: TopLevelEncoder>(encoder: E) -> some AsynchronousUnitOfWork<E.Output> where Success: Encodable {
        Workers.Encode(upstream: self, encoder: encoder)
    }
}
