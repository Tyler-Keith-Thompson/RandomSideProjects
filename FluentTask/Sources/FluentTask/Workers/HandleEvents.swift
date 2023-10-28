//
//  HandleEvents.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation

extension Workers {
    struct HandleEvents<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>

        init<U: AsynchronousUnitOfWork>(upstream: U, receiveOutput: ((Success) async throws -> Void)?, receiveError: ((Error) async throws -> Void)?, receiveCancel: (() async throws -> Void)?) where U.Success == Success {
            state = TaskState {
                try await withTaskCancellationHandler {
                    do {
                        let val = try await upstream.operation()
                        try Task.checkCancellation()
                        try await receiveOutput?(val)
                        return val
                    } catch {
                        if !(error is CancellationError) {
                            try await receiveError?(error)
                        }
                        throw error
                    }
                } onCancel: {
                    if let receiveCancel {
                        Task { try await receiveCancel() }
                    }
                }
            }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func handleEvents(receiveOutput: ((Success) async throws -> Void)? = nil, receiveError: ((Error) async throws -> Void)? = nil, receiveCancel: (() async throws -> Void)? = nil) -> some AsynchronousUnitOfWork<Success> {
        Workers.HandleEvents(upstream: self, receiveOutput: receiveOutput, receiveError: receiveError, receiveCancel: receiveCancel)
    }
}
