//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation

public struct DeferredTask<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
    public let taskCreator: @Sendable () -> Task<Success, Failure>

    public init(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture operation: @escaping @Sendable () async throws -> Success) where Failure == Error {
        taskCreator = {
            Task(priority: priority, operation: operation)
        }
    }
    
    public init(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture operation: @escaping @Sendable () async -> Success) where Failure == Never {
        taskCreator = {
            Task(priority: priority, operation: operation)
        }
    }
}
