//
//  Share.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    actor Share<Success: Sendable>: AsynchronousUnitOfWork {
        let state: TaskState<Success>
        private lazy var task = state.setLazyTask()
        
        init<U: AsynchronousUnitOfWork>(upstream: U) where U.Success == Success {
            state = upstream.state
        }
        
        public var result: Result<Success, Error> {
            get async {
                await task.result
            }
        }
        
        nonisolated public func run() throws {
            guard !state.isCancelled else { throw CancellationError() }
            Task { try await task.value }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func share() -> some AsynchronousUnitOfWork<Success> & AnyActor { Workers.Share(upstream: self) }
}
