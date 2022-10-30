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
//    func catchStatus(_ status: UInt, andThrow errorHandler: @escaping (HTTPURLResponse) -> Error) -> Publishers.TryMap<Self, Output> {
//        tryMap {
//            guard $0.response.statusCode == status else {
//                return (data: $0.data, response: $0.response)
//            }
//
//            throw errorHandler($0.response)
//        }
//    }
//
//    func `catch`<E: HTTPError>(_ httpError: E) -> Publishers.TryMap<Self, Output> {
//        catchStatus(httpError.httpStatusCode) { _ in httpError }
//    }
//
//    func respondToRateLimiting(tolerance: Int = 50) -> AnyPublisher<Output, Failure> {
//        catchStatus(API.ClientError.tooManyRequests.httpStatusCode) { API.ClientError.tooManyRequests(retryAfter: $0.retryAfter) }
//            .tryCatch(API.ClientError.self) { err -> AnyPublisher<Output, Failure> in
//                guard case .tooManyRequests(.some(let retryAfter)) = err else {
//                    throw err
//                }
//
//                return self.delay(for: .seconds(retryAfter.converted(to: .seconds).value),
//                                  tolerance: .milliseconds(tolerance),
//                                  scheduler: DispatchQueue.global(qos: .userInitiated),
//                                  options: nil)
//                .retryOn(API.ClientError.tooManyRequests)
//                .eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
//    }
}
