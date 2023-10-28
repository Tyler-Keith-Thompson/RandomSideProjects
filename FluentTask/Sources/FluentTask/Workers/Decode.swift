//
//  Decode.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation

public protocol TopLevelDecoder<Input> {
    associatedtype Input
    func decode<T: Decodable>(_ type: T.Type, from: Self.Input ) throws -> T
}

extension JSONDecoder: TopLevelDecoder { }

extension Workers {
    struct Decode<Success: Sendable & Decodable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork, D: TopLevelDecoder>(priority: TaskPriority?, upstream: U, decoder: D) where U.Success == D.Input {
            state = TaskState {
                Task(priority: priority) {
                    let val = try await upstream.createTask().value
                    try Task.checkCancellation()
                    return try decoder.decode(Success.self, from: val)
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func decode<T: Decodable, D: TopLevelDecoder>(priority: TaskPriority? = nil, type: T.Type, decoder: D) -> some AsynchronousUnitOfWork<T> where Success == D.Input {
        Workers.Decode(priority: priority, upstream: self, decoder: decoder)
    }
}
