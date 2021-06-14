//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//

import Foundation
struct GraphQLError: Codable {
    let message: String
    let locations: [Location]
    let path: [String]
}

extension GraphQLError {
    struct Location: Codable {
        let line: UInt
        let column: UInt
    }
}
