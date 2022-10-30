//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation
import RESTNetworkLayer

extension URLRequest {
    func addingBearerAuthorization(accessToken: String) -> URLRequest {
        addingValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }

    func receivingJSON() -> URLRequest {
        addingValue("application/json", forHTTPHeaderField: "Accept")
    }

    func sendingJSON() -> URLRequest {
        addingValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
