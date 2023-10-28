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

        init<U: AsynchronousUnitOfWork>(priority: TaskPriority?, upstream: U, receiveOutput: ((Success) async throws -> Void)?, receiveError: ((Error) async throws -> Void)?, receiveCancel: (() async throws -> Void)?) where U.Success == Success {
            state = TaskState {
                Task(priority: priority) {
                    try await withTaskCancellationHandler {
                        do {
                            let val = try await upstream.createTask().value
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
}

extension AsynchronousUnitOfWork {
    public func handleEvents(priority: TaskPriority? = nil, receiveOutput: ((Success) async throws -> Void)? = nil, receiveError: ((Error) async throws -> Void)? = nil, receiveCancel: (() async throws -> Void)? = nil) -> some AsynchronousUnitOfWork<Success> {
        Workers.HandleEvents(priority: priority, upstream: self, receiveOutput: receiveOutput, receiveError: receiveError, receiveCancel: receiveCancel)
    }
}
