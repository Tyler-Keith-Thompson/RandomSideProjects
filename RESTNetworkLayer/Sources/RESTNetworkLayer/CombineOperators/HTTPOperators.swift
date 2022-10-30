//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine

extension Publisher {
    public func catchHTTPErrors() -> Publishers.TryMap<Self, Output> where Output == RESTAPIProtocol.Output {
        tryMap {
            guard let err: any HTTPError = HTTPClientError(code: UInt($0.response.statusCode)) ?? HTTPServerError(code: UInt($0.response.statusCode)) else {
                return $0
            }

            if $0.response.statusCode == 429,
                let retryAfter = $0.response.retryAfter {
                throw HTTPClientError.tooManyRequests(retryAfter: retryAfter)
            }

            throw err
        }
    }

    public func respondToRateLimiting(maxSecondsToWait: Double = 1) -> AnyPublisher<Output, Failure> where Output == RESTAPIProtocol.Output, Failure == Error {
        tryCatch(HTTPClientError.tooManyRequests()) { err -> AnyPublisher<Output, Failure> in
            guard case .tooManyRequests(let retryAfter) = err else {
                throw err // shouldn't ever really happen
            }

            let delayInSeconds = retryAfter?.converted(to: .seconds).value ?? maxSecondsToWait

            return self.delay(for: .seconds(delayInSeconds),
                              scheduler: DispatchQueue.global(qos:.userInitiated),
                              options: nil)
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
