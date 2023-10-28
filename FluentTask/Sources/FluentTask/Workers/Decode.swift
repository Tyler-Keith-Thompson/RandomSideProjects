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

        init<U: AsynchronousUnitOfWork, D: TopLevelDecoder>(upstream: U, decoder: D) where U.Success == D.Input {
            state = TaskState {
                let val = try await upstream.operation()
                try Task.checkCancellation()
                return try decoder.decode(Success.self, from: val)
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func decode<T: Decodable, D: TopLevelDecoder>(type: T.Type, decoder: D) -> some AsynchronousUnitOfWork<T> where Success == D.Input {
        Workers.Decode(upstream: self, decoder: decoder)
    }
}
