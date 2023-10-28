//
//  Share.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    actor Share<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        let state: TaskState<Success, Failure>
        private lazy var task = state.createTask()
        
        init<U: AsynchronousUnitOfWork>(upstream: U) where U.Success == Success, U.Failure == Failure {
            state = upstream.state
        }
        
        public var result: Result<Success, Failure> {
            get async {
                await task.result
            }
        }
        
        nonisolated public func execute() {
            Task { await task }
        }
    }
}

extension AsynchronousUnitOfWork {
    public func share() -> some AsynchronousUnitOfWork<Success, Failure> { Workers.Share(upstream: self) }
}
