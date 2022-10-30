//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation

public enum HTTPServerError: UInt, HTTPError, CaseIterable {
    public var statusCode: UInt { return rawValue }

    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503 // Possible automatic resolution Retry-After: https://httpstatuses.com/503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case notExtended = 510 // Might need to be shown to user
    case networkAuthenticationRequired = 511 // Manual resolution possible
    case networkConnectTimeoutError = 599 // Not an RFC code

    public init?(code: UInt) {
        self.init(rawValue: code)
    }

}
