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

            if $0.response.statusCode == 429 {
                throw HTTPClientError.tooManyRequests(retryAfter: $0.response.retryAfter)
            }

            throw err
        }
    }

    public func respondToRateLimiting(maxSecondsToWait: Double = 1) -> AnyPublisher<Output, Failure> where Output == RESTAPIProtocol.Output, Failure == Error {
        catchHTTPErrors()
            .tryCatch(HTTPClientError.tooManyRequests()) { err -> AnyPublisher<Output, Failure> in
                guard case .tooManyRequests(let retryAfter) = err else {
                    throw err // shouldn't ever really happen
                }

                let delayInSeconds: Double = {
                    if let serverDelay = retryAfter?.converted(to: .seconds).value,
                       serverDelay < maxSecondsToWait {
                        return serverDelay
                    }
                    return maxSecondsToWait
                }()

                return Just(()).delay(for: .seconds(delayInSeconds),
                                      scheduler: DispatchQueue.global(qos:.userInitiated),
                                      options: nil)
                .flatMap { _ in self.catchHTTPErrors() }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
