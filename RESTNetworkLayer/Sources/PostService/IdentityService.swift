//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine

import RESTNetworkLayer

struct IdentityService: RESTAPIProtocol {
    static var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    var refresh: RESTAPIProtocol.ErasedHTTPDataTaskPublisher {
        post(endpoint: "token", body: try? Self.jsonEncoder.encode([
            "grant_type": "refresh_token",
            "refresh_token": User.shared.refreshToken
        ])) {
            $0.sendingJSON()
                .receivingJSON()
        }
        .tryMap {
            User.shared = try Self.jsonDecoder.decode(User.self, from: $0.data)
            return $0
        }
        .eraseToAnyPublisher()
    }

    var host: String {
        "api.prosper.com"
    }

    var baseURL: String {
        "https://\(host)/v1/security/oauth/"
    }
}
