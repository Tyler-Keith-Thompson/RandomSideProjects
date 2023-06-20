//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation

struct Assertion: Decodable {
    let signature: Data
    let authenticatorData: AuthenticatorData
}
