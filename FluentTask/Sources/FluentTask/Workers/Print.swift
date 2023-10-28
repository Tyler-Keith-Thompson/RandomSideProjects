//
//  Print.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation

extension AsynchronousUnitOfWork {
    public func print(_ prefix: String = "") -> some AsynchronousUnitOfWork<Success> {
        handleEvents {
            Swift.print("\(prefix) received output: \($0)")
        } receiveError: {
            Swift.print("\(prefix) received error: \($0)")
        } receiveCancel: {
            Swift.print("\(prefix) received cancellation")
        }
    }
}
