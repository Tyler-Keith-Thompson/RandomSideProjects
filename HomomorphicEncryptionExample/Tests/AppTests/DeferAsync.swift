//
//  DeferAsync.swift
//  HomomorphicEncryptionExample
//
//  Created by Tyler Thompson on 8/6/24.
//

import Foundation

// This is a clever workaround to the fact that Swift doesn't support async deferred blocks
// Credit: https://forums.swift.org/t/async-support-in-defer-blocks/69455/8
// While there's technically no license, this is test only code and can really only be done in a limited number of ways
public func deferAsync(_ perform: @escaping @Sendable () async -> Void) async {
    for await _ in AsyncStream<Never>.makeStream().stream { }
    await Task { await perform() }.value
}
