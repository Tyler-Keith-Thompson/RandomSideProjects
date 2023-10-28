//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/27/23.
//

import Foundation
@_exported import AsyncAlgorithms

public struct DeferredTask<Success: Sendable>: AsynchronousUnitOfWork {
    public let state: TaskState<Success>

    public init(@_inheritActorContext @_implicitSelfCapture operation: @escaping @Sendable () async throws -> Success) {
        state = TaskState(operation: operation)
    }
}
