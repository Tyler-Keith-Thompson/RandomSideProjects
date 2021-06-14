//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//

import XCTVapor
import Fluent
import Swinject

@testable import App

extension Application {
    static var forTesting: Application {
        get throws {
            let app = Application(.testing)
            Container.default.register((database: DatabaseConfigurationFactory, id: DatabaseID).self) { _ in
                (database: .sqlite(.memory), id: .sqlite)
            }
            try app.configure()
            try app.autoRevert().wait()
            try app.autoMigrate().wait()
            return app
        }
    }

    func sendGraphBody(_ query: String,
                       file: StaticString = #file,
                       line: UInt = #line,
                       afterResponse: (XCTHTTPResponse) throws -> () = { _ in }) throws {
        try test(.POST, "graphql", beforeRequest: { req in
            try req.content.encode(["query": query])
        }, afterResponse: { res in
            try afterResponse(res)
        })
    }
}
