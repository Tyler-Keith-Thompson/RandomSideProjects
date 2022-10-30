//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import Combine

import RESTNetworkLayer

public protocol PostService {
    var getPosts: AnyPublisher<Result<[Post], Error>, Never> { get }
}

struct _PostService: RESTAPIProtocol, PostService {
    var baseURL = "https://api.myforum.com"
    var getPosts: AnyPublisher<Result<[Post], Error>, Never> {
        self.get(endpoint: "/posts") { request in
            request
            .addingBearerAuthorization(accessToken: User.shared.accessToken)
            .receivingJSON()
        }
        .catchHTTPErrors()
        .catchUnauthorizedAndRetryRequestWithFreshAccessToken()
        .map(\.data)
        .decode(type: [Post].self, decoder: JSONDecoder())
        .map(Result.success)
        .catch { Just(.failure($0)) }
        .eraseToAnyPublisher()
    }
}
