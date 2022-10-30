//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import Combine

public protocol RESTAPIProtocol {
    typealias RequestModifier = ((URLRequest) -> URLRequest)
    typealias ErasedHTTPDataTaskPublisher = AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    typealias Output = ErasedHTTPDataTaskPublisher.Output
    typealias Failure = ErasedHTTPDataTaskPublisher.Failure

    var baseURL: String { get }
    var urlSession: URLSession { get }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 7.0, *)
extension RESTAPIProtocol {
    public var urlSession: URLSession { URLSession.shared }

    public func get(endpoint: String, requestModifier: @escaping RequestModifier = { $0 }) -> ErasedHTTPDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<Output, Failure>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    public func put(endpoint: String, body: Data?, requestModifier: @escaping RequestModifier = { $0 }) -> ErasedHTTPDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<Output, Failure>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    public func post(endpoint: String, body: Data?, requestModifier: @escaping RequestModifier = { $0 }) -> ErasedHTTPDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<Output, Failure>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    public func patch(endpoint: String, body: Data?, requestModifier: @escaping RequestModifier = { $0 }) -> ErasedHTTPDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<Output, Failure>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    public func delete(endpoint: String, requestModifier: @escaping RequestModifier = { $0 }) -> ErasedHTTPDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<Output, Failure>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    func createPublisher(for request: URLRequest, requestModifier: @escaping RequestModifier) -> ErasedHTTPDataTaskPublisher {
        Just(request)
            .flatMap { [urlSession] in
                urlSession.dataTaskPublisher(for: requestModifier($0))
            }
            .tryMap {
                guard let res = $0.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return (data: $0.data, response: res)
            }
            .eraseToAnyPublisher()
    }
}
