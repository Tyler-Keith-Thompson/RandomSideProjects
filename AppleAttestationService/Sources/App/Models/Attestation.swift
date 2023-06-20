//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation
import SwiftCBOR
import X509

struct Attestation: Decodable {
    let format: String
    let statement: Statement
    let authenticatorData: AuthenticatorData

    struct Statement: Decodable {
        let certificates: [X509.Certificate]
        let receipt: Data

        enum CodingKeys: String, CodingKey {
            case certificates = "x5c"
            case receipt
        }
    }
}

// MARK: - CBOR

extension Attestation {
    enum CodingKeys: String, CodingKey {
        case format = "fmt"
        case statement = "attStmt"
        case authenticatorData = "authData"
    }
}
