//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift

final class StubResponse {
    var stubs: [(condition: HTTPStubsTestBlock, response: HTTPStubsResponseBlock)] = []
    @discardableResult convenience init(on condition: @escaping HTTPStubsTestBlock, with response: @escaping HTTPStubsResponseBlock) {
        self.init(stubs: [(condition, response)])
    }

    private init(stubs: [(condition: HTTPStubsTestBlock, response: HTTPStubsResponseBlock)]) {
        self.stubs = stubs
        stub { req in
            let filtered = self.stubs.enumerated().filter { $0.element.condition(req) }
            return !filtered.isEmpty
        } response: { req in
            let filtered = self.stubs.enumerated().filter { $0.element.condition(req) }
            guard let first = filtered.first else { fatalError("No stub response found, something bad happened") }
            defer {
                if filtered.count > 1, let first = filtered.first {
                    self.stubs.remove(at: first.offset)
                }
            }
            return first.element.response(req)
        }
    }

    @discardableResult func thenRespond(on condition: @escaping HTTPStubsTestBlock, with response: @escaping HTTPStubsResponseBlock) -> Self {
        Self(stubs: stubs.appending((condition, response)))
    }
}


extension Array {
    fileprivate func appending(_ element: Element) -> Self {
        self + [element]
    }
}
