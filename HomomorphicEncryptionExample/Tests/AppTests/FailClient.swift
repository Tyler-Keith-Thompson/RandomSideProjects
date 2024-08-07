//
//  FailClient.swift
//  HomomorphicEncryptionExample
//
//  Created by Tyler Thompson on 8/6/24.
//

import Foundation
import Vapor
import XCTest

struct FailClient: Client {
    func send(_ request: Vapor.ClientRequest) -> NIOCore.EventLoopFuture<Vapor.ClientResponse> {
        XCTFail("Unexpected request: \(request)")
        return eventLoop.makeFailedFuture(URLError(.badURL))
    }

    var eventLoop: any NIOCore.EventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()

    func delegating(to _: any NIOCore.EventLoop) -> any Vapor.Client {
        return self
    }
}
