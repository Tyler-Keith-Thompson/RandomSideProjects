//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
@_exported import AsyncAlgorithms

public struct DeferredTask<Success: Sendable, Failure: Error>: AsynchronousUnitOfWork {
    public let state: TaskState<Success, Failure>

    public init(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture operation: @escaping @Sendable () async throws -> Success) where Failure == Error {
        state = TaskState {
            Task(priority: priority, operation: operation)
        }
    }
    
    public init(priority: TaskPriority? = nil, @_inheritActorContext @_implicitSelfCapture operation: @escaping @Sendable () async -> Success) where Failure == Never {
        state = TaskState {
            Task(priority: priority, operation: operation)
        }
    }
}
