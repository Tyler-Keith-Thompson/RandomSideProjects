//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation

public enum HTTPClientError: HTTPError, CaseIterable {
    public static var allCases: [Self] = [
        .badRequest,
        .unauthorized,
        .paymentRequired,
        .forbidden,
        .notFound,
        .methodNotAllowed,
        .notAcceptable,
        .proxyAuthenticationRequired,
        .requestTimeout,
        .conflict,
        .gone,
        .lengthRequired,
        .preconditionFailed,
        .payloadTooLarge,
        .requestURITooLong,
        .unsupportedMediaType,
        .requestedRangeNotSatisfiable,
        .expectationFailed,
        .misdirectedRequest,
        .unprocessableEntity,
        .locked,
        .failedDependency,
        .upgradeRequired,
        .preconditionRequired,
        .tooManyRequests,
        .requestHeaderFieldTooLarge,
        .connectionClosedWithoutResponse,
        .unavailableForLegalReasons,
        .clientClosedRequest
    ]

    public init?(code: UInt) {
        if let errorForCode = Self.allCases.first(where: { $0.statusCode == code }) {
            self = errorForCode
        }
        return nil
    }

    case badRequest
    case unauthorized // Okay to retry request with new credentials or tokens
    case paymentRequired
    case forbidden // Do not retry request with the same credentials
    case notFound
    case methodNotAllowed
    case notAcceptable // Automatic resolution to preferred accept types?
    case proxyAuthenticationRequired // Manual resolution possible
    case requestTimeout // Automatic retry okay with a new connection
    case conflict // Manual resolution possible
    case gone
    case lengthRequired // Unlikely since Content-Length is included by default
    case preconditionFailed
    case payloadTooLarge // Automatic resolution possible with Retry-After
    case requestURITooLong
    case unsupportedMediaType
    case requestedRangeNotSatisfiable // Automatic resolution potential: https://httpstatuses.com/416
    case expectationFailed
    case misdirectedRequest // Manual resolution possible
    case unprocessableEntity
    case locked // Perhaps enum should be expanded to indicate lock status: https://httpstatuses.com/423
    case failedDependency
    case upgradeRequired // Possible automatic resolution? https://httpstatuses.com/426
    case preconditionRequired
    case tooManyRequests(retryAfter: Measurement<UnitDuration>? = nil)
    case requestHeaderFieldTooLarge
    case connectionClosedWithoutResponse
    case unavailableForLegalReasons // Resulting body should probably be displayed to user
    case clientClosedRequest

    static let tooManyRequests = Self.tooManyRequests()

    public var statusCode: UInt {
        switch self {
            case .badRequest: return 400
            case .unauthorized: return 401
            case .paymentRequired: return 402
            case .forbidden: return 403
            case .notFound: return 404
            case .methodNotAllowed: return 405
            case .notAcceptable: return 406
            case .proxyAuthenticationRequired: return 407
            case .requestTimeout: return 408
            case .conflict: return 409
            case .gone: return 410
            case .lengthRequired: return 411
            case .preconditionFailed: return 412
            case .payloadTooLarge: return 413
            case .requestURITooLong: return 414
            case .unsupportedMediaType: return 415
            case .requestedRangeNotSatisfiable: return 416
            case .expectationFailed: return 417
            case .misdirectedRequest: return 421
            case .unprocessableEntity: return 422
            case .locked: return 423
            case .failedDependency: return 424
            case .upgradeRequired: return 426
            case .preconditionRequired: return 428
            case .tooManyRequests: return 429
            case .requestHeaderFieldTooLarge: return 431
            case .connectionClosedWithoutResponse: return 444
            case .unavailableForLegalReasons: return 451
            case .clientClosedRequest: return 499
        }
    }
}
