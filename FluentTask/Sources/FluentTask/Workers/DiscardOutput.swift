//
//  DiscardOutput.swift
//
//
//  Created by Tyler Thompson on 10/28/23.
//

import Foundation

extension AsynchronousUnitOfWork {
    public func discardOutput() -> some AsynchronousUnitOfWork<Void> {
        map { _ in }
    }
}
