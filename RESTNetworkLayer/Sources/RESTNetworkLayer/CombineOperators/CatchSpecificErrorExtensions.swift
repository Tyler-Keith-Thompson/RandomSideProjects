//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import Combine

extension Publisher {
    public func tryCatch<E: Error & Equatable,
                         P: Publisher>(_ error: E,
                                       _ handler: @escaping (E) throws -> P) -> Publishers.TryCatch<Self, P> where Failure == Error {
        tryCatch { err in
            guard let unwrappedError = (err as? E),
                    unwrappedError == error else { throw err }
            return try handler(unwrappedError)
        }
    }
}
