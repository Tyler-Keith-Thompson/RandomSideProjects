//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine

extension Publisher {
    /// Attempts to recreate a failed subscription with the upstream publisher using a specified number of attempts to establish the connection.
    ///
    /// After exceeding the specified number of retries, the publisher passes the failure to the downstream receiver.
    /// - Parameter error: An equatable error that should trigger the retry
    /// - Parameter retries: The number of times to attempt to recreate the subscription.
    /// - Returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public func retryOn<E: Error & Equatable>(_ error: E, retries: UInt = 1) -> Publishers.TryCatch<Self, Publishers.Retry<Self>> where Failure == Error {
        tryCatch(error) { err -> Publishers.Retry<Self> in
            guard retries > 0 else {
                throw err
            }

            return retry(Int(retries) - 1)
        }
    }
}
