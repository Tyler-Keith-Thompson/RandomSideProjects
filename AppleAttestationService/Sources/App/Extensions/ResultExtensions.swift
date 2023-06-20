//
//  ResultExtensions.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation

extension Result {
    func merge<NewFailure>(_ other: @autoclosure () -> Result<Success, NewFailure>) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure:
            return other()
        }
    }
}
