//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation

public protocol HTTPError: Error, Equatable {
    var statusCode: UInt { get }

    init?(code: UInt)
}

extension HTTPError {
    public static func == (lhs: any HTTPError, rhs: any HTTPError) -> Bool {
        lhs.statusCode == rhs.statusCode
    }
}
