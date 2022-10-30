//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/29/22.
//

import Foundation

extension URLRequest {
    public func addingValue(_ value: String, forHTTPHeaderField header: String) -> URLRequest {
        var request = self
        request.setValue(value, forHTTPHeaderField: header)
        return request
    }
}
