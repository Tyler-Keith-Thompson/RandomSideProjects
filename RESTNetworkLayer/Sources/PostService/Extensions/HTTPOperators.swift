//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine

import RESTNetworkLayer

extension Publisher {
    public func catchUnauthorizedAndRetryRequestWithFreshAccessToken() -> AnyPublisher<Output, Failure> where Output == RESTAPIProtocol.Output, Failure == Error {
        catchHTTPErrors()
            .tryCatch(HTTPClientError.unauthorized) { err -> AnyPublisher<Output, Failure> in
                IdentityService().refresh
                    .flatMap { _ in self.catchHTTPErrors() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
