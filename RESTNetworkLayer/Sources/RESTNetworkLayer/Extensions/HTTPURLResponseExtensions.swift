//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation

extension HTTPURLResponse {
    var retryAfter: Measurement<UnitDuration>? {
        if let retryAfter = value(forHTTPHeaderField: "Retry-After"),
           let convertedToDouble = Double(retryAfter) {
            return Measurement(value: convertedToDouble, unit: .seconds)
        }

        return nil
    }
}
