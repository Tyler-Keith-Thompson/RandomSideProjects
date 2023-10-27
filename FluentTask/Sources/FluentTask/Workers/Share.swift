//
//  Share.swift
//
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

extension Workers {
    public actor Share<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
        public let taskCreator: @Sendable () -> Task<Success, Failure>
        private lazy var task = taskCreator()
        
        init<U: AsynchronousUnitOfWork>(upstream: U) where U.Success == Success, U.Failure == Failure {
            taskCreator = upstream.taskCreator
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
